//
//  BoostingDownState.swift
//  Muffin
//
//  Created by Vinícius Binder on 04/09/19.
//  Copyright © 2019 Juba-Juba. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit
import AVFoundation

class BoostingDownState: GKState {
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
        SFX.volume = 0.9
        SFX.prepareToPlay()
        
        super.init()
    }
    
    override func didEnter(from previousState: GKState?) {
        scene.tapRec.isEnabled = false
        scene.longPressRec.isEnabled = false
        scene.swipeUpRec.isEnabled = false
        scene.swipeDownRec.isEnabled = false
        scene.swipeLeftRec.isEnabled = true
        scene.swipeRightRec.isEnabled = true
        
        if previousState is JoyGlidingState {
            scene.physicsWorld.gravity.dy = -2
        } else {
            scene.physicsWorld.gravity.dy = -5
        }
        move.water = false
        move.ground = false
        move.sink()
        scene.callLightFX("Sad")
        
        node.removeAllActions()
        SFX.play()
        
        node.run(SKAction.repeatForever(SKAction.animate(with: Animations.shared.Heavy, timePerFrame: 0.02, resize: true, restore: true)), withKey: "heavy")
        // falling?
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return (stateClass == PlayingState.self) || (stateClass == SinkingState.self)
    }
}
