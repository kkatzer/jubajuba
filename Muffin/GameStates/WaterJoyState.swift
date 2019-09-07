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
        SFX.volume = 0.4
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
        SFX.play()
        move.joyJump()
        //scene.zoom()
        node.removeAllActions()
        // animation
        scene.stateMachine.enter(FloatingUpState.self)
        node.run(SKAction.repeatForever(SKAction.animate(with: Animations.Fly, timePerFrame: 0.015, resize: true, restore: true)), withKey: "joyGoingUp")
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return (stateClass == FloatingUpState.self) || (stateClass == FloatingOnlyState.self) || (stateClass == JoyGoingUpState.self)
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        
    }
}
