//
//  JoyGoingUpState.swift
//  Muffin
//
//  Created by Vinícius Binder on 03/09/19.
//  Copyright © 2019 Juba-Juba. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class JoyGoingUpState: GKState {
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
        scene.physicsWorld.gravity.dy = -9.8
        scene.tapRec.isEnabled = false
        scene.longPressRec.isEnabled = false
        scene.swipeUpRec.isEnabled = false
        scene.swipeDownRec.isEnabled = false
        scene.swipeSideRec.isEnabled = true
        move.joyJump()
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return (stateClass == JoyGlidingState.self)
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        print("oi");
        if node.physicsBody!.velocity.dy < 0 {
            scene.stateMachine.enter(JoyGlidingState.self)
        }
    }
}
