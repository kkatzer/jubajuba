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
    // background < 0
    case player = 0
    case water = 1
    case foreground = 3
}

struct PhysicsCategory {
    static let None: UInt32 = 0
    static let Player: UInt32 = 0b1
    static let Water: UInt32 = 0b10
    static let Ground: UInt32 = 0b100
    static let Rock: UInt32 = 0b1000
}

struct Animations {
    static let Dash: [SKTexture] = AssetsUtil.getSprites(named: "Dash")
    static let Fall: [SKTexture] = AssetsUtil.getSprites(named: "Fall")
    static let Falling: [SKTexture] = AssetsUtil.getSprites(named: "Falling")
    static let Floating: [SKTexture] = AssetsUtil.getSprites(named: "Floating")
    static let Fly: [SKTexture] = AssetsUtil.getSprites(named: "Fly")
    static let GettingUp: [SKTexture] = AssetsUtil.getSprites(named: "GettingUp")
    static let Gliding: [SKTexture] = AssetsUtil.getSprites(named: "Gliding")
    static let Heavy: [SKTexture] = AssetsUtil.getSprites(named: "Heavy")
    static let Jump: [SKTexture] = AssetsUtil.getSprites(named: "Jump")
    static let Swimming: [SKTexture] = AssetsUtil.getSprites(named: "Swimming")
    static let SwimmingStart: [SKTexture] = AssetsUtil.getSprites(named: "SwimmingStart")
    static let Walk: [SKTexture] = AssetsUtil.getSprites(named: "Walk")
}

class GameScene: SKScene, SKPhysicsContactDelegate, UIGestureRecognizerDelegate {
    
    var deltaTime: TimeInterval = 0
    var lastUpdateTime: TimeInterval = 0
    var deltaStamp: TimeInterval = 0
    
    let tapRec = UITapGestureRecognizer()
    let longPressRec = UILongPressGestureRecognizer()
    let swipeUpRec = UISwipeGestureRecognizer()
    let swipeDownRec = UISwipeGestureRecognizer()
    let swipeLeftRec = UISwipeGestureRecognizer()
    let swipeRightRec = UISwipeGestureRecognizer()

    var zoomOutAction = SKAction()
    var zoomInAction = SKAction()
    
    var player: PlayerEntity!
    var ground: SKNode!
    var joy: OrbEntity!
    var anger: OrbEntity!
    var sadness: OrbEntity!
    var rock: RockEntity!
    var moveRock: RockEntity!
    
    private var joyPlayer: AVAudioPlayer!
    private var sadnessPlayer: AVAudioPlayer!
    private var angerPlayer: AVAudioPlayer!
    
