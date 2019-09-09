//
//  WaterJoyState.swift
//  Muffin
//
//  Created by Vinícius Binder on 04/09/19.
//  Copyright © 2019 Juba-Juba. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit
import AVFoundation

class WaterJoyState: GKState {
    unowned let scene: GameScene
    unowned let node: SKSpriteNode
    unowned let move: MovementComponent
    private var SFX: AVAudioPlayer!
    
    init(scene: SKScene, player: PlayerEntity) {
        self.scene = scene as! GameScene
        self.node = player.spriteComponent.node
        self.move = player.movementComponent
        
        do {
            SFX = try AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "JoyUp", withExtension: "wav")!)
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
        node.physicsBody!.linearDamping = 1
        move.water = true
        move.ground = false
        
        node.removeAllActions()
        node.run(SKAction.sequence([
            .run {
                self.node.physicsBody?.velocity.dy = 0
                },
            .animate(with: Animations.shared.SwimActionStart, timePerFrame: 0.02, resize: true, restore: true),
            .run {
                self.SFX.play()
                self.scene.callLightFX("Joy")
                self.move.joyJump()
                self.scene.stateMachine.enter(FloatingUpState.self)
                }
            ]))
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return (stateClass == FloatingUpState.self) || (stateClass == FloatingOnlyState.self) || (stateClass == JoyGoingUpState.self)
    }
}
