//
//  GameScene.swift
//  Project23
//
//  Created by Антон Кашников on 09/10/2024.
//

import AVFoundation
import SpriteKit

final class GameScene: SKScene {
    // MARK: - Private Properties
    
    private let velocityMultiplier = 40
    private let angularVelocityRange: ClosedRange<CGFloat> = -3...3
    
    private var gameScoreLabel: SKLabelNode!
    private var score = 0 {
        didSet {
            gameScoreLabel.text = "Score: \(score)"
        }
    }
    
    private var livesImages = [SKSpriteNode]()
    private var lives = 3
    
    private var activeSliceBG: SKShapeNode!
    private var activeSliceFG: SKShapeNode!
    
    private var activeSlicePoints = [CGPoint]()
    private var isSwooshSoundActive = false
    private var activeEnemies = [SKSpriteNode]()
    private var bombSoundEffect: AVAudioPlayer?
    
    private var popupTime = 0.9 // the amount of time to wait between the last enemy being destroyed and a new one being created
    private var sequence = [SequenceType]() // what enemies to create
    private var sequencePosition = 0 // where we are right now in the game
    private var chainDelay: Double = 3 // how long to wait before creating a new enemy in chain
    private var nextSequenceQueued = true // used so we know when all the enemies are destroyed and we're ready to create more
    
    private var isGameEnded = false
    private var gameOverLabel: SKLabelNode!
    
    // MARK: - SKScene
    
    override func didMove(to view: SKView) {
        let backgroundNode = SKSpriteNode(imageNamed: "sliceBackground")
        backgroundNode.position = .init(x: 512, y: 384)
        backgroundNode.blendMode = .replace
        backgroundNode.zPosition = -1
        addChild(backgroundNode)
        
        startGame()
    }
    
