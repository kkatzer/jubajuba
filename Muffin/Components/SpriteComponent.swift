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
    var lightNode: SKLightNode!
    var type: Type
    
    init(entity: GKEntity, node: SKSpriteNode, type: Type) {
        self.node = node
        self.node.entity = entity // pointer to parent
        self.type = type
        super.init()
        
        switch type {
        case .joy:
            self.setUpLightNode(UIColor.yellow)
            //UIColor(red: <#T##CGFloat#>, green: <#T##CGFloat#>, blue: <#T##CGFloat#>, alpha: <#T##CGFloat#>)
        case .anger:
            self.setUpLightNode(UIColor.red)
        case .sadness:
            self.setUpLightNode(UIColor.blue)
        case .none:
            break
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpLight(_ node: SKSpriteNode, normalMap: Bool) {
        node.lightingBitMask = 1
        node.shadowCastBitMask = 0
        node.shadowedBitMask = 1
        if normalMap {
            node.normalTexture = node.texture?.generatingNormalMap(withSmoothness: 0.55, contrast: 0.3)
        }
    }
    
    func setUpPlayerProperties() {
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
        setUpLight(node, normalMap: true)
    }
    
    func setUpLightNode(_ color: UIColor) {
        lightNode = SKLightNode()
        lightNode.position = CGPoint()
        lightNode.ambientColor = UIColor.darkGray
        lightNode.lightColor = color
        lightNode.shadowColor = UIColor.black
        lightNode.falloff = 4.7
        
//        switch type {
//        case .joy:
//            lightNode.falloff = 2
//        case .anger:
//            lightNode.falloff = 4.9
//        case .sadness:
//            lightNode.falloff = 1
//        case .none:
//            break
//        }
        
        node.addChild(lightNode)
        
        node.lightingBitMask = 1
        node.shadowCastBitMask = 0
        node.shadowedBitMask = 1
    }
}
