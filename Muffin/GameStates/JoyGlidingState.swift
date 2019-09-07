//
//  JoyGlidingState.swift
//  Muffin
//
//  Created by Vinícius Binder on 03/09/19.
//  Copyright © 2019 Juba-Juba. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class JoyGlidingState: GKState {
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
        scene.longPressRec.isEnabled = true
        scene.swipeUpRec.isEnabled = false
        scene.swipeDownRec.isEnabled = true
        scene.swipeLeftRec.isEnabled = false
        scene.swipeRightRec.isEnabled = false
        
        scene.physicsWorld.gravity.dy = -2
        move.water = false
        move.ground = false
        node.removeAllActions()
        node.run(SKAction.repeatForever(SKAction.animate(with: Animations.Gliding, timePerFrame: 0.022, resize: true, restore: true)), withKey: "gliding")
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return (stateClass == PlayingState.self) || (stateClass == SinkingState.self) || (stateClass == BoostingDownState.self)
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        
    }
}
