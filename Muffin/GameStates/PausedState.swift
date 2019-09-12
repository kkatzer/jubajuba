//
//  PauseState.swift
//  Muffin
//
//  Created by Andressa Valengo on 11/09/19.
//  Copyright © 2019 Juba-Juba. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class PausedState: GKState {
    unowned let scene: GameScene
    unowned let node: SKSpriteNode
    unowned let move: MovementComponent
    
    init(scene: SKScene, player: PlayerEntity) {
        self.scene = scene as! GameScene
        self.node = player.spriteComponent.node
        self.move = player.movementComponent
        super.init()
    }
    
    override func didEnter(from previousState: GKState?) {
        scene.tapRec.isEnabled = false
        scene.longPressRec.isEnabled = false
        scene.swipeUpRec.isEnabled = false
        scene.swipeDownRec.isEnabled = false
        scene.swipeRightRec.isEnabled = false
        scene.swipeLeftRec.isEnabled = false
        scene.stopMusic()
        
        move.stop()
        
        node.removeAllActions()
        node.run(SKAction.repeatForever(SKAction.animate(with: Animations.shared.Idle, timePerFrame: 0.05, resize: true, restore: true)), withKey: "idle")
    }
}
