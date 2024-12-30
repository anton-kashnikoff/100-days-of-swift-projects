//
//  WhackSlotNode.swift
//  Project14
//
//  Created by Антон Кашников on 08/11/2023.
//

import SpriteKit

final class WhackSlot: SKNode {
    var charNode: SKSpriteNode!
    var isVisible = false
    var isHit = false
    
    private enum Direction {
        case up
        case down
    }
    
    func configure(at position: CGPoint) {
        self.position = position
        
        addChild(SKSpriteNode(imageNamed: "whackHole"))
        
        charNode = SKSpriteNode(imageNamed: "penguinGood")
        charNode.position = CGPoint(x: 0, y: -90)
        charNode.name = "character"
        
        let cropNode = SKCropNode()
        cropNode.position = CGPoint(x: 0, y: 15)
        cropNode.zPosition = 1
        cropNode.maskNode = SKSpriteNode(imageNamed: "whackMask")
        cropNode.addChild(charNode)
        
        addChild(cropNode)
    }
    
    func show(hideTime: Double) {
        if isVisible { return }
        
        mudEffect(direction: .up)
        
        charNode.xScale = 1
        charNode.yScale = 1
        
        charNode.run(SKAction.moveBy(x: 0, y: 80, duration: 0.05))
        
        isVisible = true
        isHit = false
        
        // One-third of the time the penguin will be good, the rest of the time it will be bad.
        if Int.random(in: 0...2) == 0 {
            charNode.texture = SKTexture(imageNamed: "penguinGood")
            charNode.name = "charFriend"
        } else {
            charNode.texture = SKTexture(imageNamed: "penguinEvil")
            charNode.name = "charEnemy"
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + hideTime * 3.5) { [weak self] in
            self?.hide()
        }
    }
    
    func hide() {
        if !isVisible { return }
        
        mudEffect(direction: .down)
        
        charNode.run(SKAction.moveBy(x: 0, y: -80, duration: 0.05))
        isVisible = false
    }
    
    func hit() {
        isHit = true
        
        addSmokeEffect()
        
        charNode.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.25),
            SKAction.moveBy(x: 0, y: -80, duration: 0.5),
            SKAction.run { [unowned self] in self.isVisible = false }
        ]))
    }
    
    private func addSmokeEffect() {
        if let smoke = SKEmitterNode(fileNamed: "SmokeEmitter") {
            smoke.position = CGPoint(x: 0, y: 45)
            smoke.zPosition = 1
            smoke.numParticlesToEmit = 10
            smoke.particleLifetime = 0.75
            smoke.particleColor = SKColor.white
            smoke.particleAlpha = 0.2

            effectSequence(effect: smoke)
        }
    }
    
    private func effectSequence(effect: SKEmitterNode) {
        run(SKAction.sequence([
            SKAction.run { [weak self] in self?.addChild(effect) },
            SKAction.wait(forDuration: 2),
            SKAction.run { [weak self] in self?.removeChildren(in: [effect]) }
        ]))
    }
    
    private func mudEffect(direction: Direction) {
        if let mud = SKEmitterNode(fileNamed: "MudEmitter") {
            mud.position = CGPoint(x: 0, y: 0)
            mud.zPosition = 1
            mud.numParticlesToEmit = 100
            mud.particleBirthRate = 500
            mud.particleSize = CGSize(width: 30, height: 30)
            mud.particleColor = SKColor.brown
            mud.particleBlendMode = .replace
            switch direction {
            case .up:
                mud.particleLifetime = 0.30
                mud.particleSpeed = 1
                mud.particleSpeedRange = 300
            case .down:
                mud.particleLifetime = 0.10
                mud.particleSpeed = 100
                mud.particleSpeedRange = 0
            }
            
            effectSequence(effect: mud)
        }
    }
}
