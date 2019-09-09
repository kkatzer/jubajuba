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

protocol TutorialView: class {
    func displayCutscene(forOrb orb: Orb)
}

protocol LevelConfigurator: class {
    func getCurrentConfiguration() -> LevelConfiguration
}

class LevelConfiguration {
    var sadEnabled = false
    var joyEnabled = false
    var angerEnabled = false
}

enum Orb {
    case Joy
    case Sadness
    case Anger
}

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
    static let OrbHitbox: UInt32 = 0b11
}

class Animations {
    
    static let shared = Animations()
    
    let Dash: [SKTexture] = AssetsUtil.getSprites(named: "Dash")
    let Fall: [SKTexture] = AssetsUtil.getSprites(named: "Fall")
    let Falling: [SKTexture] = AssetsUtil.getSprites(named: "Falling")
    let Floating: [SKTexture] = AssetsUtil.getSprites(named: "Floating")
    let Fly: [SKTexture] = AssetsUtil.getSprites(named: "Fly")
    let FlyGlideTransition: [SKTexture] = AssetsUtil.getSprites(named: "FlyGlideTransition")
    let GettingUp: [SKTexture] = AssetsUtil.getSprites(named: "GettingUp")
    let Gliding: [SKTexture] = AssetsUtil.getSprites(named: "Gliding")
    let Heavy: [SKTexture] = AssetsUtil.getSprites(named: "Heavy")
    let Idle: [SKTexture] = AssetsUtil.getSprites(named: "Idle")
    let Jump: [SKTexture] = AssetsUtil.getSprites(named: "Jump")
    let Swimming: [SKTexture] = AssetsUtil.getSprites(named: "Swimming")
    let SwimmingStart: [SKTexture] = AssetsUtil.getSprites(named: "SwimmingStart")
    let SwimActionStart: [SKTexture] = AssetsUtil.getSprites(named: "SwimActionStart").reversed()
    let SwimActionEnd: [SKTexture] = AssetsUtil.getSprites(named: "SwimActionStart")
    let Walk: [SKTexture] = AssetsUtil.getSprites(named: "Walk")
    
    private init() {
        
    }
}

class GameScene: SKScene, SKPhysicsContactDelegate, UIGestureRecognizerDelegate {
    
    weak var gameViewDelegate: TutorialView?
    weak var levelConfigurator: LevelConfigurator?
    
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
    var barrierLeft: SKSpriteNode!
    var barrierRight: SKSpriteNode!
    
    private var joyPlayer: AVAudioPlayer!
    private var sadnessPlayer: AVAudioPlayer!
    private var angerPlayer: AVAudioPlayer!
    
    private var lastVelocityYStamp: CGFloat!
    private var secondToLastVelocityYStamp: CGFloat!
    
    var JoyLight: SKSpriteNode!
    var SadLight: SKSpriteNode!
    var AngerLight: SKSpriteNode!
        
//    private var region: Type? {
//        didSet {
//            switch region {
//            case .joy?:
//                if sadnessPlayer.isPlaying {
//                    sadnessPlayer.setVolume(0, fadeDuration: 1.0)
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                        self.sadnessPlayer.stop()
//                    }
//                }
//                joyPlayer.play()
//                joyPlayer.setVolume(1.5, fadeDuration: 2.0)
//            case .sadness?:
//                if joyPlayer.isPlaying {
//                    joyPlayer.setVolume(0, fadeDuration: 2.0)
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//                        self.joyPlayer.stop()
//                    }
//                } else if angerPlayer.isPlaying {
//                    angerPlayer.setVolume(0, fadeDuration: 1.0)
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//                        self.angerPlayer.stop()
//                    }
//                }
//                sadnessPlayer.play()
//                sadnessPlayer.setVolume(1.5, fadeDuration: 2.0)
//            case .anger?:
//                if sadnessPlayer.isPlaying {
//                    sadnessPlayer.setVolume(0, fadeDuration: 2.0)
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//                        self.sadnessPlayer.stop()
//                    }
//                }
//                angerPlayer.play()
//                angerPlayer.setVolume(1.5, fadeDuration: 1.0)
//            default:
//                print("Error: Could not locate player")
//            }
//        }
//    }
    
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
        
