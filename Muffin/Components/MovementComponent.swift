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
    
    var moveEnabled: Bool = false
    
    var velocity: CGPoint!
    let gravity: CGFloat = -1500
    
    init(entity: GKEntity) {
        self.spriteComponent = entity.component(ofType: SpriteComponent.self)! // pointer to the sprite component
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setVelocity(_ x: CGFloat) {
        velocity = CGPoint(x: x, y: 0)
    }
    
    func applyMovement(_ seconds: TimeInterval) {
        let spriteNode = spriteComponent.node
        spriteNode.position += velocity * CGFloat(seconds)
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        if moveEnabled {
            applyMovement(seconds)
        }
    }
}