    private var region: Type? {
        didSet {
            switch region {
            case .joy?:
                if sadnessPlayer.isPlaying {
                    sadnessPlayer.setVolume(0, fadeDuration: 1.0)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.sadnessPlayer.stop()
                    }
                }
                joyPlayer.play()
                joyPlayer.setVolume(1.5, fadeDuration: 2.0)
            case .sadness?:
                if joyPlayer.isPlaying {
                    joyPlayer.setVolume(0, fadeDuration: 2.0)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        self.joyPlayer.stop()
                    }
                } else if angerPlayer.isPlaying {
                    angerPlayer.setVolume(0, fadeDuration: 1.0)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        self.angerPlayer.stop()
                    }
                }
                sadnessPlayer.play()
                sadnessPlayer.setVolume(1.5, fadeDuration: 2.0)
            case .anger?:
                if sadnessPlayer.isPlaying {
                    sadnessPlayer.setVolume(0, fadeDuration: 2.0)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        self.sadnessPlayer.stop()
                    }
                }
                angerPlayer.play()
                angerPlayer.setVolume(1.5, fadeDuration: 1.0)
            default:
                print("Error: Could not locate player")
            }
        }
    }
    
    lazy var stateMachine: GKStateMachine = GKStateMachine(states: [
        PlayingState(scene: self, player: self.player),
        JoyGoingUpState(scene: self, player: self.player),
        JoyGlidingState(scene: self, player: self.player),
        BoostingDownState(scene: self, player: self.player),
        SinkingState(scene: self, player: self.player),
        FloatingUpState(scene: self, player: self.player),
        FloatingOnlyState(scene: self, player: self.player),
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
        if let water = self.childNode(withName: "water") as? SKSpriteNode {
            setUpWater(water)
        }
        setUpLighting()
        stateMachine.enter(PlayingState.self)
    
        setUpMusic()
    }
    
    @objc func jump() {
        if player.spriteComponent.node.physicsBody?.allContactedBodies().count != 0 {
            player.movementComponent?.jump()
            player.movementComponent.ground = false
        }
    }
    
    @objc func walk(sender: UITapGestureRecognizer) {
        let moveComponent = player.movementComponent
        let pos = sender.location(in: self.view!)
        
        if pos.x < self.view!.frame.width/2 {
            // left
            moveComponent?.moveToTheLeft(true)
            player.spriteComponent.node.xScale = abs(player.spriteComponent.node.xScale) * -1.0
        } else {
            // right
            moveComponent?.moveToTheRight(true)
            player.spriteComponent.node.xScale = abs(player.spriteComponent.node.xScale) * 1.0
        }
        
        if sender.state == .ended {
            player.movementComponent.stop()
        }
    }
    
    @objc func jumpUp() {
        if stateMachine.currentState is SinkingState || stateMachine.currentState is FloatingUpState {
            stateMachine.enter(WaterJoyState.self)
        } else if stateMachine.currentState is FloatingOnlyState || stateMachine.currentState is PlayingState {
            stateMachine.enter(JoyGoingUpState.self)
        }
    }
    
    func zoom() {
        if (camera?.position.x)! > CGFloat(90) {
            zoomOutAction = SKAction.scale(to: 1.5, duration: 1)
            zoomOutAction.timingMode = .easeInEaseOut
            zoomInAction = SKAction.scale(to: 1, duration: 1)
            zoomInAction.timingMode = .easeInEaseOut
            camera?.run(SKAction.sequence([zoomOutAction, zoomInAction]))
        }
    }
    
    func checkGroundContact() -> Bool {
        for body in (player.spriteComponent.node.physicsBody?.allContactedBodies())! {
            if body.categoryBitMask == PhysicsCategory.Ground {
                return true
            }
        }
        return false
    }
    
    @objc func sink() {
        if stateMachine.currentState is SinkingState || stateMachine.currentState is FloatingOnlyState || stateMachine.currentState is FloatingUpState {
            stateMachine.enter(WaterSadState.self)
        } else if stateMachine.currentState is PlayingState || stateMachine.currentState is JoyGlidingState {
            if checkGroundContact() {
                jump()
            } else {
                stateMachine.enter(BoostingDownState.self)
            }
        }
    }
    
    @objc func leftDash() {
        if stateMachine.currentState is FloatingUpState || stateMachine.currentState is SinkingState || stateMachine.currentState is FloatingOnlyState {
            stateMachine.state(forClass: WaterDashState.self)!.left = true
            stateMachine.enter(WaterDashState.self)
        } else if !(stateMachine.currentState is WaterSadState) && !(stateMachine.currentState is WaterJoyState) {
            stateMachine.state(forClass: DashingState.self)!.left = true
            stateMachine.enter(DashingState.self)
        }
    }
    
    @objc func rightDash() {
        if stateMachine.currentState is FloatingUpState || stateMachine.currentState is SinkingState || stateMachine.currentState is FloatingOnlyState {
            stateMachine.state(forClass: WaterDashState.self)!.left = false
            stateMachine.enter(WaterDashState.self)
        } else if !(stateMachine.currentState is WaterSadState) && !(stateMachine.currentState is WaterJoyState)  {
            stateMachine.state(forClass: DashingState.self)!.left = false
            stateMachine.enter(DashingState.self)
        }
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
        player.setUpPlayerProperties()
        player.movementComponent.setUp(player)
    }
    
    func setUpPlayerContactNodes(_ node: SKSpriteNode, tree: Bool) {
        if node.texture == nil {
            node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
        } else {
            node.physicsBody = SKPhysicsBody(texture: node.texture!, size: node.texture!.size())
        }
        
        let body = node.physicsBody
        if !tree {
            node.alpha = 0.0
            body?.restitution = 0.0
            body?.categoryBitMask = PhysicsCategory.Ground
            body?.contactTestBitMask = PhysicsCategory.Player
        }
        body?.affectedByGravity = false
        body?.allowsRotation = false
        body?.isDynamic = false
        body?.pinned = false
    }
    
    func setUpGround() {
        ground = self.childNode(withName: "ground")
        ground.enumerateChildNodes(withName: "SKSpriteNode") { (node, stop) in
            self.setUpPlayerContactNodes(node as! SKSpriteNode, tree: false)
        }
        ground.enumerateChildNodes(withName: "tree") { (node, stop) in
            self.setUpPlayerContactNodes(node as! SKSpriteNode, tree: true)
        }
    }
    
    func setUpOrbs() {
        joy = OrbEntity(node: self.childNode(withName: "joy") as! SKSpriteNode, type: .joy, player: player)
        joy.orbComponent.idleAnimation()
        joy.spriteComponent.node.zPosition = Layer.player.rawValue
        anger = OrbEntity(node: self.childNode(withName: "anger") as! SKSpriteNode, type: .anger, player: player)
        anger.orbComponent.idleAnimation()
        anger.spriteComponent.node.zPosition = Layer.player.rawValue
        sadness = OrbEntity(node: self.childNode(withName: "sadness") as! SKSpriteNode, type: .sadness, player: player)
        sadness.orbComponent.idleAnimation()
        sadness.spriteComponent.node.zPosition = Layer.player.rawValue
    }
    
    func setUpWater(_ water: SKSpriteNode) {
        water.zPosition = Layer.water.rawValue
        water.alpha = 0.0
        
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
    
    func setUpRock() {
//        rock = RockEntity(node: self.childNode(withName: "rock") as! SKSpriteNode, scene: self, breakable: true)
//        moveRock = RockEntity(node: self.childNode(withName: "moveRock") as! SKSpriteNode, scene: self, breakable: false)
    }
    
    func setUpLighting() {
        let lightAffectedNodesWithMapping = [
            "Joy Z-2",
            "Joy Z3",
            "Sadness Z-2",
            "Sadness Z-3",
            "Sadness Z2",
            "Tree Z-3",
            "Cogumelos Z3",
            "Anger Z-2",
        ]
        let lightAffectedNodesWOMapping = [
            "Joy Z2",
            "Joy Z-4",
            "Sadness Z3",
            "Anger Z-4",
            "Anger Z-5",
        ]
        
        // With mapping
        for affectedNodeName in lightAffectedNodesWithMapping {
            let affectedNode = self.childNode(withName: affectedNodeName)
            affectedNode?.enumerateChildNodes(withName: "SKSpriteNode") { (node, stop) in
                let node = node as! SKSpriteNode
                self.player.spriteComponent.setUpLight(node, normalMap: true)
            }
        }
        
        // Without mapping
        for affectedNodeName in lightAffectedNodesWOMapping {
            let affectedNode = self.childNode(withName: affectedNodeName)
            affectedNode?.enumerateChildNodes(withName: "SKSpriteNode") { (node, stop) in
                let node = node as! SKSpriteNode
                self.player.spriteComponent.setUpLight(node, normalMap: false)
            }
        }
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
            if stateMachine.currentState is JoyGlidingState || stateMachine.currentState is BoostingDownState || stateMachine.currentState is FloatingOnlyState {
                stateMachine.enter(PlayingState.self)
            }
            player.movementComponent.ground = true
        }
        
        if other.categoryBitMask == PhysicsCategory.Water {
            // entrou na agua
            if stateMachine.currentState is JoyGlidingState || stateMachine.currentState is PlayingState || stateMachine.currentState is DashingState {
                stateMachine.enter(SinkingState.self)
            }
            if stateMachine.currentState is BoostingDownState {
                stateMachine.enter(WaterSadState.self)
            }
        }
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        let other = contact.bodyA.categoryBitMask == PhysicsCategory.Player ? contact.bodyB : contact.bodyA
        let player = contact.bodyA

        if other.categoryBitMask == PhysicsCategory.Water {
            if stateMachine.currentState is WaterJoyState {
                stateMachine.enter(JoyGoingUpState.self)
            } else if stateMachine.currentState is FloatingUpState {
                if (player.node?.physicsBody!.velocity.dy)! > CGFloat(300) {
                    stateMachine.enter(JoyGoingUpState.self)
                } else {
                    stateMachine.enter(FloatingOnlyState.self)
                }
            }
        } else if other.categoryBitMask == PhysicsCategory.Rock {
            rock.breakComponent.breakRock()
        }
    }
    
    func setUpMusic() {
        //Joy
        let joyURL = Bundle.main.url(forResource: "Joy", withExtension: "wav")!
        do {
            joyPlayer =  try AVAudioPlayer(contentsOf: joyURL)
        } catch {
            print("Error: Could not load sound file.")
        }
        joyPlayer.numberOfLoops = -1
        joyPlayer.volume = 0.0
        joyPlayer.prepareToPlay()
        
        //Sadness
        do {
            sadnessPlayer =  try AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "Sadness", withExtension: "wav")!)
        } catch {
            print("Error: Could not load sound file.")
        }
        sadnessPlayer.numberOfLoops = -1
        sadnessPlayer.volume = 0.0
        sadnessPlayer.prepareToPlay()
        
        //Anger
        do {
            angerPlayer =  try AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "Anger", withExtension: "wav")!)
        } catch {
            print("Error: Could not load sound file.")
        }
        angerPlayer.numberOfLoops = -1
        angerPlayer.volume = 0.0
        angerPlayer.prepareToPlay()
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        
        deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        player.update(deltaTime: deltaTime)
        
        let cameraBorder: CGFloat = -110
        camera?.position = player.spriteComponent.node.position + CGPoint(x: 0, y: frame.size.height/6)
        if (camera?.position.x)! < cameraBorder {
            camera?.position.x = cameraBorder
        } else if (camera?.position.x)! < cameraBorder {
            camera?.position.x = cameraBorder
        }
        
        if player.spriteComponent.node.position.x < 3150 {
            if region != .joy {
                region = .joy
            }
            if !joyPlayer.isPlaying {
                joyPlayer.play()
                joyPlayer.setVolume(1.5, fadeDuration: 2.0)
            }
        } else if player.spriteComponent.node.position.x < 4870 {
            if region != .sadness {
                region = .sadness
            }
            if !sadnessPlayer.isPlaying {
                sadnessPlayer.play()
                sadnessPlayer.setVolume(1.5, fadeDuration: 2.0)
            }
        } else {
            if region != .anger {
                region = .anger
            }
            if !angerPlayer.isPlaying {
                angerPlayer.play()
                angerPlayer.setVolume(1.5, fadeDuration: 2.0)
            }
        }
        
        stateMachine.update(deltaTime: deltaTime)
    }
}
