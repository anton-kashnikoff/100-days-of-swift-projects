//
//  BulletsNode.swift
//  MilestoneProjects16-18
//
//  Created by Антон Кашников on 09/01/2024.
//

import SpriteKit

final class BulletsNode: SKNode {
    // MARK: - Private Properties
    
    private var bullets = [SKSpriteNode]()
    private var bulletsCount = 6
    
    private let loadedTexture = SKTexture(imageNamed: "icon_bullet_gold_long")
    private let emptyTexture = SKTexture(imageNamed: "icon_bullet_empty_long")
    
    // MARK: - Public Methods
    
    func configure(at position: CGPoint) {
        self.position = position
        
        var x = 0
        for _ in 1...6 {
            bullets.append(addBullet(at: x))
            x += 25
        }
        
        // enlarge bullet tap area
        let transparency = SKSpriteNode()
        transparency.size = CGSize(width: 200, height: 150)
        transparency.position = CGPoint(x: -100, y: -75)
        addChild(transparency)
    }
    
    func reload() {
        for bullet in bullets {
            bullet.texture = loadedTexture
        }
        bulletsCount = 6
    }
    
    func remains() -> Bool {
        bulletsCount > 0
    }
    
    func decrease() {
        if bulletsCount <= 0 {
            return
        }
        
        bulletsCount -= 1
        bullets[bulletsCount].texture = emptyTexture
    }
    
    // MARK: - Private Methods
    
    private func addBullet(at x: Int) -> SKSpriteNode {
        let bullet = SKSpriteNode(imageNamed: "icon_bullet_gold_long")
        bullet.position = CGPoint(x: x, y: 0)
        bullet.zPosition = 1
        addChild(bullet)
        return bullet
    }
}
