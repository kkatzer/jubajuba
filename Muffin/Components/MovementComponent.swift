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
    
    let spriteComponent: SpriteComponent
    let nodeBody: SKPhysicsBody
    
    var moveRight: Bool = false
    var moveLeft: Bool = false
    
    private var force = 200
    private var maxVelocity: CGFloat = 500
    private var jumpVelocity: CGFloat = 500
    private var joyJumpVelocity: CGFloat = 1000
    private var dashImpulse: CGFloat = 1500
    private var slowStopMultiplier: CGFloat = 3 // the higher the slower (0 <)
    
    private var jumpSFX: AVAudioPlayer!
    private var stepsSFX: AVAudioPlayer!
    
    init(entity: GKEntity) {
        self.spriteComponent = entity.component(ofType: SpriteComponent.self)! // pointer to the sprite component
        self.nodeBody = spriteComponent.node.physicsBody!
        
        do {
            jumpSFX = try AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "Jump", withExtension: "wav")!)
        } catch {
            print("Error: Could not load sound file.")
        }
        jumpSFX.numberOfLoops = 0
        jumpSFX.volume = 3.0
        jumpSFX.prepareToPlay()
        
        do {
            stepsSFX = try AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "Steps", withExtension: "wav")!)
        } catch {
            print("Error: Could not load sound file.")
        }
        stepsSFX.numberOfLoops = -1
        stepsSFX.volume = 3.0
        stepsSFX.prepareToPlay()
        super.init()
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
    }
    
    func joyJump() {
        nodeBody.velocity.dy = joyJumpVelocity
    }
    
    func dash(left: Bool) {
        if (left) {
            self.nodeBody.velocity.dx = -dashImpulse
        } else {
            self.nodeBody.velocity.dx = dashImpulse
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
//        if (nodeBody?.velocity.dx)! > maxVelocity {
//            nodeBody?.velocity.dx = maxVelocity
//        } else if (nodeBody?.velocity.dx)! < -maxVelocity {
//            nodeBody?.velocity.dx = -maxVelocity
//        }
//
//        if moveRight {
//            nodeBody!.applyForce(CGVector(dx: force, dy: 0))
//        } else if moveLeft {
//            nodeBody!.applyForce(CGVector(dx: -force, dy: 0))
//        }
        
        
        
        if -maxVelocity ... maxVelocity ~= nodeBody.velocity.dx {
            if moveRight {
                if !jumpSFX.isPlaying {
                    jumpSFX.play()
                }
                nodeBody.applyForce(CGVector(dx: force, dy: 0))
            } else if moveLeft {
                if !jumpSFX.isPlaying {
                    jumpSFX.play()
                }
                nodeBody.applyForce(CGVector(dx: -force, dy: 0))
            }
        }
        
        if (!moveRight && !moveLeft) {
            stepsSFX.stop()
        }
    }
}
