//
//  TutorialRepository.swift
//  Muffin
//
//  Created by Andressa Valengo on 10/09/19.
//  Copyright © 2019 Juba-Juba. All rights reserved.
//

import Foundation

class TutorialRepository {
    
    enum Checkpoint: String {
        case Joy = "JoyCheckpoint"
        case Sadness = "SadnessCheckpoint"
        case Anger = "AngerCheckpoint"
    }
    
    public static let shared = TutorialRepository()
    
    private init() {}
    
    func setCompleted(checkpoint: Checkpoint) {
        UserDefaults.standard.set(true, forKey: checkpoint.rawValue)
    }
    
    func isCheckpointCompleted(for checkpoint: Checkpoint) -> Bool {
        return UserDefaults.standard.bool(forKey: checkpoint.rawValue)
    }
}
