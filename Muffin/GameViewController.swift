//
//  GameViewController.swift
//  Muffin
//
//  Created by Kevin Katzer on 15/08/19.
//  Copyright © 2019 Juba-Juba. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import AVFoundation

class GameViewController: UIViewController {
    
    var sceneNode: GameScene!
    var playerLayer: AVPlayerLayer!
    var levelConfig = LevelConfiguration()
    var lastPlayedCutscene: Orb?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadScene(fileNamed: "GameSceneJoy")
        
    }
    
    override var shouldAutorotate: Bool {
        return true
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func playVideo(named: String) {        
        guard let url = Bundle.main.url(forResource: "\(named)", withExtension:"mp4") else {
            debugPrint("\(named).mp4 not found")
            return
        }
        let item = AVPlayerItem(url: url)
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying(note:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item)
        let player = AVPlayer(playerItem: item)
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.view.bounds
        self.view.layer.addSublayer(playerLayer)
        player.play()
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        if let orb = lastPlayedCutscene {
            switch orb {
            case .Joy:
                levelConfig.joyEnabled = true
            case .Sadness:
                levelConfig.joyEnabled = true
                levelConfig.sadEnabled = true
            case .Anger:
                levelConfig.joyEnabled = true
                levelConfig.sadEnabled = true
                levelConfig.angerEnabled = true
            }
        }
        playerLayer.removeFromSuperlayer()
    }
    
    func loadScene(fileNamed name: String) {
        if let scene = GKScene(fileNamed: name) {
            sceneNode = scene.rootNode as! GameScene?
            sceneNode.scaleMode = .aspectFill
            sceneNode.gameViewDelegate = self
            sceneNode.levelConfigurator = self
            
            if let view = self.view as! SKView? {
                view.presentScene(sceneNode)
                
                view.ignoresSiblingOrder = true
                
                view.showsFPS = false
                view.showsPhysics = true
                view.showsNodeCount = false
            }
        }
    }
}

extension GameViewController: TutorialView {
    func displayCutscene(forOrb orb: Orb) {
        lastPlayedCutscene = orb
        switch orb {
        case .Joy:
            playVideo(named: "CutsceneJoy")
        case .Sadness:
            playVideo(named: "CutsceneSadness")
            loadScene(fileNamed: "GameSceneSad")
        case .Anger:
            playVideo(named: "CutsceneAnger")
            loadScene(fileNamed: "GameSceneAnger")
        }
    }
}

extension GameViewController: LevelConfigurator {
    func getCurrentConfiguration() -> LevelConfiguration {
        return levelConfig
    }
}
