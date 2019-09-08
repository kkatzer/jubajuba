//
//  WaterSadState.swift
//  Muffin
//
//  Created by Vinícius Binder on 04/09/19.
//  Copyright © 2019 Juba-Juba. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class WaterSadState: GKState {
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
        scene.swipeDownRec.isEnabled = false
        scene.swipeLeftRec.isEnabled = true
        scene.swipeRightRec.isEnabled = true
        
        scene.physicsWorld.gravity.dy = 1
        node.physicsBody?.linearDamping = 1
        move.water = true
        move.ground = false
        move.sink()
        node.removeAllActions()
        
        let sequence: SKAction
        if !(previousState is FloatingOnlyState) {
            sequence = SKAction.sequence([
                .animate(with: Animations.shared.SwimActionStart, timePerFrame: 0.025, resize: true, restore: true),
                .animate(with: Animations.shared.Heavy, timePerFrame: 0.04, resize: true, restore: true),
                .animate(with: Animations.shared.SwimmingStart, timePerFrame: 0.025, resize: true, restore: true),
                .run {
                    self.scene.stateMachine.enter(FloatingUpState.self)
                }
                ])
        } else {
            sequence = SKAction.sequence([
                .animate(with: Animations.shared.Heavy, timePerFrame: 0.03, resize: true, restore: true),
                .animate(with: Animations.shared.SwimmingStart, timePerFrame: 0.01, resize: true, restore: true),
                .run {
                    self.scene.stateMachine.enter(FloatingUpState.self)
                }
                ])
        }
        node.run(sequence)
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return (stateClass == FloatingUpState.self) // || (stateClass == PlayingState.self)
    }
}
