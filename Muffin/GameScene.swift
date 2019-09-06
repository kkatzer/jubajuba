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
//    static let Obstacle: UInt32 = 0b10
    static let Ground: UInt32 = 0b11
    static let Rock: UInt32 = 0b100
}

class GameScene: SKScene, SKPhysicsContactDelegate, UIGestureRecognizerDelegate {
    
    var deltaTime: TimeInterval = 0
    var lastUpdateTime: TimeInterval = 0
    
    var deltaStamp: TimeInterval = 0
    
    let velocityX: CGFloat = 200
    
    let tapRec = UITapGestureRecognizer()
    let longPressRec = UILongPressGestureRecognizer()
    let swipeUpRec = UISwipeGestureRecognizer()
    let swipeDownRec = UISwipeGestureRecognizer()
    let swipeLeftRec = UISwipeGestureRecognizer()
    let swipeRightRec = UISwipeGestureRecognizer()
    
    var player: PlayerEntity!
    var ground: SKNode!
    var joy: OrbEntity!
    var anger: OrbEntity!
    var sadness: OrbEntity!
    var rock: RockEntity!
    var moveRock: RockEntity!
    
    private var musicPlayer: AVAudioPlayer!
    
    lazy var stateMachine: GKStateMachine = GKStateMachine(states: [
        PlayingState(scene: self, player: self.player),
        JoyGoingUpState(scene: self, player: self.player),
        JoyGlidingState(scene: self, player: self.player),
        BoostingDownState(scene: self, player: self.player),
        SinkingState(scene: self, player: self.player),
        FloatingUpState(scene: self, player: self.player),
        WaterJoyState(scene: self, player: self.player),
        WaterSadState(scene: self, player: self.player),
        WaterDashState(scene: self, player: self.player),
        DashingState(scene: self, player: self.player)
        ])
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        
        setUpGestureRecognizers()
        setUpPlayer()
        setUpGround()
        setUpOrbs()
        setUpRock()
        
        stateMachine.enter(PlayingState.self)
    
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
        
        if pos.x < self.view!.frame.width/2 {
            // left
            moveComponent?.moveToTheLeft(true)
        } else {
            // right
            moveComponent?.moveToTheRight(true)
        }
        
        if sender.state == .ended {
            player.movementComponent.stop()
        }
    }
    
    @objc func jumpUp() {
        if player.spriteComponent.node.physicsBody?.allContactedBodies().count != 0 {
            stateMachine.enter(JoyGoingUpState.self)
        }
    }
    
    @objc func sink() {
        print("sink")
    }
    
    @objc func leftDash() {
        stateMachine.state(forClass: DashingState.self)!.left = true
        stateMachine.enter(DashingState.self)
    }
    
    @objc func rightDash() {
        stateMachine.state(forClass: DashingState.self)!.left = false
        stateMachine.enter(DashingState.self)
    }
    
    func setUpGestureRecognizers() {
        tapRec.addTarget(self, action: #selector(jump))
        tapRec.delegate = self
        self.view!.addGestureRecognizer(tapRec)
        
        longPressRec.addTarget(self, action: #selector(walk))
        longPressRec.delegate = self
        longPressRec.minimumPressDuration = 0.1
        
        self.view!.addGestureRecognizer(longPressRec)
        
        swipeUpRec.addTarget(self, action: #selector(jumpUp))
        swipeUpRec.delegate = self
        swipeUpRec.direction = .up
        self.view!.addGestureRecognizer(swipeUpRec)
        
        swipeDownRec.addTarget(self, action: #selector(sink))
        swipeDownRec.delegate = self
        swipeDownRec.direction = .down
        self.view!.addGestureRecognizer(swipeDownRec)
        
        swipeLeftRec.addTarget(self, action: #selector(leftDash))
        swipeLeftRec.direction = .left
        self.view!.addGestureRecognizer(swipeLeftRec)
        
        swipeRightRec.addTarget(self, action: #selector(rightDash))
        swipeRightRec.direction = .right
        self.view!.addGestureRecognizer(swipeRightRec)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.location(ofTouch: 0, in: self.view) == otherGestureRecognizer.location(ofTouch: 0, in: self.view) {
            return false
        }
        if gestureRecognizer is UILongPressGestureRecognizer || otherGestureRecognizer is UILongPressGestureRecognizer {
            return true
        }
        return false
    }
    
    func setUpPlayer() {
        player = PlayerEntity(node: self.childNode(withName: "player") as! SKSpriteNode)
        let node = player.spriteComponent.node
        //node.zPosition = Layer.player.rawValue
        node.physicsBody?.restitution = 0.0
        node.physicsBody?.categoryBitMask = PhysicsCategory.Player
        node.physicsBody?.contactTestBitMask = PhysicsCategory.Ground
    }
    
    func setUpGround() {
        ground = self.childNode(withName: "ground")
        
        ground.enumerateChildNodes(withName: "ground") { (node, stop) in
            let ground = node as! SKSpriteNode
            //ground.zPosition = Layer.player.rawValue
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
            body?.isDynamic = false
            body?.pinned = false
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
    
    func setUpRock() {
//        rock = RockEntity(node: self.childNode(withName: "rock") as! SKSpriteNode, scene: self, breakable: true)
//        moveRock = RockEntity(node: self.childNode(withName: "moveRock") as! SKSpriteNode, scene: self, breakable: false)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var other: SKPhysicsBody = contact.bodyA
        if contact.bodyA.categoryBitMask == PhysicsCategory.Player {
            other = contact.bodyB
        } else if contact.bodyB.categoryBitMask == PhysicsCategory.Player {
            other = contact.bodyA
        } else {
            return
        }
        
        if other.categoryBitMask == PhysicsCategory.Ground {
            if stateMachine.currentState is JoyGlidingState {
                stateMachine.enter(PlayingState.self)
            }
        }
        
        if other.categoryBitMask == PhysicsCategory.Rock {
            rock.breakComponent.breakRock()
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
        
        stateMachine.update(deltaTime: deltaTime)
    }
    
}
