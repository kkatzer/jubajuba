//
//  DashingState.swift
//  Muffin
//
//  Created by Vinícius Binder on 04/09/19.
//  Copyright © 2019 Juba-Juba. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit
import AVFoundation

class DashingState: GKState {
    unowned let scene: GameScene
    unowned let node: SKSpriteNode
    unowned let move: MovementComponent
    public var left: Bool = true
    private var SFX: AVAudioPlayer!
    
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
        SFX.volume = 0.9
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
        move.water = false
        move.ground = false
        move.dash(left: self.left)
        scene.callLightFX("Anger")
        
        node.removeAllActions()
        let sequence = SKAction.sequence([
            .animate(with: Animations.shared.Dash, timePerFrame: 0.02, resize: true, restore: true),
            .run {
                self.move.stopDash()
                self.scene.stateMachine.enter(PlayingState.self)
            }
            ])
        node.run(sequence)
        
        if (left) {
            node.xScale = abs(node.xScale) * -1.0
        } else {
            node.xScale = abs(node.xScale) * 1.0
        }
        SFX.play()
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return (stateClass == PlayingState.self) || (stateClass == SinkingState.self)
    }
}
