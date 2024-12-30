//
//  WaveNode.swift
//  MilestoneProjects16-18
//
//  Created by Антон Кашников on 08/01/2024.
//

import SpriteKit

enum WaveType {
    case top, center, bottom
}

enum WaveDirection {
    case right, left
}

final class WaveNode: SKNode {
    var direction: WaveDirection = .right
    var childrenMovement: CGFloat = 1400
    var childrenStartingPoint: CGFloat = -200
    
    func configure(at position: CGPoint, xScale: CGFloat, direction: WaveDirection) {
        self.direction = direction
        self.position = position
        self.xScale = xScale
        yScale = 1
        isUserInteractionEnabled = false
        
        childrenMovement /= xScale
        
        if direction == .left {
            childrenStartingPoint += childrenMovement
            childrenMovement = -childrenMovement
        }
        
        let nWave = Int(1 / xScale) + 1
        for i in 0...nWave {
            // stick several waves together to have them taller without stretching them
            addWave(x: 66 + (i * 798), y: -100)
            addWave(x: 66 + (i * 798), y: -50)
            addWave(x: 66 + (i * 798), y: 0)
            addWave(x: 66 + (i * 798), y: 50)
        }
    }
    
    func animate() {
        let rotateCW = SKAction.rotate(byAngle: CGFloat.pi / 128, duration: getDuration())
        let rotateCCW = SKAction.rotate(byAngle: CGFloat.pi / -128, duration: getDuration())
        let goDown = SKAction.moveBy(x: 0, y: -20, duration: getDuration())
        let goUp = SKAction.moveBy(x: 0, y: 20, duration: getDuration())
        let goLeft = SKAction.moveBy(x: -20, y: 0, duration: getDuration())
        let goRight = SKAction.moveBy(x: 20, y: 0, duration: getDuration())
        
        let sequence1 = SKAction.sequence([rotateCW, goDown, goLeft, rotateCCW, goUp, rotateCCW, goDown, goRight, rotateCW, goUp])
        let sequence2 = SKAction.sequence([rotateCCW, goUp, goRight, rotateCW, goDown, rotateCW, goUp, goLeft, rotateCCW, goDown])
        guard let sequence = [sequence1, sequence2].randomElement() else { return }
        run(SKAction.repeatForever(sequence))
    }
    
    private func addWave(x: Int, y: Int) {
        let wave = SKSpriteNode(imageNamed: "Water")
        wave.position = CGPoint(x: x, y: y)
        addChild(wave)
    }
    
    private func getDuration() -> Double {
        Double.random(in: 0.2...0.6)
    }
}
