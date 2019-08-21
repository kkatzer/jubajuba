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
    
    let velocityX: CGFloat = 200
    
    var player: PlayerEntity!
    
    private var musicPlayer: AVAudioPlayer!
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        
        player = PlayerEntity(node: self.childNode(withName: "player") as! SKSpriteNode)
        
        
        //playMusic()
    }
    
    func setUpPlayer() {
        let playerNode = player.spriteComponent.node
        playerNode.zPosition = Layer.player.rawValue
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self.view)
        
        let moveComponent = player.movementComponent
        moveComponent?.moveEnabled = true
        
        if location.x < frame.size.width/2 {
            // left
            moveComponent?.setVelocity(-self.velocityX)
        } else {
            // right
            moveComponent?.setVelocity(self.velocityX)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let moveComponent = player.movementComponent
        moveComponent?.moveEnabled = false
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
    }
}
