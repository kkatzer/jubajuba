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
    var joy: OrbEntity!
    
    private var musicPlayer: AVAudioPlayer!
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        
        player = PlayerEntity(node: self.childNode(withName: "player") as! SKSpriteNode)
        
        joy = OrbEntity(node: self.childNode(withName: "joy") as! SKSpriteNode, type: .joy, player: player)
        
        joy.orbComponent.idleAnimation()
        
        //playMusic()
    }
    
    func setUpPlayer() {
        let playerNode = player.spriteComponent.node
        playerNode.zPosition = Layer.player.rawValue
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self.view)
        print(location.x)
        if (location.x < ((frame.width)/2)) {
            print("esquerda")
            //chamar a heldToTheLeft
        }else {
            print("direita")
            //chamar a heldToTheRight
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
    }
}
