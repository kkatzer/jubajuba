//
//  BreakComponent.swift
//  Muffin
//
//  Created by Kevin Katzer on 29/08/19.
//  Copyright © 2019 Juba-Juba. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit
import AVFoundation

class BreakComponent: GKComponent {
    
    let spriteComponent: SpriteComponent
    let breakable: Bool
    let scene: GameScene!
    var SFX: AVAudioPlayer!
    
    private let emitter = SKEmitterNode(fileNamed: "RockExplosion")
    
    init(entity: RockEntity, scene: GameScene, breakable: Bool) {
        self.spriteComponent = entity.component(ofType: SpriteComponent.self)!
        self.breakable = breakable
        self.scene = scene
        self.emitter?.zPosition = Layer.player.rawValue
        self.emitter?.position = spriteComponent.node.position
        emitter?.isHidden = true
        self.scene.addChild(emitter!)

        
        do {
            SFX = try AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "Stone Breaking", withExtension: "wav")!)
        } catch {
            print("Error: Could not load sound file.")
        }
        SFX.numberOfLoops = 0
        SFX.volume = 1.0
        SFX.prepareToPlay()
        
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func breakRock() {
        if (breakable && scene.stateMachine.currentState is DashingState) {
            SFX.play()
            spriteComponent.node.removeFromParent()
            emitter?.isHidden = false
            Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false, block: {timer in
                self.emitter?.removeFromParent()
            })
        }
    }
}
