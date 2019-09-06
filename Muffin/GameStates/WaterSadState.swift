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
    
    let sinkVelocity: CGFloat = -1000
    
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
        scene.swipeSideRec.isEnabled = true
        // things supposed to happen
        print("mergulhou")
        
        scene.physicsWorld.gravity.dy = 1
        node.physicsBody?.linearDamping = 1
        node.physicsBody?.velocity.dy = sinkVelocity
        
        
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return (stateClass == FloatingUpState.self) // || (stateClass == PlayingState.self)
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        if node.physicsBody!.velocity.dy >= 0 {
            scene.stateMachine.enter(FloatingUpState.self)
        }
    }
}
