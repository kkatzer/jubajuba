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
    
    @IBOutlet weak var finalImage: UIImageView!
    
    private let tutorialRepository = TutorialRepository.shared
    
    private var sceneNode: GameScene!
    private var cutsceneDisplayDelegator: CutsceneDisplayDelegator?
    private var levelConfig = LevelConfiguration()
    private var lastPlayedCutscene: Orb?
    
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
    
    func playCutscene(forOrb orb: Orb) {
        guard let fileName = gameCutscenes[orb] else {
            return
        }
        
        lastPlayedCutscene = orb
        
        self.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.navigationController?.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: CutsceneViewController.self)) as? CutsceneViewController {
            cutsceneDisplayDelegator = vc as CutsceneDisplayDelegator
            vc.cutsceneName = fileName
            vc.delegate = self
            self.navigationController?.present(vc, animated: false, completion:  nil)
        }
        
        if orb == Orb.Joy && tutorialRepository.isCheckpointCompleted(forOrb: orb) {
            cutsceneDisplayDelegator?.showSkipButton()
        }
    }
    
    func loadScene(forOrb orb: Orb) {
        levelConfig = tutorialRepository.getTutorialLevelConfiguration(forOrb: orb,
                                                                       isFirst: lastPlayedCutscene == nil)
        
        if let name = gameScenes[orb] {
            sceneNode = GameScene(fileNamed: name)
            sceneNode.scaleMode = .aspectFill
            sceneNode.sceneName = name
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
    
    func loadSceneWithDelay(forOrb orb: Orb) {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: {timer in
            self.loadScene(forOrb: orb)
        })
    }
}

extension GameViewController: TutorialView {
    func displayCutscene(forOrb orb: Orb) {
        playCutscene(forOrb: orb)
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
            if cutsceneDisplayDelegator?.hasStartedPlaying() ?? false && tutorialRepository.isCheckpointCompleted(forOrb: orb) {
                cutsceneDisplayDelegator?.showSkipButton()
            }
        }
    }
}

extension GameViewController: CutsceneDelegator {
    func playerDidFinishPlaying() {
        sceneNode.isPaused = false
        if let orb = lastPlayedCutscene {
            levelConfig = tutorialRepository.getTutorialLevelConfiguration(forOrb: orb, isFirst: false)
            tutorialRepository.setCheckPointCompleted(forOrb: orb)
        }
        sceneNode.playMusic()
        sceneNode.unpauseGame()
    }
    
    func playerDidFinishLoading() {
        guard let orb = lastPlayedCutscene else {
            return
        }
        if orb != .Joy {
            loadSceneWithDelay(forOrb: orb)
        }
    }
}
