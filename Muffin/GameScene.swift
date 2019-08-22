//
//  GameScene.swift
//  Muffin
//
//  Created by Kevin Katzer on 15/08/19.
//  Copyright © 2019 Juba-Juba. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation

enum Layer: CGFloat {
    case distance
    case background
    case player
    case foreground
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var deltaTime: TimeInterval = 0
    var lastUpdateTime: TimeInterval = 0
    
    var deltaStamp: TimeInterval = 0
    
    let velocityX: CGFloat = 200
    
    var player: PlayerEntity!
    
    private var musicPlayer: AVAudioPlayer!
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        
        player = PlayerEntity(node: self.childNode(withName: "player") as! SKSpriteNode)
        
        //playMusic()
    }
    
    func setUpPlayer() {
        let node = player.spriteComponent.node
        node.zPosition = Layer.player.rawValue
        node.physicsBody?.restitution = 0.0
    }
    
    func setUpGround() {
        // layer player
        // restitution 0
    }
    
    func touchDown(atPoint pos : CGPoint) {
        let moveComponent = player.movementComponent
        let node = player.spriteComponent.node
        
        if pos.x < (self.camera?.position.x)! {
            // left
            if moveComponent!.moveRight {
                if node.physicsBody?.allContactedBodies() != nil {
                    moveComponent?.jump()
                }
            } else {
                moveComponent?.moveToTheLeft(true)
            }
        } else {
            // right
            if moveComponent!.moveLeft {
                if node.physicsBody?.allContactedBodies() != nil {
                    moveComponent?.jump()
                }
            } else {
                moveComponent!.moveToTheRight(true)
            }
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        let moveComponent = player.movementComponent
        let node = player.spriteComponent.node
        let contactedBodies = node.physicsBody?.allContactedBodies()
        
        print(deltaStamp)
        if deltaStamp < 0.05 && contactedBodies?.count != 0 {
            print("oi")
            moveComponent?.jump()
        }
        
        if pos.x < (self.camera?.position.x)! {
            // left
            if moveComponent!.moveLeft {
                moveComponent!.moveToTheLeft(false)
            } else if moveComponent!.moveRight {
                moveComponent!.moveToTheRight(false)
            }
        } else {
            // right
            if moveComponent!.moveRight {
                moveComponent!.moveToTheRight(false)
            } else if moveComponent!.moveLeft {
                moveComponent!.moveToTheLeft(false)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for t in touches {
            deltaStamp = t.timestamp
            print(t.timestamp)
            self.touchDown(atPoint: t.location(in: self))
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for t in touches {
            deltaStamp = t.timestamp - deltaStamp
            print(t.timestamp)
            self.touchUp(atPoint: t.location(in: self))
        }
    }
    
    func playMusic() {
        
        let url = Bundle.main.url(forResource: "", withExtension: "")!
        
        do {
            musicPlayer =  try AVAudioPlayer(contentsOf: url)
        } catch {
            print("Error: Could not load sound file.")
        }
        musicPlayer.numberOfLoops = -1
        musicPlayer.prepareToPlay()
        musicPlayer.play()
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        
        deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        player.update(deltaTime: deltaTime)
        camera?.position = player.spriteComponent.node.position + CGPoint(x: 0, y: frame.size.height/6)
    }
}
