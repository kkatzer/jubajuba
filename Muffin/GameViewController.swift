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
        
        // To do:
        // allow choice of which orbs to debug with
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
        playerLayer.videoGravity = .resizeAspectFill
        self.view.layer.addSublayer(playerLayer)
        player.play()
        sceneNode.musicPlayer.stop()
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        sceneNode.isPaused = false

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
        sceneNode.musicPlayer.play()
    }
    
    func loadScene(fileNamed name: String) {
        sceneNode = GameScene(fileNamed: name)
        sceneNode.scaleMode = .aspectFill
        sceneNode.sceneName = name
        sceneNode.gameViewDelegate = self
        sceneNode.levelConfigurator = self
        
        if let view = self.view as! SKView? {
            view.presentScene(sceneNode)
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = false
            view.showsPhysics = false
            view.showsNodeCount = false
        }
    }
    
    func loadSceneWithDelay(fileNamed name: String) {
        Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: {timer in
            self.loadScene(fileNamed: name)
        })
    }
}

extension GameViewController: TutorialView {
    func displayCutscene(forOrb orb: Orb) {
        lastPlayedCutscene = orb
        switch orb {
        case .Joy:
            playVideo(named: "CutsceneJoy")
            sceneNode.sceneName = "CutsceneJoy"
        case .Sadness:
            playVideo(named: "CutsceneSadness")
            sceneNode.sceneName = "CutsceneSadness"
            loadSceneWithDelay(fileNamed: "GameSceneSad")
        case .Anger:
            playVideo(named: "CutsceneAnger")
            sceneNode.sceneName = "CutsceneAnger"
            loadSceneWithDelay(fileNamed: "GameSceneAnger")
        }
    }
}

extension GameViewController: LevelConfigurator {
    func getCurrentConfiguration() -> LevelConfiguration {
        return levelConfig
    }
}
