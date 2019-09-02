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
    
    let spriteComponent: SpriteComponent
    let nodeBody: SKPhysicsBody
    
    var moveRight: Bool = false
    var moveLeft: Bool = false
    
    private var force = 200
    private var maxVelocity: CGFloat = 500
    private var jumpVelocity: CGFloat = 500
    private var joyJumpVelocity: CGFloat = 1000
    private var dashImpulse: CGFloat = 3000
    private var slowStopMultiplier: CGFloat = 3 // the higher the slower (0 <)
    
    init(entity: GKEntity) {
        self.spriteComponent = entity.component(ofType: SpriteComponent.self)! // pointer to the sprite component
        self.nodeBody = spriteComponent.node.physicsBody!
        super.init()
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
    
    func dash(left: Bool) {
        if (left) {
            spriteComponent.node.physicsBody?.velocity.dx = -dashImpulse
        } else {
            spriteComponent.node.physicsBody?.velocity.dx = dashImpulse
        }
    }
    func stop() {
        moveToTheLeft(false)
        moveToTheRight(false)
        nodeBody.velocity.dx /= slowStopMultiplier
    }
    
    override func update(deltaTime seconds: TimeInterval) {
//        if (nodeBody?.velocity.dx)! > maxVelocity {
//            nodeBody?.velocity.dx = maxVelocity
//        } else if (nodeBody?.velocity.dx)! < -maxVelocity {
//            nodeBody?.velocity.dx = -maxVelocity
//        }
//
//        if moveRight {
//            nodeBody!.applyForce(CGVector(dx: force, dy: 0))
//        } else if moveLeft {
//            nodeBody!.applyForce(CGVector(dx: -force, dy: 0))
//        }
        
        
        
        if -maxVelocity ... maxVelocity ~= (nodeBody?.velocity.dx)! {
            if moveRight {
                nodeBody!.applyForce(CGVector(dx: force, dy: 0))
            } else if moveLeft {
                nodeBody!.applyForce(CGVector(dx: -force, dy: 0))
            }
            }
        }
    }
}
