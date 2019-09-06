//
//  WaterDashState.swift
//  Muffin
//
//  Created by Vinícius Binder on 04/09/19.
//  Copyright © 2019 Juba-Juba. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class WaterDashState: GKState {
    unowned let scene: GameScene
    unowned let node: SKSpriteNode
    unowned let move: MovementComponent
    public var left: Bool = true
    
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
        scene.swipeLeftRec.isEnabled = false
        scene.swipeRightRec.isEnabled = false
        
        move.water = true
        move.dash(left: self.left)
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return (stateClass == FloatingUpState.self) || (stateClass == FloatingOnlyState.self) // || (stateClass == PlayingState.self)
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        if abs((node.physicsBody?.velocity.dx)!) <= 150 {
            scene.stateMachine.enter(FloatingUpState.self)
        }
    }
}
