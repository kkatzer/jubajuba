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
    
    let tutorialRepository = TutorialRepository.shared
    
    var sceneNode: GameScene!
    var playerLayer: AVPlayerLayer!
    var levelConfig = LevelConfiguration()
    var lastPlayedCutscene: Orb?
    var player: AVPlayer?
    
    let gameScenes = [
        Orb.Joy: "GameSceneJoy",
        Orb.Sadness: "GameSceneSad",
        Orb.Anger: "GameSceneAnger"
    ]
    
    let gameCutscenes = [
        Orb.Joy: "CutsceneJoy",
        Orb.Sadness: "CutsceneSadness",
        Orb.Anger: "CutsceneAnger"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        skipButton.isHidden = true
        loadScene(forOrb: .Joy)
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
        
        guard let name = gameCutscenes[orb] else {
            print("no gameScene registered at the gamescene dictionary for orb \(orb)")
            return
        }
        
        if orb != .Joy {
            loadSceneWithDelay(forOrb: orb)
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
        
        if orb == Orb.Joy && tutorialRepository.isCheckpointCompleted(forOrb: orb) {
            self.skipButton.backgroundColor = UIColor.clear
            self.skipButton.isHidden = false
        }
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        sceneNode.isPaused = false

        if let orb = lastPlayedCutscene {
            levelConfig = tutorialRepository.getTutorialLevelConfiguration(forOrb: orb)
            tutorialRepository.setCheckPointCompleted(forOrb: orb)
        }
        
        playerLayer.removeFromSuperlayer()
        cutsceneView.isHidden = true
        skipButton.isHidden = true
        sceneNode.musicPlayer.play()
    }
    
    func loadScene(forOrb orb: Orb) {
        levelConfig = tutorialRepository.getTutorialLevelConfiguration(forOrb: orb)
        
        if let name = gameScenes[orb] {
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
    }
    
    func loadSceneWithDelay(forOrb orb: Orb) {
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: {timer in
            self.loadScene(forOrb: orb)
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
        if let orb = lastPlayedCutscene {
            if player?.rate != 0 && tutorialRepository.isCheckpointCompleted(forOrb: orb) {
                skipButton.isHidden = false
            }
        }
    }
}
