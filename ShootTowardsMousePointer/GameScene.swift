//
//  GameScene.swift
//  ShootTowardsMousePointer
//
//  Created by Kristoffer on 2020-02-28.
//  Copyright © 2020 Kristoffer. All rights reserved.
//

import SpriteKit
import GameplayKit

// Direction implementation
func +(left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func -(left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func *(point: CGPoint, scalar: CGFloat) -> CGPoint {
  return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func /(point: CGPoint, scalar: CGFloat) -> CGPoint {
  return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
func sqrt(a: CGFloat) -> CGFloat {
  return CGFloat(sqrtf(Float(a)))
}
#endif

extension CGPoint {
  func length() -> CGFloat {
    return sqrt(x*x + y*y)
  }
  
  func normalized() -> CGPoint {
    return self / length()
  }
}

class GameScene: SKScene {
    
struct PhysicsCategory {
  static let none      : UInt32 = 0
  static let all       : UInt32 = UInt32.max
  static let monster   : UInt32 = 0b1
  static let projectile: UInt32 = 0b10
}

    // INIT
    var playerPos = CGPoint(x: 0, y: 0)
    let player = SKSpriteNode(imageNamed: "ninjaman")
    var scoreLabel: SKLabelNode!
    
    // Text setup
    var monstersDestroyed = 0 {
        didSet{
            scoreLabel.text = "Score: \(monstersDestroyed)"
        }
    }
    
    // m CGFloat = ??
    func test(x_pos: CGFloat, y_pos: CGFloat) -> CGFloat {
        let testDistance = x_pos + y_pos
        
        return (testDistance)
    }
    
    // return distance between two points
    func CGPointDistanceSquared(from: CGPoint, to: CGPoint) -> CGFloat {
        return (from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y)
    }

    // return distance squared between two points
    func CGPointDistance(from: CGPoint, to: CGPoint) -> CGFloat {
        return sqrt(CGPointDistanceSquared(from: from, to: to))
    }
    
    func random() -> CGFloat {
      return CGFloat(Float(arc4random()) / 4000000000) // Has to be 4000billion
    }

    func random(min: CGFloat, max: CGFloat) -> CGFloat {
      return random() * (max - min) + min
    }
    
    func addMonster() {
      // Create sprite
      let monster = SKSpriteNode(imageNamed: "monster")
        
        // Physics
        monster.physicsBody = SKPhysicsBody(rectangleOf: monster.size)
        monster.physicsBody?.isDynamic = true
        monster.physicsBody?.categoryBitMask = PhysicsCategory.monster
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.projectile
        monster.physicsBody?.collisionBitMask = PhysicsCategory.none
        
        // Spawn on Y-axis
        let actualY = random(min: monster.size.height, max: size.height - monster.size.height)
        
        // Position off screen
        monster.position = CGPoint(x: size.width + monster.size.width/3, y: actualY)
        
        // Add the monster to the scene
        addChild(monster)
        
        // Determine speed of the monster
        let actualDuration = random(min: CGFloat(2.0), max: CGFloat(6.0))
        
        // Create the actions
        let actionMove = SKAction.move(to: CGPoint(x: -monster.size.width/2, y: actualY), duration: TimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        let loseAction = SKAction.run() { [weak self] in
          guard let `self` = self else { return }
          let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
          let gameOverScene = GameOverScene(size: self.size, won: false)
          self.view?.presentScene(gameOverScene, transition: reveal)
        }
        monster.run(SKAction.sequence([actionMove, loseAction, actionMoveDone]))
    }
    
    // HIT
    func projectileDidCollideWithMonster(projectile: SKSpriteNode, monster: SKSpriteNode) {
      print("Hit")
      projectile.removeFromParent()
      monster.removeFromParent()
        // Win condition handling
        monstersDestroyed += 1
        
        // MARK: - WIN CONDITION
        if monstersDestroyed > 50 {
            let reveal = SKTransition.flipVertical(withDuration: 0.5)
            let gameOverScene = GameOverScene(size: self.size, won: true)
            view?.presentScene(gameOverScene, transition: reveal)
        }
    }
    
    // AddBullet
    func addSprite (clickPos:CGPoint) {
        
        // init
        let bulletSprite = SKSpriteNode(imageNamed: "BallBlue")

        // Physics
        bulletSprite.physicsBody = SKPhysicsBody(circleOfRadius: bulletSprite.size.width/2)
        bulletSprite.physicsBody?.isDynamic = true
        bulletSprite.physicsBody?.categoryBitMask = PhysicsCategory.projectile
        bulletSprite.physicsBody?.contactTestBitMask = PhysicsCategory.monster
        bulletSprite.physicsBody?.collisionBitMask = PhysicsCategory.none
        bulletSprite.physicsBody?.usesPreciseCollisionDetection = true
        
        // bullet = player position
        bulletSprite.position = player.position
        self.addChild(bulletSprite)
        
        let magnitudeOfObj = CGPointDistance(from: player.position, to: clickPos)
        
        // Multiplyer / magnitude
        /// let m: CGFloat = 1 / (size.height - magnitudeOfObj) sjukt coolt
        print("magnitude: \(magnitudeOfObj)")
        print("height: \(size.height)")
        // let m: CGFloat = ((size.height - magnitudeOfObj) / 100)
        let m: CGFloat = (size.height - magnitudeOfObj) / 100
        
        print("m: \(m)")
        // Distance between two points
        let outOfScreenPos = CGPoint(x: clickPos.x * m, y: clickPos.y * m)
        
        // Move bullet
        let actionMove = SKAction.move(to: outOfScreenPos,duration: TimeInterval(2))
        let actionMoveDone = SKAction.removeFromParent()
        
        // player pos to outside screen
        let distance = CGPointDistance(from: playerPos, to: outOfScreenPos)
        
        // Sequence Actions
        bulletSprite.run(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    override func didMove(to view: SKView) {
        // Label Setup
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: size.width * 0.5, y: size.height * 0.9)
        addChild(scoreLabel)
        
        backgroundColor = SKColor.gray
        player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
        playerPos = player.position
        
        // add player
        addChild(player)
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        // ADD MONSTERS FOREVER
        run(SKAction.repeatForever(
          SKAction.sequence([
            SKAction.run(addMonster),
            SKAction.wait(forDuration: 0.3) // Delay
            ])
        ))
        

    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
      // 1 - Touches
      guard let touch = touches.first else {
        return
      }
      let touchLocation = touch.location(in: self)
        let bulletSprite = SKSpriteNode(imageNamed: "BallBlue")

        // Physics
        bulletSprite.physicsBody = SKPhysicsBody(circleOfRadius: bulletSprite.size.width/2)
        bulletSprite.physicsBody?.isDynamic = true
        bulletSprite.physicsBody?.categoryBitMask = PhysicsCategory.projectile
        bulletSprite.physicsBody?.contactTestBitMask = PhysicsCategory.monster
        bulletSprite.physicsBody?.collisionBitMask = PhysicsCategory.none
        bulletSprite.physicsBody?.usesPreciseCollisionDetection = true
      
      // 2 - Set up initial location of projectile
      bulletSprite.position = player.position
      
      // 3 - Determine offset of location to projectile
      let offset = touchLocation - bulletSprite.position
      
      // 4 - Bail out if you are shooting down or backwards
      if offset.x < 0 { return }
      
      // 5 - OK to add now - double checked position
      addChild(bulletSprite)
      
      // 6 - Get the direction of where to shoot
      let direction = offset.normalized()
      
      // 7 - Make it shoot far enough to be guaranteed off screen
      let shootAmount = direction * 1000
      
      // 8 - Add the shoot amount to the current position
      let realDest = shootAmount + bulletSprite.position
      
      // 9 - Create the actions
      let actionMove = SKAction.move(to: realDest, duration: 2.0)
      let actionMoveDone = SKAction.removeFromParent()
      bulletSprite.run(SKAction.sequence([actionMove, actionMoveDone]))
    }
    /*override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchedPoint = touch.location(in: self)
            // TODO: Make this point real
            print(touchedPoint)
            addSprite(clickPos: touchedPoint)
        }
 */
    }

// Hit detection
extension GameScene: SKPhysicsContactDelegate {
  func didBegin(_ contact: SKPhysicsContact) {
    var firstBody: SKPhysicsBody
    var secondBody: SKPhysicsBody
    if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
      firstBody = contact.bodyA
      secondBody = contact.bodyB
    } else {
      firstBody = contact.bodyB
      secondBody = contact.bodyA
    }
    
    if ((firstBody.categoryBitMask & PhysicsCategory.monster != 0) &&
      (secondBody.categoryBitMask & PhysicsCategory.projectile != 0)) {
      if let monster = firstBody.node as? SKSpriteNode,
        let projectile = secondBody.node as? SKSpriteNode {
        projectileDidCollideWithMonster(projectile: projectile, monster: monster)
      }
    }
  }
}


///TRASH CODE FOR NOW
// SKAction.move(to: outOfScreenPos, duration: 2)

// let v = simd_float2(x: Float(playerPos.x), y: Float(playerPos.y))

// Removed: Continously draws when holding down
/*
 
 override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
     for touch in touches {
         let touchedPoint = touch.location(in: self)
         print(touchedPoint)
     }
     
 }
*/

// Bullet behavior
   //func bulletBehavior() {
       // simd_length(_:) - Return the length of a vector
       // simd_distance(_:_:) - Return the distance between two vectors
       
       
   //}
