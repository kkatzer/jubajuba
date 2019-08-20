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
    case background
    case player
    case foreground
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
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
}
