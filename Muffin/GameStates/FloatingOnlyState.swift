//
//  FloatingOnlyState.swift
//  Muffin
//
//  Created by Eduarda Mello on 05/09/19.
//  Copyright © 2019 Juba-Juba. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class FloatingOnlyState: GKState {
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
        scene.swipeUpRec.isEnabled = true
        scene.swipeDownRec.isEnabled = true
        scene.swipeLeftRec.isEnabled = true
        scene.swipeRightRec.isEnabled = true
        
        node.physicsBody!.linearDamping = 0
        node.physicsBody!.velocity.dy = 0
        scene.physicsWorld.gravity.dy = 0
        move.water = true
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return (stateClass == JoyGoingUpState.self) || (stateClass == WaterSadState.self) || (stateClass == PlayingState.self) // || (stateClass == WaterDashState.self)
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        
    }
}
