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
    
    var moveRight: Bool = false
    var moveLeft: Bool = false
    
    private var force = 200
    private var maxVelocity: CGFloat = 500
    private var jumpVelocity: CGFloat = 500
    
    init(entity: GKEntity) {
        self.spriteComponent = entity.component(ofType: SpriteComponent.self)! // pointer to the sprite component
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
        spriteComponent.node.physicsBody?.velocity.dy = jumpVelocity
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        let nodeBody = spriteComponent.node.physicsBody
        
        if (nodeBody?.velocity.dx)! > maxVelocity {
            nodeBody?.velocity.dx = maxVelocity
        } else if (nodeBody?.velocity.dx)! < -maxVelocity {
            nodeBody?.velocity.dx = -maxVelocity
        }
        
        if moveRight {
            nodeBody!.applyForce(CGVector(dx: force, dy: 0))
        } else if moveLeft {
            nodeBody!.applyForce(CGVector(dx: -force, dy: 0))
        }
    }
}
