//
//  OrbEntity.swift
//  Muffin
//
//  Created by Kevin Katzer on 20/08/19.
//  Copyright © 2019 Juba-Juba. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

enum Type: Int {
    case joy = 1
    case sadness = 2
    case anger = 3

    static let allValues = [joy, sadness, anger]
}

class OrbEntity: GKEntity {
    
    var spriteComponent: SpriteComponent!
    var orbComponent: OrbComponent!
    let type: Type!
    let player: PlayerEntity!
    
    init(node: SKSpriteNode, type: Type, player: PlayerEntity) {
        self.type = type
        self.player = player
        
        super.init()
        
        spriteComponent = SpriteComponent(entity: self, node: node)
        addComponent(spriteComponent)
        
        orbComponent = OrbComponent(entity: self, type: type)
        addComponent(orbComponent)
        
        switch type {
        case .joy:
            self.setUpLightNode(UIColor.yellow)
        //UIColor(red: <#T##CGFloat#>, green: <#T##CGFloat#>, blue: <#T##CGFloat#>, alpha: <#T##CGFloat#>)
        case .anger:
            self.setUpLightNode(UIColor.red)
        case .sadness:
            self.setUpLightNode(UIColor.blue)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpLightNode(_ color: UIColor) {
        let lightNode = SKLightNode()
        lightNode.position = CGPoint()
        lightNode.ambientColor = UIColor.white
        lightNode.lightColor = color
        lightNode.shadowColor = UIColor.black
        lightNode.falloff = 3.5
        
        let node = self.spriteComponent.node
        
        node.addChild(lightNode)
        
        spriteComponent.setUpLight(node, normalMap: true)
    }
    
    func setIsHidden(_ isHidden: Bool) {
        spriteComponent.node.isHidden = isHidden
    }
}
