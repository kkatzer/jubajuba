//
//  BreakComponent.swift
//  Muffin
//
//  Created by Kevin Katzer on 29/08/19.
//  Copyright © 2019 Juba-Juba. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class BreakComponent: GKComponent {
    
    let spriteComponent: SpriteComponent
    let breakable: Bool
    
    init(entity: RockEntity, breakable: Bool) {
        self.spriteComponent = entity.component(ofType: SpriteComponent.self)! // pointer to the sprite component
        self.breakable = breakable
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func breakRock() {
        if (breakable) {
            spriteComponent.node.removeFromParent()
        }
    }
}
