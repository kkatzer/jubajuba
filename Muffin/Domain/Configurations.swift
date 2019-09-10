//
//  LevelConfiguration.swift
//  Muffin
//
//  Created by Andressa Valengo on 10/09/19.
//  Copyright © 2019 Juba-Juba. All rights reserved.
//

import Foundation

class LevelConfiguration {
    var sadEnabled = false
    var joyEnabled = false
    var angerEnabled = false
    
    public init() {}
    
    public init(joyEnabled: Bool, sadEnabled: Bool, angerEnabled: Bool) {
        self.joyEnabled = joyEnabled
        self.sadEnabled = sadEnabled
        self.angerEnabled = angerEnabled
    }
}
