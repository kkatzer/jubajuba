//
//  MovementComponent.swift
//  Muffin
//
//  Created by Vinícius Binder on 16/08/19.
//  Copyright © 2019 Juba-Juba. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit
import AVFoundation

class MovementComponent: GKComponent {
    
    var spriteComponent: SpriteComponent!
    var nodeBody: SKPhysicsBody!
    
    var moveRight: Bool = false
    var moveLeft: Bool = false
    var water: Bool = false
    var ground: Bool = false
    
    private var force = 200.0
    private var maxVelocity: CGFloat = 200
    private var jumpVelocity: CGFloat = 500
    private var sinkVelocity: CGFloat = -500
    private var joyJumpVelocity: CGFloat = 1000
    var dashImpulse: CGFloat = 600
    private var slowStopMultiplier: CGFloat = 3 // the higher the slower (0 <)
    
    private var jumpSFX: AVAudioPlayer!
    private var stepsSFX: AVAudioPlayer!
    
    func setUp(_ entity: GKEntity) {
        self.spriteComponent = entity.component(ofType: SpriteComponent.self)! // pointer to the sprite component
        self.nodeBody = spriteComponent.node.physicsBody!
    }
    
    init(entity: GKEntity) {
        do {
            jumpSFX = try AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "Jump", withExtension: "wav")!)
        } catch {
            print("Error: Could not load sound file.")
        }
        jumpSFX.numberOfLoops = 0
        jumpSFX.volume = 1.0
        jumpSFX.prepareToPlay()
        
        do {
            stepsSFX = try AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "Steps", withExtension: "wav")!)
        } catch {
            print("Error: Could not load sound file.")
        }
        stepsSFX.numberOfLoops = -1
        stepsSFX.volume = 1.0
        stepsSFX.prepareToPlay()
        super.init()
        setUp(entity)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func moveToTheLeft(_ move: Bool) {
        moveLeft = move
    }
    
    func moveToTheRight(_ move: Bool) {
        moveRight = move
    }
    
    func jump() {
        jumpSFX.play()
        nodeBody.velocity.dy = jumpVelocity
        self.spriteComponent.node.run(SKAction.animate(with: Animations.shared.Jump, timePerFrame: 0.03, resize: true, restore: true))
        
    }
    
    func joyJump() {
        nodeBody.velocity.dy = water ? 0.5*joyJumpVelocity : joyJumpVelocity
    }
    
    func sink() {
        nodeBody.velocity.dy = water ? 0.8*sinkVelocity : sinkVelocity
    }
    
    func dash(left: Bool) {
        if (left) {
            self.nodeBody.velocity.dx = water ? -0.5*dashImpulse : -dashImpulse
        } else {
            self.nodeBody.velocity.dx = water ? 0.5*dashImpulse : dashImpulse
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.48) {
            if self.nodeBody.velocity.dx > 150 {
                self.nodeBody.velocity.dx = 150
            } else if self.nodeBody.velocity.dx < -150 {
                self.nodeBody.velocity.dx = -150
            }
        }
    }
    
    func stop() {
        moveToTheLeft(false)
        moveToTheRight(false)
        nodeBody.velocity.dx /= slowStopMultiplier
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        let node = self.spriteComponent.node
        
        if -maxVelocity...maxVelocity ~= nodeBody.velocity.dx {
            if moveRight {
                if (!water && ground) {
                    if !stepsSFX.isPlaying {
                        stepsSFX.play()
                    }
                    if (node.action(forKey: "walking") == nil) {
                        node.run(SKAction.repeatForever(SKAction.animate(with: Animations.shared.Walk, timePerFrame: 0.025, resize: true, restore: true)), withKey: "walking")
                        node.xScale = abs(node.xScale) * 1.0
                    }
                }
                nodeBody.applyForce(CGVector(dx: water ? 0.1*force : force, dy: 0))
            } else if moveLeft {
                if (!water && ground) {
                    if !stepsSFX.isPlaying {
                        stepsSFX.play()
                    }
                    if (node.action(forKey: "walking") == nil) {
                        node.run(SKAction.repeatForever(SKAction.animate(with: Animations.shared.Walk, timePerFrame: 0.025, resize: true, restore: true)), withKey: "walking")
                        node.xScale = abs(node.xScale) * -1.0
                    }
                }
                nodeBody.applyForce(CGVector(dx: water ? -0.1*force : -force, dy: 0))
            }
        }
        
        if (!moveRight && !moveLeft || !ground) {
            stepsSFX.stop()
            node.removeAction(forKey: "walking")
        }
    }
}
