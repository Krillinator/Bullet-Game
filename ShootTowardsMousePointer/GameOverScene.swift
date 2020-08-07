//
//  GameOverScene.swift
//  ShootTowardsMousePointer
//
//  Created by Kristoffer on 2020-03-16.
//  Copyright © 2020 Kristoffer. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene {
  init(size: CGSize, won:Bool) {
    super.init(size: size)
    
    // Game over Color
    backgroundColor = SKColor.white
    
    // Result screen
    let message = won ? "You Won!" : "Game Over"
    
    // Message font
    let label = SKLabelNode(fontNamed: "Chalkduster")
    label.text = message
    label.fontSize = 40
    label.fontColor = SKColor.black
    label.position = CGPoint(x: size.width/2, y: size.height/2)
    addChild(label)
    
    // Screen time
    run(SKAction.sequence([
      SKAction.wait(forDuration: 3.0),
      SKAction.run() { [weak self] in
        // Return
        guard let `self` = self else { return }
        let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
        let scene = GameScene(size: size)
        self.view?.presentScene(scene, transition:reveal)
      }
      ]))
  }
  
  // Error
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
