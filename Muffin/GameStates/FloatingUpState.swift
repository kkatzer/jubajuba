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
        scene.swipeSideRec.isEnabled = true
        
        
//        node.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: node.size.width, height: 0.25 * node.size.height), center: CGPoint(x: 0, y: 20))
//        player.spriteComponent.setUpPlayerProperties()
//        move.setUp(player)
        
        print("entrou no floating")
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return (stateClass == WaterJoyState.self) || (stateClass == WaterSadState.self) || (stateClass == WaterDashState.self) || (stateClass == FloatingOnlyState.self)
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        
    }
}
