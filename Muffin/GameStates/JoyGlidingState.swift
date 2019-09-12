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
        
        let sequence = SKAction.sequence([
            .animate(with: Animations.shared.FlyGlideTransition, timePerFrame: 0.008, resize: true, restore: true),
            .repeatForever(.animate(with: Animations.shared.Gliding, timePerFrame: 0.025, resize: true, restore: true))
            // falling?
            ])
        node.run(sequence)
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return (stateClass == PlayingState.self) || (stateClass == SinkingState.self) || (stateClass == BoostingDownState.self) || (stateClass == PausedState.self)
    }
}
