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

    private var player: SKSpriteNode!
    private var scoreLabel: SKLabelNode!
    private var motionManager: CMMotionManager!
    private var lastTouchPosition: CGPoint?
    private var isGameOver = false

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

        physicsWorld.contactDelegate = self
        physicsWorld.gravity = .zero

        loadLevel()
        createPlayer()

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
        lastTouchPosition = touch.location(in: self)
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
        guard let levelURL = Bundle.main.url(forResource: "level1", withExtension: "txt") else {
            fatalError("Could not find level1.txt in the app bundle.")
        }

        guard let levelString = try? String(contentsOf: levelURL) else {
            fatalError("Could not load level1.txt from the app bundle.")
        }

        let lines = levelString.components(separatedBy: .newlines)

        for (row, line) in lines.reversed().enumerated() {
            for (column, letter) in line.enumerated() {
                let position = CGPoint(x: 64 * column + 32, y: 64 * row + 32)

                switch letter {
                case "x":
                    // load wall
                    let blockNode = SKSpriteNode(imageNamed: "block")
                    blockNode.position = position
                    blockNode.physicsBody = .init(rectangleOf: blockNode.size)
                    blockNode.physicsBody?.categoryBitMask = CollisionTypes.wall.rawValue
                    blockNode.physicsBody?.isDynamic = false
                    addChild(blockNode)
                case "v":
                    // load vortex
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
                case "s":
                    // load star
                    let starNode = SKSpriteNode(imageNamed: "star")
                    starNode.name = "star"
                    starNode.physicsBody = .init(circleOfRadius: starNode.size.width / 2)
                    starNode.physicsBody?.isDynamic = false
                    starNode.physicsBody?.categoryBitMask = CollisionTypes.star.rawValue
                    starNode.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
                    starNode.physicsBody?.collisionBitMask = .zero
                    starNode.position = position
                    addChild(starNode)
                case "f":
                    // load finish
                    let finishNode = SKSpriteNode(imageNamed: "finish")
                    finishNode.name = "finish"
                    finishNode.physicsBody = .init(circleOfRadius: finishNode.size.width / 2)
                    finishNode.physicsBody?.isDynamic = false
                    finishNode.physicsBody?.categoryBitMask = CollisionTypes.finish.rawValue
                    finishNode.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
                    finishNode.physicsBody?.collisionBitMask = .zero
                    finishNode.position = position
                    addChild(finishNode)
                case " ":
                    // this is an empty space – do nothing!
                    break
                default:
                    fatalError("Unknown level letter: \(letter)")
                }
            }
        }
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
            // next level
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
