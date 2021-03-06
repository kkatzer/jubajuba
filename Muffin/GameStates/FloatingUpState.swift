//
//  FloatingUpState.swift
//  Muffin
//
//  Created by Vinícius Binder on 04/09/19.
//  Copyright © 2019 Juba-Juba. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class FloatingUpState: GKState {
    unowned let scene: GameScene
    unowned let node: SKSpriteNode
    unowned let move: MovementComponent
    unowned let player: PlayerEntity
    
    init(scene: SKScene, player: PlayerEntity) {
        self.scene = scene as! GameScene
        self.node = player.spriteComponent.node
        self.move = player.movementComponent
        self.player = player
        super.init()
    }
    
    override func didEnter(from previousState: GKState?) {
        scene.tapRec.isEnabled = false
        scene.longPressRec.isEnabled = true
        scene.swipeUpRec.isEnabled = true
        scene.swipeDownRec.isEnabled = true
        scene.swipeLeftRec.isEnabled = true
        scene.swipeRightRec.isEnabled = true
        
        scene.physicsWorld.gravity.dy = 1
        node.physicsBody?.linearDamping = 1
        move.water = true
        move.ground = false
        node.removeAllActions()
        
        var sequence: SKAction
        if previousState is WaterJoyState {
            sequence = SKAction.sequence([
                .animate(with: Animations.shared.SwimActionEnd, timePerFrame: 0.02, resize: true, restore: true),
                .repeatForever(SKAction.animate(with: Animations.shared.Swimming, timePerFrame: 0.05, resize: true, restore: true))
                ])
        } else {
            sequence = SKAction.sequence([
                .repeatForever(SKAction.animate(with: Animations.shared.Swimming, timePerFrame: 0.05, resize: true, restore: true))
                ])
        }
        node.run(sequence)
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return (stateClass == WaterJoyState.self) || (stateClass == WaterSadState.self) || (stateClass == WaterDashState.self) || (stateClass == FloatingOnlyState.self) || (stateClass == JoyGoingUpState.self)
    }
}
