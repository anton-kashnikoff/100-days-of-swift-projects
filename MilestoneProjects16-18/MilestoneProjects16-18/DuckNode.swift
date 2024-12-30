//
//  DuckNode.swift
//  MilestoneProjects16-18
//
//  Created by Антон Кашников on 09/01/2024.
//

import SpriteKit

enum DuckType {
    case good, bad
}

final class DuckNode: SKNode {
    static let duckColors = ["brown", "white", "yellow"]
    
    private var type: DuckType = .good
    
    var points = 100
    
    func configure(at position: CGPoint, type: DuckType, points: Int, xScale: CGFloat, yScale: CGFloat) {
        self.type = type
        self.points = points
        self.position = position
        self.xScale = xScale
        self.yScale = yScale
        
        let stick = SKSpriteNode(imageNamed: "stick_wood")
        stick.position = CGPoint(x: 0, y: 0)
        stick.zPosition = 0
        addChild(stick)
        
        guard let duckColor = DuckNode.duckColors.randomElement() else { return }
        
        let duck = SKSpriteNode(imageNamed: "duck" + (type == .good ? "_target_" : "_") + duckColor)
        duck.position = CGPoint(x: 0, y: 100)
        duck.zPosition = 0.1
        addChild(duck)
    }
}
