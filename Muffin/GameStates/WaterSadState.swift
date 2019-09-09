//
//  WaterSadState.swift
//  Muffin
//
//  Created by Vinícius Binder on 04/09/19.
//  Copyright © 2019 Juba-Juba. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit
import AVFoundation

class WaterSadState: GKState {
    unowned let scene: GameScene
    unowned let node: SKSpriteNode
    unowned let move: MovementComponent
    private var SFX: AVAudioPlayer!
    
    init(scene: SKScene, player: PlayerEntity) {
        self.scene = scene as! GameScene
        self.node = player.spriteComponent.node
        self.move = player.movementComponent
        
        do {
            SFX = try AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "BoostDown", withExtension: "wav")!)
        } catch {
            print("Error: Could not load sound file.")
        }
        SFX.numberOfLoops = 0
        SFX.volume = 0.5
        SFX.prepareToPlay()
        
        super.init()
    }
    
    override func didEnter(from previousState: GKState?) {
        scene.tapRec.isEnabled = false
        scene.longPressRec.isEnabled = true
        scene.swipeUpRec.isEnabled = false
        scene.swipeDownRec.isEnabled = false
        scene.swipeLeftRec.isEnabled = true
        scene.swipeRightRec.isEnabled = true
        
        scene.physicsWorld.gravity.dy = 1
        node.physicsBody?.linearDamping = 1
        move.water = true
        move.ground = false
        move.sink()
        scene.callLightFX("Sad")
        SFX.play()
        node.removeAllActions()
        
        let sequence: SKAction
        if !(previousState is FloatingOnlyState) {
            sequence = SKAction.sequence([
                .animate(with: Animations.shared.SwimActionStart, timePerFrame: 0.03, resize: true, restore: true),
                .animate(with: Animations.shared.Heavy, timePerFrame: 0.04, resize: true, restore: true),
                .animate(with: Animations.shared.SwimActionEnd, timePerFrame: 0.041, resize: true, restore: true),
                .run {
                    self.scene.stateMachine.enter(FloatingUpState.self)
                }
                ])
        } else {
            sequence = SKAction.sequence([
                // SwimActionStart trimmed
                .animate(with: Animations.shared.Heavy, timePerFrame: 0.04, resize: true, restore: true),
                .animate(with: Animations.shared.SwimActionEnd, timePerFrame: 0.04, resize: true, restore: true),
                .run {
                    self.scene.stateMachine.enter(FloatingUpState.self)
                }
                ])
        }
        node.run(sequence)
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return (stateClass == FloatingUpState.self) // || (stateClass == PlayingState.self)
    }
}