        if let hitBoxOrb = self.childNode(withName: "JoySpriteBox") as? SKSpriteNode {
            setupOrbHitBox(hitBoxOrb)
        }
        
        if let hitBoxOrb = self.childNode(withName: "SadSpriteBox") as? SKSpriteNode {
            setupOrbHitBox(hitBoxOrb)
        }
        
        if let hitBoxOrb = self.childNode(withName: "AngerSpriteBox") as? SKSpriteNode {
            setupOrbHitBox(hitBoxOrb)
        }
        
        setUpLighting()
        stateMachine.enter(PlayingState.self)
    
        setUpMusic()
        
        setUpLightFX()
    }
    
    func setUpLightFX() {
        JoyLight = SKSpriteNode(color: #colorLiteral(red: 1, green: 0.8562885523, blue: 0.000872995588, alpha: 1), size: CGSize(width: 1000, height: 1000))
        JoyLight.alpha = 0.0
        JoyLight.zPosition = 50
        addChild(JoyLight)
        SadLight = SKSpriteNode(color: #colorLiteral(red: 0.410720408, green: 0.6092639565, blue: 0.7631528974, alpha: 1), size: CGSize(width: 1000, height: 1000))
        SadLight.alpha = 0.0
        SadLight.zPosition = 50
        addChild(SadLight)
        AngerLight = SKSpriteNode(color: #colorLiteral(red: 0.826115787, green: 0.3553501666, blue: 0.4102210701, alpha: 1), size: CGSize(width: 1000, height: 1000))
        AngerLight.alpha = 0.0
        AngerLight.zPosition = 50
        addChild(AngerLight)
    }
    
    func callLightFX(_ type: String) {
        switch type {
        case "Joy":
            JoyLight.run(SKAction.sequence([
                .fadeAlpha(to: 0.15, duration: 0.6),
                .fadeAlpha(to: 0, duration: 0.6)
                ]))
        case "Sad":
            SadLight.run(SKAction.sequence([
                .fadeAlpha(to: 0.44, duration: 0.6),
                .fadeAlpha(to: 0, duration: 0.6)
                ]))
        case "Anger":
            AngerLight.run(SKAction.sequence([
                .fadeAlpha(to: 0.2, duration: 0.23),
                .fadeAlpha(to: 0, duration: 0.23)
                ]))
        default:
            break
        }
    }
    
    @objc func jump() {
        if player.spriteComponent.node.physicsBody?.allContactedBodies().count != 0 {
            player.movementComponent?.jump()
            player.movementComponent.ground = false
        }
    }
    
    @objc func walk(sender: UILongPressGestureRecognizer) {
        let moveComponent = player.movementComponent
        let pos = sender.location(in: self.view!)
        
        // comparar com o player e nao a view
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
        if let levelConfig = levelConfigurator?.getCurrentConfiguration() {
            if levelConfig.joyEnabled == false {
                return
            }
        }
        if stateMachine.currentState is SinkingState || stateMachine.currentState is FloatingUpState {
            stateMachine.enter(WaterJoyState.self)
        } else if stateMachine.currentState is FloatingOnlyState || stateMachine.currentState is PlayingState {
            stateMachine.state(forClass: JoyGoingUpState.self)!.comingFromWaterJoy = false
            stateMachine.enter(JoyGoingUpState.self)
        }
    }
    
    func zoom() {
        if (camera?.position.x)! > barrierLeft.position.x+CGFloat(600) && (camera?.position.x)! < barrierRight.position.x-CGFloat(600) {
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
        if let levelConfig = levelConfigurator?.getCurrentConfiguration() {
            if levelConfig.sadEnabled == false {
                return
            }
        }
        
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
        if let levelConfig = levelConfigurator?.getCurrentConfiguration() {
            if levelConfig.angerEnabled == false {
                return
            }
        }
        
        if stateMachine.currentState is FloatingUpState || stateMachine.currentState is SinkingState || stateMachine.currentState is FloatingOnlyState {
            stateMachine.state(forClass: WaterDashState.self)!.left = true
            stateMachine.enter(WaterDashState.self)
        } else if !(stateMachine.currentState is WaterSadState) && !(stateMachine.currentState is WaterJoyState) {
            stateMachine.state(forClass: DashingState.self)!.left = true
            stateMachine.enter(DashingState.self)
        }
    }
    
    @objc func rightDash() {
        if let levelConfig = levelConfigurator?.getCurrentConfiguration() {
            if levelConfig.angerEnabled == false {
                return
            }
        }
        
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
        player.spriteComponent.node.position.x += CGFloat(50)
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
        barrierLeft = self.childNode(withName: "barrierLeft") as? SKSpriteNode
        setUpPlayerContactNodes(barrierLeft, tree: true)
        barrierRight = self.childNode(withName: "barrierRight") as? SKSpriteNode
        setUpPlayerContactNodes(barrierRight, tree: true)
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
    
    func setupOrbHitBox(_ spriteNode: SKSpriteNode) {
        spriteNode.alpha = 0.0
        let nodeBody = SKPhysicsBody(rectangleOf: spriteNode.size)
        nodeBody.restitution = 0.0
        nodeBody.categoryBitMask = PhysicsCategory.OrbHitbox
        nodeBody.contactTestBitMask = PhysicsCategory.Player
        nodeBody.collisionBitMask = PhysicsCategory.Player
        nodeBody.affectedByGravity = false
        nodeBody.allowsRotation = false
        nodeBody.isDynamic = true
        nodeBody.pinned = true
        spriteNode.physicsBody = nodeBody
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
        if (self.childNode(withName: "rock") as? SKSpriteNode) != nil {
            rock = RockEntity(node: self.childNode(withName: "rock") as! SKSpriteNode, scene: self, breakable: true)
        }
        if (self.childNode(withName: "moveRock") as? SKSpriteNode) != nil {
            moveRock = RockEntity(node: self.childNode(withName: "moveRock") as! SKSpriteNode, scene: self, breakable: false)
        }
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
            //"Joy Z2", // creative decision (also sad mushrooms)
            "Joy Z-3",
            "Joy Z-4",
            "Sadness Z-4",
            "Sadness Z-6",
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
        
        if other.categoryBitMask == PhysicsCategory.Ground && !player.movementComponent.water {
            if stateMachine.currentState is JoyGlidingState || stateMachine.currentState is BoostingDownState || stateMachine.currentState is FloatingOnlyState {
                stateMachine.enter(PlayingState.self)
            }
            player.movementComponent.ground = true
        }
        
        if other.categoryBitMask == PhysicsCategory.Water {
            // entrou na agua
            if stateMachine.currentState is JoyGlidingState || stateMachine.currentState is PlayingState || stateMachine.currentState is DashingState || stateMachine.currentState is BoostingDownState {
                stateMachine.enter(SinkingState.self)
            }
        }
        
        if other.categoryBitMask == PhysicsCategory.OrbHitbox {
            player.movementComponent.stop()
            other.node?.removeFromParent()
            if let orbSprite = self.childNode(withName: "JoySprite") as? SKSpriteNode {
                self.gameViewDelegate?.displayCutscene(forOrb: Orb.Joy)
                orbSprite.removeFromParent()
            } else if let orbSprite = self.childNode(withName: "SadSprite") as? SKSpriteNode {
                self.gameViewDelegate?.displayCutscene(forOrb: Orb.Sadness)
                orbSprite.removeFromParent()
            } else if let orbSprite = self.childNode(withName: "AngerSprite") as? SKSpriteNode {
                self.gameViewDelegate?.displayCutscene(forOrb: Orb.Anger)
                orbSprite.removeFromParent()
            }
        }
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        let other = contact.bodyA.categoryBitMask == PhysicsCategory.Player ? contact.bodyB : contact.bodyA

        if other.categoryBitMask == PhysicsCategory.Water {
            if stateMachine.currentState is FloatingUpState {
                if secondToLastVelocityYStamp > CGFloat(220) {
                    // pass current velocity?
                    stateMachine.state(forClass: JoyGoingUpState.self)!.comingFromWaterJoy = true
                    stateMachine.enter(JoyGoingUpState.self)
                } else {
                    stateMachine.enter(FloatingOnlyState.self)
                }
            } else if stateMachine.currentState is FloatingOnlyState {
                stateMachine.enter(PlayingState.self)
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
        
        secondToLastVelocityYStamp = lastVelocityYStamp
        lastVelocityYStamp = player.spriteComponent.node.physicsBody!.velocity.dy
        
        camera?.position = player.spriteComponent.node.position + CGPoint(x: 0, y: frame.size.height/6)
        
        let width: CGFloat = UIScreen.main.bounds.size.width*UIScreen.main.bounds.size.width/UIScreen.main.bounds.size.height
        let posCamL = (camera?.position.x)! - width/4
        let posCamR = (camera?.position.x)! + width/4
        let posBarL = barrierLeft.position.x + 0.5*barrierLeft.size.width
        let posBarR = barrierRight.position.x - 0.5*barrierRight.size.width
        if posCamL < posBarL {
            camera?.position.x = posBarL + width/4
        } else if posCamR > posBarR {
            camera?.position.x = posBarR - width/4
        }
        
        if let levelConfig = levelConfigurator?.getCurrentConfiguration() {
            self.joy.setIsHidden(!levelConfig.joyEnabled)
            self.sadness.setIsHidden(!levelConfig.sadEnabled)
            self.anger.setIsHidden(!levelConfig.angerEnabled)
        }
        
        JoyLight.position = player.spriteComponent.node.position + CGPoint(x: 0, y: frame.size.height/6)
        SadLight.position = player.spriteComponent.node.position + CGPoint(x: 0, y: frame.size.height/6)
        AngerLight.position = player.spriteComponent.node.position + CGPoint(x: 0, y: frame.size.height/6)
        
//        if player.spriteComponent.node.position.x < 3150 {
//            if region != .joy {
//                region = .joy
//            }
//            if !joyPlayer.isPlaying {
//                joyPlayer.play()
//                joyPlayer.setVolume(1.5, fadeDuration: 2.0)
//            }
//        } else if player.spriteComponent.node.position.x < 4870 {
//            if region != .sadness {
//                region = .sadness
//            }
//            if !sadnessPlayer.isPlaying {
//                sadnessPlayer.play()
//                sadnessPlayer.setVolume(1.5, fadeDuration: 2.0)
//            }
//        } else {
//            if region != .anger {
//                region = .anger
//            }
//            if !angerPlayer.isPlaying {
//                angerPlayer.play()
//                angerPlayer.setVolume(1.5, fadeDuration: 2.0)
//            }
//        }
        
        stateMachine.update(deltaTime: deltaTime)
        
//        let fps = 20.0
//        let animFrames = Animations.shared.Idle
//        var normals = [SKTexture]()
//        for texture in animFrames {
//            normals.append(texture.generatingNormalMap(withSmoothness: 0.55, contrast: 0.3))
//        }
//        let anim = SKAction.customAction(withDuration: 1.0, actionBlock: { node, time in
//            let index = Int((fps * Double(time))) % animFrames.count
//            (node as! SKSpriteNode).normalTexture = normals[index]
//            (node as! SKSpriteNode).texture = animFrames[index]
//        })
//        player.spriteComponent.node.run(SKAction.repeatForever(anim));
    }
}
