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
        SFX.volume = 1.0
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
        node.removeAllActions()
        node.run(SKAction.animate(with: Animations.shared.Dash, timePerFrame: 0.02, resize: true, restore: true))
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
    
    override func update(deltaTime seconds: TimeInterval) {
        if abs((node.physicsBody?.velocity.dx)!) <= 150 {
            move.stopDash()
            scene.stateMachine.enter(PlayingState.self)
        }
    }
}
