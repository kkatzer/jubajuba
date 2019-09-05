//
//  SpriteComponent.swift
//  Muffin
//
//  Created by Vinícius Binder on 16/08/19.
//  Copyright © 2019 Juba-Juba. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class SpriteComponent: GKComponent {
    var node: SKSpriteNode
    
    init(entity: GKEntity, node: SKSpriteNode) {
        self.node = node
        self.node.entity = entity // pointer to parent
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpPlayerProperties() {
        node.zPosition = Layer.player.rawValue
        node.physicsBody?.isDynamic = true
        node.physicsBody?.allowsRotation = false
        node.physicsBody?.pinned = false
        node.physicsBody?.affectedByGravity = true
        node.physicsBody?.restitution = 0.0
        node.physicsBody?.categoryBitMask = PhysicsCategory.Player
        node.physicsBody?.contactTestBitMask = PhysicsCategory.Ground | PhysicsCategory.Water
        node.physicsBody?.collisionBitMask = PhysicsCategory.Ground
    }
}
