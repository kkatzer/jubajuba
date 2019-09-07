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
        scene.longPressRec.isEnabled = false
        scene.swipeUpRec.isEnabled = false
        scene.swipeDownRec.isEnabled = false
        scene.swipeLeftRec.isEnabled = false
        scene.swipeRightRec.isEnabled = false
        
        move.water = true
        move.ground = false
        move.dash(left: self.left)
        SFX.play()
        node.removeAllActions()
        // animation
        node.run(SKAction.animate(with: Animations.Dash, timePerFrame: 0.02, resize: true, restore: true))
        if (left) {
            node.xScale = abs(node.xScale) * -1.0
        } else {
            node.xScale = abs(node.xScale) * 1.0
        }

    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return (stateClass == FloatingUpState.self) || (stateClass == FloatingOnlyState.self) // || (stateClass == PlayingState.self)
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        if abs((node.physicsBody?.velocity.dx)!) <= 0.415*move.dashImpulse {
            scene.stateMachine.enter(FloatingUpState.self)
        }
    }
}
