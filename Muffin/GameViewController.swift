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
    
    @IBOutlet weak var cutsceneView: UIView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var finalImage: UIImageView!
    @IBOutlet weak var skipButton: UIButton!
    
    var sceneNode: GameScene!
    var playerLayer: AVPlayerLayer!
    var levelConfig = LevelConfiguration()
    var lastPlayedCutscene: Orb?
    var player: AVPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        skipButton.isHidden = true
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
    
    @IBAction func skipCutscene(_ sender: Any) {
        if let item = player?.currentItem {
            skipButton.isHidden = true
            player?.seek(to: item.duration)
        }
    }
    
    
    func playVideo(forOrb orb: Orb) {
        lastPlayedCutscene = orb
        
        var name = ""
        
        switch orb {
        case .Joy:
            name =  "CutsceneJoy"
        case .Sadness:
            name = "CutsceneSadness"
            loadSceneWithDelay(fileNamed: "GameSceneSad")
        case .Anger:
            name = "CutsceneAnger"
            loadSceneWithDelay(fileNamed: "GameSceneAnger")
        }
        
        guard let url = Bundle.main.url(forResource: "\(name)", withExtension:"mp4") else {
            debugPrint("\(name).mp4 not found")
            return
        }
        
        let item = AVPlayerItem(url: url)
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying(note:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item)
        
        player = AVPlayer(playerItem: item)
        player?.preventsDisplaySleepDuringVideoPlayback = true
                
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = videoView.bounds
        videoView.layer.addSublayer(playerLayer)
        
        cutsceneView.isHidden = false
        player?.play()
        sceneNode.musicPlayer.stop()
        
        if orb == Orb.Joy {
            self.skipButton.backgroundColor = UIColor.clear
            self.skipButton.isHidden = false
        }
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
        cutsceneView.isHidden = true
        skipButton.isHidden = true
        sceneNode.musicPlayer.play()
    }
    
    func loadScene(fileNamed name: String) {
        if let scene = GKScene(fileNamed: name) {
            sceneNode = scene.rootNode as! GameScene?
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
    }
    
    func loadSceneWithDelay(fileNamed name: String) {
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: {timer in
            self.loadScene(fileNamed: name)
        })
    }
}

extension GameViewController: TutorialView {
    func displayCutscene(forOrb orb: Orb) {
        playVideo(forOrb: orb)
    }
}

extension GameViewController: LevelConfigurator {
    func getCurrentConfiguration() -> LevelConfiguration {
        return levelConfig
    }
    
    func showImage() {
        finalImage.isHidden = false
        UIView.animate(withDuration: 1.5, animations: {
            self.finalImage.alpha = 1
        })
    }
    
    func sceneDidSetup() {
        if player?.rate != 0 {
            skipButton.isHidden = false
        }
    }
}
