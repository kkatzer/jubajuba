//
//  TutorialRepository.swift
//  Muffin
//
//  Created by Andressa Valengo on 10/09/19.
//  Copyright © 2019 Juba-Juba. All rights reserved.
//

import Foundation

class TutorialRepository {
    
    
    let checkpoints = [
        Orb.Joy: "JoyCheckpoint",
        Orb.Sadness: "SadnessCheckpoint",
        Orb.Anger: "AngerCheckpoint"
    ]
    
    public static let shared = TutorialRepository()
    
    private init() {}
    
    func setCheckPointCompleted(forOrb orb: Orb) {
        if let checkpoint = checkpoints[orb] {
            UserDefaults.standard.set(true, forKey: checkpoint)
        }
    }
    
    func isCheckpointCompleted(forOrb orb: Orb) -> Bool {
        if let checkpoint = checkpoints[orb] {
            return UserDefaults.standard.bool(forKey: checkpoint)
        }
        return false
    }
    
    func getTutorialLevelConfiguration(forOrb orb: Orb) -> LevelConfiguration {
        
         let levelConfig = LevelConfiguration(joyEnabled: isCheckpointCompleted(forOrb: Orb.Joy),
                                              sadEnabled: isCheckpointCompleted(forOrb: Orb.Sadness),
                                              angerEnabled: isCheckpointCompleted(forOrb: Orb.Anger))
        
        if orb == .Sadness || orb == .Anger {
            levelConfig.joyEnabled = true
            levelConfig.sadEnabled = true
        }
        
        if orb == .Anger {
            levelConfig.angerEnabled = true
        }
        
        return levelConfig
    }
}
