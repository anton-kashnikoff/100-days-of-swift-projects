//
//  GameScene.swift
//  Project26
//
//  Created by Антон Кашников on 02/01/2025.
//

import SpriteKit

final class GameScene: SKScene {
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background.jpg")
        background.position = .init(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)

        loadLevel()
    }

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
}
