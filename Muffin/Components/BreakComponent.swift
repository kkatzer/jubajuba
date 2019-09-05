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
    let scene: GameScene!
    
    init(entity: RockEntity, scene: GameScene, breakable: Bool) {
        self.spriteComponent = entity.component(ofType: SpriteComponent.self)! // pointer to the sprite component
        self.breakable = breakable
        self.scene = scene
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func breakRock() {
        if (breakable && scene.stateMachine.currentState is DashingState) {
            spriteComponent.node.removeFromParent()
        }
    }
}
