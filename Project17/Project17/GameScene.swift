//
//  GameScene.swift
//  Project17
//
//  Created by Антон Кашников on 19/12/2023.
//

import SpriteKit

class GameScene: SKScene {
    // MARK: - Private properties

    private let possibleEnemies = ["ball", "hammer", "tv"]
    
    private var isPlayerTouched = false
    private var isGameOver = false
    private var gameTimer: Timer?
    private var timeInterval: Double = 1
    private var numberOfEnemies = 0
    
    private var starfield: SKEmitterNode!
    private var player: SKSpriteNode!
    private var scoreLabel: SKLabelNode!
    private var gameOverLabel: SKLabelNode?
    private var newGameLabel: SKLabelNode?
    
    private var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        starfield = SKEmitterNode(fileNamed: "starfield")!
        starfield.position = CGPoint(x: 1024, y: 384)
        starfield.advanceSimulationTime(10) // simulate 10 seconds passing in the emitter, thus updating all the particles as if they were created 10 seconds ago
        addChild(starfield)
        starfield.zPosition = -1
        
        player = SKSpriteNode(imageNamed: "player")
        player.name = "player"
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size) // per-pixel collision detection
        player.physicsBody?.contactTestBitMask = 1
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
        score = 0
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        startNewGame()
    }
    
    override func update(_ currentTime: TimeInterval) {
        for node in children {
            if node.position.x <= -300 { node.removeFromParent() }
        }
        
        if !isGameOver { score += 1 }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isPlayerTouched {
            guard let touch = touches.first else { return }

            var location = touch.location(in: self)
        
            if location.y < 100 { location.y = 100 }
            else if location.y > 668 { location.y = 668 }
            
            player.position = location
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        
        for node in nodes(at: location) {
            if node.name == "player" {
                isPlayerTouched = true
            } else if node.name == "NewGame" {
                startNewGame()
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        
        for node in nodes(at: location) {
            if node.name == "player" {
                isPlayerTouched = false
            }
        }
    }
    
    private func startNewGame() {
        score = 0
        numberOfEnemies = 0
        timeInterval = 1
        isGameOver = false
        
        if let gameOverLabel, let newGameLabel {
            gameOverLabel.removeFromParent()
            newGameLabel.removeFromParent()
        }
        
        for node in children {
            if node.name == "Enemy" {
                node.removeFromParent()
            }
        }
        
        player.position = CGPoint(x: 100, y: 384)
        addChild(player)

        // The scheduledTimer() timer not only creates a timer, but also starts it immediately.
        // it will create about three enemies a second
        gameTimer = Timer.scheduledTimer(
            timeInterval: timeInterval, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true
        )
    }
    
    private func endGame() {
        let explosion = SKEmitterNode(fileNamed: "explosion")!
        explosion.position = player.position
        addChild(explosion)
        
        player.removeFromParent()
        
        isGameOver = true
        gameTimer?.invalidate()
        
        gameOverLabel = SKLabelNode(fontNamed: "Chalkduster")
        gameOverLabel?.position = CGPoint(x: 512, y: 384)
        gameOverLabel?.zPosition = 1
        gameOverLabel?.fontSize = 48
        gameOverLabel?.horizontalAlignmentMode = .center
        gameOverLabel?.text = "GAME OVER"
        addChild(gameOverLabel!)

        newGameLabel = SKLabelNode(fontNamed: "Chalkduster")
        newGameLabel?.position = CGPoint(x: 512, y: 324)
        newGameLabel?.zPosition = 1
        newGameLabel?.fontSize = 32
        newGameLabel?.horizontalAlignmentMode = .center
        newGameLabel?.text = "New Game"
        newGameLabel?.name = "NewGame"
        addChild(newGameLabel!)
    }
    
    @objc
    private func createEnemy() {
        numberOfEnemies += 1
        
        guard let enemyName = possibleEnemies.randomElement() else { return }
        
        let spriteNode = SKSpriteNode(imageNamed: enemyName)
        spriteNode.position = CGPoint(x: 1200, y: Int.random(in: 50...736))
        spriteNode.name = "Enemy"
        addChild(spriteNode)
        
        spriteNode.physicsBody = SKPhysicsBody(texture: spriteNode.texture!, size: spriteNode.size)
        spriteNode.physicsBody?.categoryBitMask = 1
        spriteNode.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        spriteNode.physicsBody?.angularVelocity = 5
        
        // its movement and rotation will never slow down over time
        spriteNode.physicsBody?.linearDamping = 0
        spriteNode.physicsBody?.angularDamping = 0
        
        if numberOfEnemies >= 20 {
            if timeInterval >= 0.1 {
                timeInterval -= 0.1
            }
            
            gameTimer?.invalidate()
            gameTimer = Timer.scheduledTimer(
                timeInterval: timeInterval, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true
            )
            
            numberOfEnemies = 0
        }
    }
}

// MARK: - SKPhysicsContactDelegate

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        endGame()
    }
}
