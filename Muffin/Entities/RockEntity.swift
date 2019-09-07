//
//  RockEntity.swift
//  Muffin
//
//  Created by Kevin Katzer on 29/08/19.
//  Copyright © 2019 Juba-Juba. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class RockEntity: GKEntity {
    var spriteComponent: SpriteComponent!
    var breakComponent: BreakComponent!
    
    let breakable: Bool!
    let scene: GameScene!
    
    init(node: SKSpriteNode, scene: GameScene, breakable: Bool) {
        self.scene = scene
        self.breakable = breakable
        
        super.init()
        
        spriteComponent = SpriteComponent(entity: self, node: node)
        addComponent(spriteComponent)
        
        breakComponent = BreakComponent(entity: self, scene: scene, breakable: breakable)
        addComponent(breakComponent)
        
        setUpPhysics()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpPhysics() {
        self.spriteComponent.node.zPosition = Layer.player.rawValue
        let body = self.spriteComponent.node.physicsBody
        body?.restitution = 0.2
        body?.categoryBitMask = PhysicsCategory.Rock
        body?.contactTestBitMask = PhysicsCategory.Player
        if (!breakable) {
            body?.affectedByGravity = true
            body?.allowsRotation = false
            body?.isDynamic = true
            body?.pinned = false
        }
    }
}
