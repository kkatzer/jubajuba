//
//  WaterDashState.swift
//  Muffin
//
//  Created by Vinícius Binder on 04/09/19.
//  Copyright © 2019 Juba-Juba. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit
import AVFoundation

class WaterDashState: GKState {
    unowned let scene: GameScene
    unowned let node: SKSpriteNode
    unowned let move: MovementComponent
    private var SFX: AVAudioPlayer!
    public var left: Bool = true
    
    init(scene: SKScene, player: PlayerEntity) {
        self.scene = scene as! GameScene
        self.node = player.spriteComponent.node
        self.move = player.movementComponent
        
        do {
            SFX = try AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "Dash", withExtension: "wav")!)
        } catch {
            print("Error: Could not load sound file.")
        }
        SFX.numberOfLoops = 0
        SFX.volume = 0.2
        SFX.prepareToPlay()
        
        super.init()
    }
    
    override func didEnter(from previousState: GKState?) {
        scene.tapRec.isEnabled = false
        scene.longPressRec.isEnabled = true
        scene.swipeUpRec.isEnabled = false
        scene.swipeDownRec.isEnabled = false
        scene.swipeLeftRec.isEnabled = false
        scene.swipeRightRec.isEnabled = false
        
        node.physicsBody?.linearDamping = 2.2
        move.water = true
        move.ground = false
        move.dash(left: self.left)
        SFX.play()
        node.removeAllActions()
        
        let sequence = SKAction.sequence([
            .animate(with: Animations.shared.SwimActionStart, timePerFrame: 0.015, resize: true, restore: true),
            .animate(with: Animations.shared.Dash, timePerFrame: 0.02, resize: true, restore: true),
            .animate(with: Animations.shared.SwimmingStart, timePerFrame: 0.03, resize: true, restore: true),
            .run {
                self.move.stopDash()
                self.scene.stateMachine.enter(FloatingUpState.self)
            }
            ])
        
        if (left) {
            node.xScale = abs(node.xScale) * -1.0
        } else {
            node.xScale = abs(node.xScale) * 1.0
        }
        node.run(sequence)
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return (stateClass == FloatingUpState.self) || (stateClass == FloatingOnlyState.self) // || (stateClass == PlayingState.self)
    }
}
