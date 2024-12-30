//
//  GameScene.swift
//  Project20
//
//  Created by Антон Кашников on 21/01/2024.
//

import SpriteKit

final class GameScene: SKScene {
    
    // MARK: - Private Properties
    
    private var gameTimer: Timer?
    private var fireworks = [SKNode]()
    private var gameOverLabel: SKLabelNode!
    private var newGameLabel: SKLabelNode!
    private var scoreLabel: SKLabelNode!
    private var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    private var launches = 0
    
    private let maxLaunches = 20
    private let leftEdge = -22
    private let bottomEdge = -22
    private let rightEdge = 1024 + 22
    
    // MARK: - SKScene
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        scoreLabel = SKLabelNode(fontNamed: "chalkduster")
        scoreLabel.position = CGPoint(x: 1000, y: 720)
        scoreLabel.zPosition = 1
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.text = "Score: 0"
        addChild(scoreLabel)
        
        gameOverLabel = SKLabelNode(fontNamed: "chalkduster")
        gameOverLabel.position = CGPoint(x: 512, y: 384)
        gameOverLabel.horizontalAlignmentMode = .center
        gameOverLabel.zPosition = 1
        gameOverLabel.text = "Game Over"
        gameOverLabel.fontSize = 48
        
        newGameLabel = SKLabelNode(fontNamed: "chalkduster")
        newGameLabel.position = CGPoint(x: 512, y: 334)
        newGameLabel.horizontalAlignmentMode = .center
        newGameLabel.zPosition = 1
        newGameLabel.text = "NEW GAME"
        newGameLabel.name = "newGame"
        newGameLabel.fontSize = 28
        
        startGame()
    }
    
    override func update(_ currentTime: TimeInterval) {
        for (index, firework) in fireworks.enumerated().reversed() {
            if firework.position.y > 900 {
                // this uses a position high above so that rockets can explode off screen
                fireworks.remove(at: index)
                firework.removeFromParent()
            }
        }
    }
    
    // MARK: - UIResponder
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        checkTouches(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        checkTouches(touches)
    }
    
    // MARK: - Public Methods
    
    func explodeFireworks() {
        var numExploded = 0
        
        for (index, fireworkContainer) in fireworks.enumerated().reversed() {
            guard let firework = fireworkContainer.children.first as? SKSpriteNode else { continue }
            
            if firework.name == "selected" {
                // destroy this firework
                explode(firework: fireworkContainer)
                fireworks.remove(at: index)
                numExploded += 1
            }
        }
        
        switch numExploded {
        case 0: break
        case 1: score += 200
        case 2: score += 500
        case 3: score += 1500
        case 4: score += 2500
        default: score += 4000
        }
    }
    
    // MARK: - Private Methods
    
    private func startGame() {
        score = 0
        launches = 0
        
        gameOverLabel.removeFromParent()
        newGameLabel.removeFromParent()
        
        gameTimer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(launchFireworks), userInfo: nil, repeats: true)
    }
    
    private func gameOver() {
        gameTimer?.invalidate()
        
        for firework in fireworks {
            firework.removeFromParent()
        }
        
        addChild(gameOverLabel)
        addChild(newGameLabel)
    }
    
    private func createFirework(xMovement: CGFloat, x: Int, y: Int) {
        // Create the firework container
        let node = SKNode()
        node.position = CGPoint(x: x, y: y)
        
        // Create the firework
        let firework = SKSpriteNode(imageNamed: "rocket")
        firework.colorBlendFactor = 1 // recolor sprites dynamically with absolutely no performance cost
        firework.name = "firework"
        node.addChild(firework)
        
        // Give the firework sprite node one of three random colors
        firework.color = switch Int.random(in: 0...2) {
        case 0: .cyan
        case 1: .green
        case 2: .red
        default: .white
        }
        
        // Create a UIBezierPath that will represent the movement of the firework
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: xMovement, y: 1000))
        
        // Tell the container node to follow that path, turning itself as needed
        node.run(SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: 200))
        
        // Create particles behind the rocket to make it look like the fireworks are lit
        if let emitter = SKEmitterNode(fileNamed: "fuse") {
            emitter.position = CGPoint(x: 0, y: -22)
            node.addChild(emitter)
        }
        
        // Add the firework to fireworks array and also to the scene
        fireworks.append(node)
        addChild(node)
    }
    
    private func checkTouches(_ touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        
        let nodesAtPoint = nodes(at: touch.location(in: self))
        
        for case let node as SKSpriteNode in nodesAtPoint {
            if node.name == "newGame" {
                startGame()
                return
            }
            
            guard node.name == "firework" else { continue }
            
            for parent in fireworks {
                guard let firework = parent.children.first as? SKSpriteNode else { continue }
                
                if firework.name == "selected" && firework.color != node.color {
                    firework.name = "firework"
                    firework.colorBlendFactor = 1
                }
            }
            
            node.name = "selected"
            node.colorBlendFactor = 0
        }
    }
    
    @objc
    private func launchFireworks() {
        let movementAmount: CGFloat = 1800
        
        launches += 1
        if launches >= maxLaunches {
            gameOver()
            return
        }
        
        switch Int.random(in: 0...3) {
        case 0:
            // straight up
            var x = 512 - 200
            for _ in 1...5 {
                createFirework(xMovement: 0, x: x, y: bottomEdge)
                x += 100
            }
        case 1:
            // in a fan
            var delta = -200
            for _ in 1...5 {
                createFirework(xMovement: CGFloat(delta), x: 512 + delta, y: bottomEdge)
                delta += 100
            }
        case 2:
            // from the left to the right
            var delta = 400
            for _ in 1...5 {
                createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + delta)
                delta -= 100
            }
        case 3:
            // from the right to the left
            var delta = 400
            for _ in 1...5 {
                createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + delta)
                delta -= 100
            }
        default: break
        }
    }
    
    private func explode(firework: SKNode) {
        if let emitter = SKEmitterNode(fileNamed: "explode") {
            emitter.position = firework.position
            addChild(emitter)
            
            emitter.run(SKAction.sequence([
                SKAction.wait(forDuration: 2),
                SKAction.run { emitter.removeFromParent() }
            ]))
        }
        
        firework.removeFromParent()
    }
}