    override func update(_ currentTime: TimeInterval) {
        if !activeEnemies.isEmpty {
            for (index, node) in activeEnemies.enumerated().reversed() {
                if node.position.y < -140 {
                    node.removeAllActions()
                    
                    if node.name == "enemy" {
                        node.name = .init()
                        subtractLife()
                        
                        node.removeFromParent()
                        activeEnemies.remove(at: index)
                    } else if node.name == "bombContainer" {
                        node.name = .init()
                        node.removeFromParent()
                        activeEnemies.remove(at: index)
                    }
                }
            }
        } else {
            if !nextSequenceQueued {
                DispatchQueue.main.asyncAfter(deadline: .now() + popupTime) { [weak self] in
                    self?.tossEnemies()
                }
                
                nextSequenceQueued = true
            }
        }
        
        var bombCount = 0
        
        for activeEnemy in activeEnemies {
            if activeEnemy.name == "bombContainer" {
                bombCount += 1
                break
            }
        }
        
        if bombCount == 0 {
            bombSoundEffect?.stop()
            bombSoundEffect = nil
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        activeSlicePoints.removeAll(keepingCapacity: true)
        activeSlicePoints.append(touch.location(in: self))
        redrawActiveSlice()
        
        activeSliceBG.removeAllActions()
        activeSliceFG.removeAllActions()
        
        activeSliceBG.alpha = 1
        activeSliceFG.alpha = 1
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGameEnded { return }
        
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        
        activeSlicePoints.append(location)
        redrawActiveSlice()
        
        if !isSwooshSoundActive {
            playSwooshSound()
        }
        
        for case let node as SKSpriteNode in nodes(at: location) {
            if node.name == "enemy" {
                // Create a particle effect over the penguin.
                if let emitterNode = SKEmitterNode(fileNamed: "sliceHitEnemy") {
                    emitterNode.position = node.position
                    addChild(emitterNode)
                }
                
                // Clear its node name so that it can't be swiped repeatedly.
                node.name = .init()
                
                // Disable the isDynamic of its physics body so that it doesn't carry on falling.
                node.physicsBody?.isDynamic = false
                
                // Make the penguin scale out and fade out at the same time.
                node.run(
                    .sequence(
                        [
                            .group(
                                [
                                    .scale(to: 0.001, duration: 0.2),
                                    .fadeOut(withDuration: 0.2)
                                ]
                            ),
                            .removeFromParent()
                        ]
                    )
                )
                
                score += 1
                
                if let index = activeEnemies.firstIndex(of: node) {
                    activeEnemies.remove(at: index)
                }
                
                run(.playSoundFileNamed("whack.caf", waitForCompletion: false))
            } else if node.name == "bomb" {
                guard let bombContainer = node.parent as? SKSpriteNode else { continue }
                
                if let emitterNode = SKEmitterNode(fileNamed: "sliceHitBomb") {
                    emitterNode.position = bombContainer.position
                    addChild(emitterNode)
                }
                
                node.name = .init()
                bombContainer.physicsBody?.isDynamic = false
                
                bombContainer.run(
                    .sequence(
                        [
                            .group(
                                [
                                    .scale(to: 0.001, duration: 0.2),
                                    .fadeOut(withDuration: 0.2)
                                ]
                            ),
                            .removeFromParent()
                        ]
                    )
                )
                
                if let index = activeEnemies.firstIndex(of: bombContainer) {
                    activeEnemies.remove(at: index)
                }
                
                run(.playSoundFileNamed("explosion.caf", waitForCompletion: false))
                endGame(triggeredByBomb: true)
            } else if node.name == "superPenguin" {
                if let emitterNode = SKEmitterNode(fileNamed: "sliceHitEnemy") {
                    emitterNode.position = node.position
                    addChild(emitterNode)
                }
                
                node.name = .init()
                node.physicsBody?.isDynamic = false
                node.run(
                    .sequence(
                        [
                            .group(
                                [
                                    .scale(to: 0.001, duration: 0.2),
                                    .fadeOut(withDuration: 0.2)
                                ]
                            ),
                            .removeFromParent()
                        ]
                    )
                )
                
                score += 5
                
                if let index = activeEnemies.firstIndex(of: node) {
                    activeEnemies.remove(at: index)
                }
                
                run(.playSoundFileNamed("whack.caf", waitForCompletion: false))
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        activeSliceBG.run(.fadeOut(withDuration: 0.25))
        activeSliceFG.run(.fadeOut(withDuration: 0.25))
    }
    
    // MARK: - Private Methods
    
    private func startGame() {
        isGameEnded = false
        
        isUserInteractionEnabled = true
        physicsWorld.gravity = .init(dx: 0, dy: -6)
        physicsWorld.speed = 0.85
        
        createScore()
        createLives()
        createSlices()
        
        sequence = [.oneNoBomb, .oneNoBomb, .twoWithOneBomb, .twoWithOneBomb, .three, .one, .chain]
        
        for _ in 0...1000 {
            if let nextSequence = SequenceType.allCases.randomElement() {
                sequence.append(nextSequence)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.tossEnemies()
        }
    }
    
    private func createScore() {
        gameScoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        gameScoreLabel.horizontalAlignmentMode = .left
        gameScoreLabel.fontSize = 48
        addChild(gameScoreLabel)
        
        gameScoreLabel.position = .init(x: 8, y: 8)
        score = 0
    }
    
    private func createLives() {
        for i in 0..<3 {
            let lifeNode = SKSpriteNode(imageNamed: "sliceLife")
            lifeNode.position = .init(x: 834 + (i * 70), y: 720)
            addChild(lifeNode)
            livesImages.append(lifeNode)
        }
    }
    
    private func createSlices() {
        activeSliceBG = .init()
        activeSliceBG.zPosition = 2
        activeSliceBG.strokeColor = .init(red: 1, green: 0.9, blue: 0, alpha: 1)
        activeSliceBG.lineWidth = 9
        
        activeSliceFG = .init()
        activeSliceFG.zPosition = 3
        activeSliceFG.strokeColor = .white
        activeSliceFG.lineWidth = 5
        
        addChild(activeSliceBG)
        addChild(activeSliceFG)
    }
    
    private func redrawActiveSlice() {
        if activeSlicePoints.count < 2 {
            activeSliceBG.path = nil
            activeSliceFG.path = nil
            return
        }
        
        if activeSlicePoints.count > 12 {
            activeSlicePoints.removeFirst(activeSlicePoints.count - 12)
        }
        
        let path = UIBezierPath()
        path.move(to: activeSlicePoints[0])
        
        for i in 1..<activeSlicePoints.count {
            path.addLine(to: activeSlicePoints[i])
        }
        
        activeSliceBG.path = path.cgPath
        activeSliceFG.path = path.cgPath
    }
    
    private func playSwooshSound() {
        isSwooshSoundActive = true
        
        run(.playSoundFileNamed("swoosh\(Int.random(in: 1...3)).caf", waitForCompletion: true)) { [weak self] in
            self?.isSwooshSoundActive = false
        }
    }
    
    private func createEnemy(forceBomb: ForceBomb = .random) {
        let enemy: SKSpriteNode
        
        let enemyType = switch forceBomb {
        case .never: 1
        case .always: 0
        case .random: Int.random(in: 0...6)
        }
        
        if enemyType == 0 {
            enemy = SKSpriteNode()
            enemy.name = "bombContainer"
            enemy.zPosition = 2
            
            let bombImage = SKSpriteNode(imageNamed: "sliceBomb")
            bombImage.name = "bomb"
            enemy.addChild(bombImage)
            
            if bombSoundEffect != nil {
                bombSoundEffect?.stop()
                bombSoundEffect = nil
            }
            
            if let path = Bundle.main.url(forResource: "sliceBombFuse", withExtension: "caf") {
                if let sound = try? AVAudioPlayer(contentsOf: path) {
                    bombSoundEffect = sound
                    sound.play()
                }
            }
            
            if let emitter = SKEmitterNode(fileNamed: "sliceFuse") {
                emitter.position = .init(x: 76, y: 64)
                enemy.addChild(emitter)
            }
        } else if enemyType == 2 {
            enemy = SKSpriteNode()
            enemy.name = "superPenguin"
            enemy.zPosition = 1
            
            let penguinImage = SKSpriteNode(imageNamed: "penguin")
            penguinImage.name = "penguin"
            enemy.addChild(penguinImage)
            
            if let emitter = SKEmitterNode(fileNamed: "sliceFuse") {
                emitter.position = .zero
                enemy.addChild(emitter)
            }
        } else {
            enemy = SKSpriteNode(imageNamed: "penguin")
            enemy.name = "enemy"
            run(.playSoundFileNamed("launch.caf", waitForCompletion: false))
        }
        
        let randomPosition = CGPoint(x: Int.random(in: 64...960), y: -128)
        let randomXVelocity: Int = if randomPosition.x < 256 {
            .random(in: 8...15)
        } else if randomPosition.x < 512 {
            .random(in: 3...5)
        } else if randomPosition.x < 768 {
            -.random(in: 3...5)
        } else {
            -.random(in: 8...15)
        }
        
        enemy.position = randomPosition
        
        enemy.physicsBody = .init(circleOfRadius: 64)
        enemy.physicsBody?.velocity = .init(
            dx: randomXVelocity * velocityMultiplier,
            dy: Int.random(in: 24...32) * velocityMultiplier
        )
        enemy.physicsBody?.angularVelocity = .random(in: angularVelocityRange)
        enemy.physicsBody?.collisionBitMask = .zero
        
        addChild(enemy)
        activeEnemies.append(enemy)
    }
    
    private func tossEnemies() {
        if isGameEnded { return }
        
        popupTime *= 0.991
        chainDelay *= 0.99
        physicsWorld.speed *= 1.02
        
        switch sequence[sequencePosition] {
        case .oneNoBomb:
            createEnemy(forceBomb: .never)
        case .one:
            createEnemy()
        case .twoWithOneBomb:
            createEnemy(forceBomb: .never)
            createEnemy(forceBomb: .always)
        case .two:
            for _ in 0..<2 { createEnemy() }
        case .three:
            for _ in 0..<3 { createEnemy() }
        case .four:
            for _ in 0..<4 { createEnemy() }
        case .chain:
            for i in 0...4 {
                DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5 * Double(i))) { [weak self] in
                    self?.createEnemy()
                }
            }
        case .fastChain:
            for i in 0...4 {
                DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10 * Double(i))) { [weak self] in
                    self?.createEnemy()
                }
            }
        }
        
        sequencePosition += 1
        nextSequenceQueued = false
    }
    
