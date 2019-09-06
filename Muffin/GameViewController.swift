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

class GameViewController: UIViewController {
    
    var sceneNode: GameScene!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let scene = GKScene(fileNamed: "GameScene") {
        sceneNode = scene.rootNode as! GameScene?
            
            sceneNode.scaleMode = .aspectFill
            
            if let view = self.view as! SKView? {
                view.presentScene(sceneNode)
                
                view.ignoresSiblingOrder = true
                
                view.showsFPS = false
                view.showsPhysics = true
                view.showsNodeCount = false
            }
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }

//    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//        return [.landscape, .landscapeLeft, .landscapeRight]
//    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
