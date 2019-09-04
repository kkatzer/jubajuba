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
    
    init(scene: SKScene, player: PlayerEntity) {
        self.scene = scene as! GameScene
        self.node = player.spriteComponent.node
        self.move = player.movementComponent
        super.init()
    }
    
    override func didEnter(from previousState: GKState?) {
        scene.tapRec.isEnabled = false
        scene.longPressRec.isEnabled = false
        scene.swipeUpRec.isEnabled = true
        scene.swipeDownRec.isEnabled = true
        scene.swipeSideRec.isEnabled = true
        // things supposed to happen
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return (stateClass == SinkingState.self) || (stateClass == WaterJoyState.self) || (stateClass == WaterSadState.self) || (stateClass == WaterDashState.self)
    }
}
