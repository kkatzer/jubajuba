//
//  JoyGoingUpState.swift
//  Muffin
//
//  Created by Vinícius Binder on 03/09/19.
//  Copyright © 2019 Juba-Juba. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit
import AVFoundation

class JoyGoingUpState: GKState {
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
        SFX.volume = 1.0
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
        
        scene.physicsWorld.gravity.dy = -9.8
        node.physicsBody?.linearDamping = 0
        move.water = false
        move.ground = false
        move.joyJump()
        node.removeAllActions()
        node.run(SKAction.repeatForever(SKAction.animate(with: Animations.shared.Fly, timePerFrame: 0.015, resize: true, restore: true)), withKey: "joyGoingUp")
        scene.zoom()
        SFX.play()
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return (stateClass == JoyGlidingState.self)
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        let sinkingState = scene.stateMachine.state(forClass: SinkingState.self)
        if (sinkingState!.SFX.isPlaying) {
            sinkingState!.SFX.stop()
        }
        if node.physicsBody!.velocity.dy < 0 {
            scene.stateMachine.enter(JoyGlidingState.self)
            node.removeAction(forKey: "joyGoingUp")
        }
    }
}
