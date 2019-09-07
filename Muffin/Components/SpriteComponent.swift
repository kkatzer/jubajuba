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
    
    func setUpLight(_ node: SKSpriteNode, normalMap: Bool) {
        node.lightingBitMask = 1
        node.shadowCastBitMask = 0
        node.shadowedBitMask = 1
        if normalMap {
            node.normalTexture = node.texture?.generatingNormalMap(withSmoothness: 0.55, contrast: 0.3)
        }
    }
}
