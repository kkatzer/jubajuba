//
//  MovementComponent.swift
//  Muffin
//
//  Created by Vinícius Binder on 16/08/19.
//  Copyright © 2019 Juba-Juba. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class MovementComponent: GKComponent {
    
    var spriteComponent: SpriteComponent!
    var nodeBody: SKPhysicsBody!
    
    var moveRight: Bool = false
    var moveLeft: Bool = false
    
    private var force = 200
    private var maxVelocity: CGFloat = 500
    private var jumpVelocity: CGFloat = 500
    private var sinkVelocity: CGFloat = -1000
    private var joyJumpVelocity: CGFloat = 1000
    private var slowStopMultiplier: CGFloat = 3 // the higher the slower (0 <)
    
    func setUp(_ entity: GKEntity) {
        self.spriteComponent = entity.component(ofType: SpriteComponent.self)! // pointer to the sprite component
        self.nodeBody = spriteComponent.node.physicsBody!
    }
    
    init(entity: GKEntity) {
        super.init()
        setUp(entity)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func moveToTheLeft(_ move: Bool) {
        moveLeft = move
    }
    
    func moveToTheRight(_ move: Bool) {
        moveRight = move
    }
    
    func jump() {
        nodeBody.velocity.dy = jumpVelocity
    }
    
    func joyJump() {
        nodeBody.velocity.dy = joyJumpVelocity
    }
    
//    func sadSink(){
//        spriteComponent.node.physicsBody?.velocity.dy = sinkVelocity
//    }
    
    func stop() {
        moveToTheLeft(false)
        moveToTheRight(false)
        nodeBody.velocity.dx /= slowStopMultiplier
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        
        if (nodeBody.velocity.dx) > maxVelocity {
            nodeBody.velocity.dx = maxVelocity
        } else if (nodeBody.velocity.dx) < -maxVelocity {
            nodeBody.velocity.dx = -maxVelocity
        }
        
        if moveRight {
            nodeBody.applyForce(CGVector(dx: force, dy: 0))
        } else if moveLeft {
            nodeBody.applyForce(CGVector(dx: -force, dy: 0))
        }
    }
}
