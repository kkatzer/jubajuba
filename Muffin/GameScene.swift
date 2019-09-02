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

struct PhysicsCategory {
    static let None: UInt32 = 0
    static let Player: UInt32 = 0b1
    static let Water: UInt32 = 0b10
    static let Ground: UInt32 = 0b100
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var deltaTime: TimeInterval = 0
    var lastUpdateTime: TimeInterval = 0
    
    var deltaStamp: TimeInterval = 0
    
    let velocityX: CGFloat = 200
    
    let tapRec = UITapGestureRecognizer()
    let longPressRec = UILongPressGestureRecognizer()
    let swipeUpRec = UISwipeGestureRecognizer()
    let swipeDownRec = UISwipeGestureRecognizer()
    let swipeSideRec = UISwipeGestureRecognizer()
    
    var player: PlayerEntity!
    var ground: SKNode!
    var water: SKSpriteNode!
    var joy: OrbEntity!
    var anger: OrbEntity!
    var sadness: OrbEntity!
    
    private var musicPlayer: AVAudioPlayer!
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        
        setUpGestureRecognizers()
        setUpPlayer()
        setUpGround()
        setUpOrbs()
        setUpWater()
    
        //playMusic()
    }
    
    @objc func jump() {
        if player.spriteComponent.node.physicsBody?.allContactedBodies().count != 0 {
            player.movementComponent?.jump()
        }
    }
    
    @objc func walk(sender: UITapGestureRecognizer) {
        let moveComponent = player.movementComponent
        let pos = sender.location(in: self.view!)
        
        if pos.x < (self.view!.frame.width / 2) {
            // left
            moveComponent?.moveToTheLeft(true)
        } else {
            // right
            moveComponent?.moveToTheRight(true)
        }
        
        if sender.state == .ended {
            moveComponent?.moveToTheLeft(false)
            moveComponent?.moveToTheRight(false)
        }
    }
    
    @objc func jumpUp() {
        if player.spriteComponent.node.physicsBody?.allContactedBodies().count != 0 {
            player.movementComponent?.joyJump()
            self.physicsWorld.gravity = CGVector(dx: 0, dy: -7)
        }
    }
    
    @objc func sink() {
        player.movementComponent?.sadSink()
    }
    
    func underWater(){
        if player.spriteComponent.node.physicsBody?.allContactedBodies().count != 0 {
            print("dentro da agua")
        }
    }
    
    func setUpGestureRecognizers() {
        tapRec.addTarget(self, action: #selector(jump))
        self.view!.addGestureRecognizer(tapRec)
        
        longPressRec.addTarget(self, action: #selector(walk))
        longPressRec.minimumPressDuration = 0.1
        self.view!.addGestureRecognizer(longPressRec)
        
        swipeUpRec.addTarget(self, action: #selector(jumpUp))
        swipeUpRec.direction = .up
        self.view!.addGestureRecognizer(swipeUpRec)
        
        swipeDownRec.addTarget(self, action: #selector(sink))
        swipeDownRec.direction = .down
        self.view!.addGestureRecognizer(swipeDownRec)
    }
    
    func setUpWater() {
        water = self.childNode(withName: "water") as? SKSpriteNode
        
        
            if water.texture == nil {
                water.physicsBody = SKPhysicsBody(rectangleOf: water.size)
            } else {
                water.physicsBody = SKPhysicsBody(texture: water.texture!, size: water.texture!.size())
            }
            
            let bodyWater = water.physicsBody
            bodyWater?.restitution = 0.0
            bodyWater?.categoryBitMask = PhysicsCategory.Water
            bodyWater?.contactTestBitMask = PhysicsCategory.Player
            bodyWater?.collisionBitMask = PhysicsCategory.Player
            bodyWater?.affectedByGravity = false
            bodyWater?.allowsRotation = false
            bodyWater?.isDynamic = true
            bodyWater?.pinned = true
        
    }
    
    func setUpPlayer() {
        player = PlayerEntity(node: self.childNode(withName: "player") as! SKSpriteNode)
        let node = player.spriteComponent.node
        node.zPosition = Layer.player.rawValue
        node.physicsBody?.restitution = 0.0
        node.physicsBody?.categoryBitMask = PhysicsCategory.Player
        node.physicsBody?.contactTestBitMask = PhysicsCategory.Ground | PhysicsCategory.Water
        node.physicsBody?.collisionBitMask = PhysicsCategory.Ground
    }
    
    func setUpGround() {
        ground = self.childNode(withName: "ground")
        
        ground.enumerateChildNodes(withName: "ground") { (node, stop) in
            let ground = node as! SKSpriteNode
            ground.zPosition = Layer.player.rawValue
            if ground.texture == nil {
                ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
            } else {
                ground.physicsBody = SKPhysicsBody(texture: ground.texture!, size: ground.texture!.size())
            }
            
            let body = ground.physicsBody
            body?.restitution = 0.0
            body?.categoryBitMask = PhysicsCategory.Ground
            body?.contactTestBitMask = PhysicsCategory.Player
            body?.affectedByGravity = false
            body?.allowsRotation = false
            body?.isDynamic = true
            body?.pinned = true
        }
    }
    
    func setUpOrbs() {
        joy = OrbEntity(node: self.childNode(withName: "joy") as! SKSpriteNode, type: .joy, player: player)
        joy.orbComponent.idleAnimation()
        anger = OrbEntity(node: self.childNode(withName: "anger") as! SKSpriteNode, type: .anger, player: player)
        anger.orbComponent.idleAnimation()
        sadness = OrbEntity(node: self.childNode(withName: "sadness") as! SKSpriteNode, type: .sadness, player: player)
        sadness.orbComponent.idleAnimation()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let other = contact.bodyA.categoryBitMask == PhysicsCategory.Player ? contact.bodyB : contact.bodyA
        
        if other.categoryBitMask == PhysicsCategory.Ground {
            if self.physicsWorld.gravity != CGVector(dx: 0, dy: -9.8) {
                self.physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
            }
        } else if other.categoryBitMask == PhysicsCategory.Water {
            // entrou na agua
            underWater()
            
        }
    }
    
    
//    func touchDown(atPoint pos : CGPoint) {
//        let moveComponent = player.movementComponent
//        let node = player.spriteComponent.node
//
//        if pos.x < (self.camera?.position.x)! {
//            // left
//            if moveComponent!.moveRight {
//                if node.physicsBody?.allContactedBodies() != nil {
//                    moveComponent?.jump()
//                }
//            } else {
//                moveComponent?.moveToTheLeft(true)
//            }
//        } else {
//            // right
//            if moveComponent!.moveLeft {
//                if node.physicsBody?.allContactedBodies() != nil {
//                    moveComponent?.jump()
//                }
//            } else {
//                moveComponent!.moveToTheRight(true)
//            }
//        }
//    }
//    
//    func touchUp(atPoint pos : CGPoint) {
//        let moveComponent = player.movementComponent
//        let node = player.spriteComponent.node
//        let contactedBodies = node.physicsBody?.allContactedBodies()
//
//        print(deltaStamp)
//        if deltaStamp < 0.05 && contactedBodies?.count != 0 {
//            print("oi")
//            moveComponent?.jump()
//        }
//
//        if pos.x < (self.camera?.position.x)! {
//            // left
//            if moveComponent!.moveLeft {
//                moveComponent!.moveToTheLeft(false)
//            } else if moveComponent!.moveRight {
//                moveComponent!.moveToTheRight(false)
//            }
//        } else {
//            // right
//            if moveComponent!.moveRight {
//                moveComponent!.moveToTheRight(false)
//            } else if moveComponent!.moveLeft {
//                moveComponent!.moveToTheLeft(false)
//            }
//        }
//    }
//
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//
//        for t in touches {
//            deltaStamp = t.timestamp
//            print(t.timestamp)
//            self.touchDown(atPoint: t.location(in: self))
//        }
//    }
//
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//
//        for t in touches {
//            deltaStamp = t.timestamp - deltaStamp
//            print(t.timestamp)
//            self.touchUp(atPoint: t.location(in: self))
//        }
//    }
    
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
