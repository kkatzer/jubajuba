//
//  IdleStates.swift
//  Muffin
//
//  Created by Vinícius Binder on 03/09/19.
//  Copyright © 2019 Juba-Juba. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class PlayingState: GKState {
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
        scene.tapRec.isEnabled = true
        scene.longPressRec.isEnabled = true
        scene.swipeUpRec.isEnabled = true
        scene.swipeDownRec.isEnabled = true
        scene.swipeSideRec.isEnabled = true
        
        scene.physicsWorld.gravity.dy = -9.8
        node.physicsBody?.linearDamping = 0
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return (stateClass == JoyGoingUpState.self) || (stateClass == BoostingDownState.self) || (stateClass == SinkingState.self) || (stateClass == DashingState.self)
    }
}
