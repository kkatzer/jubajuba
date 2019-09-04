//
//  AssetsUtil.swift
//  Muffin
//
//  Created by Andressa Valengo on 04/09/19.
//  Copyright © 2019 Juba-Juba. All rights reserved.
//

import Foundation
import SpriteKit

class AssetsUtil {
    public static func getSprites(named name: String) -> [SKTexture] {
        var animationSprites: [SKTexture] = []
        let animatedAtlas = SKTextureAtlas(named: name)
        let numTextures = animatedAtlas.textureNames.count
        for i in 0..<numTextures {
            let textureName = "\(name)_\(i)"
            animationSprites.append(animatedAtlas.textureNamed(textureName))
        }
        return animationSprites
    }
}
