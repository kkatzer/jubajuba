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
        let node = spriteComponent.node
        node.zPosition = Layer.player.rawValue
        node.normalTexture = node.texture!.generatingNormalMap(withSmoothness: 0.55, contrast: 0.3)
        node.physicsBody = SKPhysicsBody(texture: node.texture!, size: CGSize(width: 0.7*node.texture!.size().width, height: node.texture!.size().height))
        
        let body = node.physicsBody
        body?.restitution = 0.2
        body?.categoryBitMask = PhysicsCategory.Rock
        body?.contactTestBitMask = PhysicsCategory.Player
        body?.affectedByGravity = true
        body?.allowsRotation = false
        body?.isDynamic = true
        if (!breakable) {
            body?.pinned = false
        } else {
            body?.pinned = true
        }
    }
}
