//
//  OrbComponent.swift
//  Muffin
//
//  Created by Kevin Katzer on 21/08/19.
//  Copyright © 2019 Juba-Juba. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class OrbComponent: GKComponent {
    
    let spriteComponent: SpriteComponent
    let type: Type
    let player: PlayerEntity
    var timer: Timer?
    
    init(entity: OrbEntity, type: Type) {
        self.spriteComponent = entity.component(ofType: SpriteComponent.self)! // pointer to the sprite component
        self.player = entity.player
        self.type = type
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func idleAnimation() {
        if type == .joy {
            timer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(joy), userInfo: nil, repeats: true)
        }
    }
    
    @objc func joy() {
        let rightAction = SKAction.moveBy(x: 100.0, y: 10.0, duration: 2.0)
        rightAction.timingMode = .easeInEaseOut
        let leftAction = SKAction.moveBy(x: -100.0, y: -10.0, duration: 2.0)
        leftAction.timingMode = .easeInEaseOut
        let moveAction = SKAction.sequence([rightAction, leftAction])
        let upAction = SKAction.moveBy(x: 0, y: 20, duration: 1.0)
        upAction.timingMode = .easeOut
        let downAction = SKAction.moveBy(x: 0, y: -20, duration: 1.0)
        downAction.timingMode = .easeIn
        let jumpAction = SKAction.sequence([upAction, downAction, downAction, upAction])
        spriteComponent.node.run(moveAction)
        spriteComponent.node.run(jumpAction)
    }
}
