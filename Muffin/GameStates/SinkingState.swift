//
//  EnterWaterState.swift
//  Muffin
//
//  Created by Vinícius Binder on 04/09/19.
//  Copyright © 2019 Juba-Juba. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit
import AVFoundation

class SinkingState: GKState {
    unowned let scene: GameScene
    unowned let node: SKSpriteNode
    unowned let move: MovementComponent
    
    private var splashSFX: AVAudioPlayer!
    var SFX: AVAudioPlayer!
    
    
    init(scene: SKScene, player: PlayerEntity) {
        self.scene = scene as! GameScene
        self.node = player.spriteComponent.node
        self.move = player.movementComponent
        
        do {
            splashSFX = try AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "Splash", withExtension: "wav")!)
        } catch {
            print("Error: Could not load sound file.")
        }
        splashSFX.numberOfLoops = 0
        splashSFX.volume = 0.2
        splashSFX.prepareToPlay()
        
        do {
            SFX = try AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "Under the Water", withExtension: "wav")!)
        } catch {
            print("Error: Could not load sound file.")
        }
        SFX.numberOfLoops = -1
        SFX.volume = 0.15
        SFX.prepareToPlay()
        
        super.init()
    }
    
    override func didEnter(from previousState: GKState?) {
        scene.tapRec.isEnabled = false
        scene.longPressRec.isEnabled = true
        scene.swipeUpRec.isEnabled = true
        scene.swipeDownRec.isEnabled = true
        scene.swipeLeftRec.isEnabled = true
        scene.swipeRightRec.isEnabled = true
        
        scene.physicsWorld.gravity.dy = 1
        node.physicsBody?.linearDamping = 1.5
        if (!move.water) {
            splashSFX.play()
        }
        move.water = true
        move.ground = false
        node.removeAllActions()
        
        let sequence = SKAction.sequence([
                .animate(with: Animations.shared.SwimmingStart, timePerFrame: 0.06, resize: true, restore: true),
                .run {
                    self.scene.stateMachine.enter(FloatingUpState.self)
                }
                ])
        node.run(sequence)
        
        if (!SFX.isPlaying) {
            SFX.play()
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return (stateClass == FloatingUpState.self) || (stateClass == WaterJoyState.self) || (stateClass == WaterSadState.self) || (stateClass == WaterDashState.self) || (stateClass == PausedState.self)
    }
}
