//
//  GameScene.swift
//  Project26
//
//  Created by Антон Кашников on 02/01/2025.
//

import CoreMotion
import SpriteKit

final class GameScene: SKScene {
    // MARK: - Private Properties
    
    private let maxLevel = 7

    private var player: SKSpriteNode!
    private var scoreLabel: SKLabelNode!
    private var restartGameLabel: SKLabelNode!
    private var restartLevelLabel: SKLabelNode!
    private var nextLevelLabel: SKLabelNode!
    private var currentLevelLabel: SKLabelNode!
    private var finishNode: SKSpriteNode!
    private var motionManager: CMMotionManager!
    private var lastTouchPosition: CGPoint?
    private var isGameOver = false
    
    private var currentLevel = 1 {
        didSet {
            currentLevelLabel.text = "Level: \(currentLevel)"
        }
    }

    private var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }

    // MARK: - SKScene

    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background.jpg")
        background.position = .init(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)

        scoreLabel = .init(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = .init(x: 16, y: 16)
        scoreLabel.zPosition = 2
        addChild(scoreLabel)

        currentLevelLabel = .init(fontNamed: "Chalkduster")
        currentLevelLabel.text = "Level: \(currentLevel)"
        currentLevelLabel.horizontalAlignmentMode = .left
        currentLevelLabel.position = .init(x: 16, y: 730)
        currentLevelLabel.zPosition = 2
        currentLevelLabel.name = "currentLevel"
        addChild(currentLevelLabel)

        physicsWorld.contactDelegate = self
        physicsWorld.gravity = .zero

        loadLevel()
        createPlayer()
        createFinishLabels()

        motionManager = .init()
        motionManager.startAccelerometerUpdates()
    }

    override func update(_ currentTime: TimeInterval) {
        guard !isGameOver else { return }

        #if targetEnvironment(simulator)
            if let currentTouch = lastTouchPosition {
                let diff = CGPoint(x: currentTouch.x - player.position.x, y: currentTouch.y - player.position.y)
                physicsWorld.gravity = .init(dx: diff.x / 100, dy: diff.y / 100)
            }
        #else
            if let accelerometerData = motionManager.accelerometerData {
                physicsWorld.gravity = .init(dx: accelerometerData.acceleration.y * -50, dy: accelerometerData.acceleration.x * 50)
            }
        #endif
    }

    // MARK: - UIResponder

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        lastTouchPosition = location

        nodes(at: location).forEach { node in
            switch node.name {
            case "nextLevel":
                currentLevel += 1
                if currentLevel >= maxLevel {
                    currentLevel = 1
                }
                restart()
            case "restartLevel":
                restart()
            case "restartGame":
                score = .zero
                currentLevel = 1
                restart()
            case "currentLevel":
                player.removeAllActions()
                player.physicsBody?.isDynamic = false
                addChild(nextLevelLabel)
                addChild(restartLevelLabel)
                addChild(restartGameLabel)
            default: break
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        lastTouchPosition = touch.location(in: self)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchPosition = nil
    }
    
    // MARK: - Private Methods

    private func loadLevel() {
        let name = "level\(currentLevel)"

        guard let levelURL = Bundle.main.url(forResource: name, withExtension: "txt") else {
            fatalError("Could not find \(name).txt in the app bundle.")
        }

        guard let levelString = try? String(contentsOf: levelURL) else {
            fatalError("Could not load \(name).txt from the app bundle.")
        }

        let lines = levelString.components(separatedBy: .newlines)

        for (row, line) in lines.reversed().enumerated() {
            for (column, letter) in line.enumerated() {
                let position = CGPoint(x: 64 * column + 32, y: 64 * row + 32)
                addElement(with: letter, to: position)
            }
        }
    }

    private func destroyLevel() {
        children.forEach { node in
            if ["wall", "vortex", "star", "finish", "portal"].contains(node.name) {
                node.removeFromParent()
            }
        }
        player.removeFromParent()
    }

    private func restart() {
        [finishNode, nextLevelLabel, restartLevelLabel, restartGameLabel].forEach {
            $0?.removeFromParent()
        }
        destroyLevel()
        loadLevel()
        createPlayer()
        isGameOver = false
    }

    private func addElement(with letter: Character, to position: CGPoint) {
        switch letter {
        case "x":
            addWall(to: position)
        case "v":
            addVortex(to: position)
        case "s":
            addStar(to: position)
        case "f":
            addFinish(to: position)
        case " ":
            // this is an empty space – do nothing!
            break
        default:
            fatalError("Unknown level letter: \(letter)")
        }
    }

    private func addWall(to position: CGPoint) {
        let blockNode = SKSpriteNode(imageNamed: "block")
        blockNode.position = position
        blockNode.physicsBody = .init(rectangleOf: blockNode.size)
        blockNode.physicsBody?.categoryBitMask = CollisionTypes.wall.rawValue
        blockNode.physicsBody?.isDynamic = false
        addChild(blockNode)
    }

    private func addVortex(to position: CGPoint) {
        let vortexNode = SKSpriteNode(imageNamed: "vortex")
        vortexNode.name = "vortex"
        vortexNode.position = position
        vortexNode.run(.repeatForever(.rotate(byAngle: .pi, duration: 1)))
        vortexNode.physicsBody = .init(circleOfRadius: vortexNode.size.width / 2)
        vortexNode.physicsBody?.isDynamic = false
        vortexNode.physicsBody?.categoryBitMask = CollisionTypes.vortex.rawValue
        vortexNode.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        vortexNode.physicsBody?.collisionBitMask = .zero
        addChild(vortexNode)
    }

    private func addStar(to position: CGPoint) {
        let starNode = SKSpriteNode(imageNamed: "star")
        starNode.name = "star"
        starNode.physicsBody = .init(circleOfRadius: starNode.size.width / 2)
        starNode.physicsBody?.isDynamic = false
        starNode.physicsBody?.categoryBitMask = CollisionTypes.star.rawValue
        starNode.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        starNode.physicsBody?.collisionBitMask = .zero
        starNode.position = position
        addChild(starNode)
    }

    private func addFinish(to position: CGPoint) {
        let finishNode = SKSpriteNode(imageNamed: "finish")
        finishNode.name = "finish"
        finishNode.physicsBody = .init(circleOfRadius: finishNode.size.width / 2)
        finishNode.physicsBody?.isDynamic = false
        finishNode.physicsBody?.categoryBitMask = CollisionTypes.finish.rawValue
        finishNode.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        finishNode.physicsBody?.collisionBitMask = .zero
        finishNode.position = position
        addChild(finishNode)
    }

    private func createPlayer() {
        player = .init(imageNamed: "player")
        player.position = .init(x: 96, y: 672)
        player.zPosition = 1
        player.physicsBody = .init(circleOfRadius: player.size.width / 2)
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.linearDamping = 0.5 // applies a lot of friction to its movement
        player.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        player.physicsBody?.contactTestBitMask = CollisionTypes.star.rawValue | CollisionTypes.vortex.rawValue | CollisionTypes.finish.rawValue
        player.physicsBody?.collisionBitMask = CollisionTypes.wall.rawValue
        addChild(player)
    }

    func createFinishLabels() {
        finishNode = .init(imageNamed: "finish")
        finishNode.position = .init(x: 512, y: 544)
        finishNode.zPosition = 2

        nextLevelLabel = .init(fontNamed: "Chalkduster")
        nextLevelLabel.text = "Next Level"
        nextLevelLabel.fontSize = 48
        nextLevelLabel.name = "nextLevel"
        nextLevelLabel.horizontalAlignmentMode = .center
        nextLevelLabel.position = .init(x: 512, y: 454)
        nextLevelLabel.zPosition = 2
        
        restartLevelLabel = .init(fontNamed: "Chalkduster")
        restartLevelLabel.text = "Restart Level"
        restartLevelLabel.fontSize = 48
        restartLevelLabel.name = "restartLevel"
        restartLevelLabel.horizontalAlignmentMode = .center
        restartLevelLabel.position = .init(x: 512, y: 384)
        restartLevelLabel.zPosition = 2
        
        restartGameLabel = .init(fontNamed: "Chalkduster")
        restartGameLabel.text = "Restart Game"
        restartGameLabel.fontSize = 48
        restartGameLabel.name = "restartGame"
        restartGameLabel.horizontalAlignmentMode = .center
        restartGameLabel.position = .init(x: 512, y: 314)
        restartGameLabel.zPosition = 2
    }

    private func playerCollided(with node: SKNode) {
        if node.name == "vortex" {
            player.physicsBody?.isDynamic = false
            isGameOver = true
            score -= 1

            player.run(
                .sequence([
                    .move(to: node.position, duration: 0.25),
                    .scale(to: 0.0001, duration: 0.25),
                    .removeFromParent()
                ])
            ) { [weak self] in
                self?.createPlayer()
                self?.isGameOver = false
            }
        } else if node.name == "star" {
            node.removeFromParent()
            score += 1
        } else if node.name == "finish" {
            player.physicsBody?.isDynamic = false
            [finishNode, nextLevelLabel, restartLevelLabel, restartGameLabel].forEach {
                addChild($0)
            }
        }
    }
}

// MARK: - SKPhysicsContactDelegate

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node, let nodeB = contact.bodyB.node else { return }
        
        if nodeA == player {
            playerCollided(with: nodeB)
        } else if nodeB == player {
            playerCollided(with: nodeA)
        }
    }
}
