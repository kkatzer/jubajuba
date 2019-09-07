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
        
        setUpPlayerProperties()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpPlayerProperties() {
        let node = self.spriteComponent.node
        node.physicsBody = SKPhysicsBody(texture: node.texture!, size: CGSize(width: 0.3*node.texture!.size().width, height: 0.3*node.texture!.size().height))
        node.zPosition = Layer.player.rawValue
        node.physicsBody?.isDynamic = true
        node.physicsBody?.allowsRotation = false
        node.physicsBody?.pinned = false
        node.physicsBody?.affectedByGravity = true
        node.physicsBody?.restitution = 0.0
        node.physicsBody?.categoryBitMask = PhysicsCategory.Player
        node.physicsBody?.contactTestBitMask = PhysicsCategory.Ground | PhysicsCategory.Water
        node.physicsBody?.collisionBitMask = PhysicsCategory.Ground
        spriteComponent.setUpLight(node, normalMap: true)
    }
}
