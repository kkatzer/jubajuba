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
    var positionNegative: Bool = true
    
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
        switch type {
        case .joy:
            timer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(joy), userInfo: nil, repeats: true)
        case .anger:
            timer = Timer.scheduledTimer(timeInterval: 0.75, target: self, selector: #selector(anger), userInfo: nil, repeats: true)
        case .sadness:
            timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(sadness), userInfo: nil, repeats: true)
        }
    }
    
    @objc func joy() {
        //If orb is on the right, goes to the left, and vice-versa
        let position = positionNegative ? CGPoint(x: player.spriteComponent.node.position.x + CGFloat.random(in: 35.00...80.00), y: player.spriteComponent.node.position.y + CGFloat.random(in: 90.00...110.00)) : CGPoint(x: player.spriteComponent.node.position.x - CGFloat.random(in: 35.00...80.00), y: player.spriteComponent.node.position.y + CGFloat.random(in: 90.00...110.00))
        positionNegative = !positionNegative
        let moveAction = SKAction.move(to: position, duration: 1.5)
        moveAction.timingMode = .easeInEaseOut
        let random = CGFloat.random(in: 20.0...40.0)
        let upAction = SKAction.moveBy(x: 0, y: random, duration: 0.75)
        upAction.timingMode = .easeOut
        let downAction = SKAction.moveBy(x: 0, y: random, duration: 0.75)
        downAction.timingMode = .easeIn
        let jumpAction = SKAction.sequence([upAction, downAction])
        spriteComponent.node.run(moveAction)
        spriteComponent.node.run(jumpAction)
    }
    
    @objc func anger() {
        //If orb is on the right, goes to the left, and vice-versa
        let position = positionNegative ? CGPoint(x: player.spriteComponent.node.position.x + CGFloat.random(in: 50.00...100.00), y: player.spriteComponent.node.position.y + CGFloat.random(in: 70.00...130.00)) : CGPoint(x: player.spriteComponent.node.position.x - CGFloat.random(in: 50.00...100.00), y: player.spriteComponent.node.position.y + CGFloat.random(in: 70.00...130.00))
        positionNegative = !positionNegative
        
        let moveAction = SKAction.move(to: position, duration: 0.15)
        moveAction.timingMode = .easeInEaseOut
        
        spriteComponent.node.run(moveAction)
    }
    
    @objc func sadness() {
        let moveAction = SKAction.move(to: CGPoint(x: player.spriteComponent.node.position.x - 50.0, y: player.spriteComponent.node.position.y + CGFloat.random(in: 65.0...100.0)), duration: 2.0)
        spriteComponent.node.run(moveAction)
    }
}