    private func subtractLife() {
        lives -= 1
        
        run(.playSoundFileNamed("wrong.caf", waitForCompletion: false))
        
        var life: SKSpriteNode
        
        if lives == 2 {
            life = livesImages[0]
        } else if lives == 1 {
            life = livesImages[1]
        } else {
            life = livesImages[2]
            endGame(triggeredByBomb: false)
        }
        
        life.texture = .init(imageNamed: "sliceLifeGone") // modify the contents of a sprite node without having to recreate it
        life.xScale = 1.3
        life.yScale = 1.3
        life.run(.scale(to: 1, duration: 0.1))
    }
    
    private func endGame(triggeredByBomb: Bool) {
        if isGameEnded { return }
        
        isGameEnded = true
        physicsWorld.speed = 0
        isUserInteractionEnabled = false
        
        bombSoundEffect?.stop()
        bombSoundEffect = nil
        
        gameOverLabel = SKLabelNode(fontNamed: "Chalkduster")
        gameOverLabel.text = "Game Over"
        gameOverLabel.fontSize = 48
        addChild(gameOverLabel)
        gameOverLabel.position = .init(x: 512, y: 384)
        
        if triggeredByBomb {
            for i in 0..<3 {
                livesImages[i].texture = .init(imageNamed: "sliceLifeGone")
            }
        }
        
        activeEnemies.forEach { enemy in
            enemy.removeFromParent()
        }
        activeEnemies.removeAll()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            guard let self else { return }
            
            self.gameOverLabel.removeFromParent()
            self.gameScoreLabel.removeFromParent()
            
            for i in 0..<3 {
                self.livesImages[i].removeFromParent()
            }
            self.livesImages.removeAll(keepingCapacity: true)
            
            self.startGame()
        }
    }
}
