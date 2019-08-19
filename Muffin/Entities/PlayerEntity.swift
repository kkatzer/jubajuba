//
//  PlayerEntity.swift
//  Muffin
//
//  Created by Vinícius Binder on 16/08/19.
//  Copyright © 2019 Juba-Juba. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class PlayerEntity: GKEntity {
    
    var spriteComponent: SpriteComponent!
    var movementComponent: MovementComponent!
    
    init(node: SKSpriteNode) {
        super.init()
        
        spriteComponent = SpriteComponent(entity: self, node: node)
        addComponent(spriteComponent)
        
        movementComponent = MovementComponent(entity: self)
        addComponent(movementComponent)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
