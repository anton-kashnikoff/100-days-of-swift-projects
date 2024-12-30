//
//  GameScene.swift
//  Project11
//
//  Created by Антон Кашников on 16.06.2023.
//

import SpriteKit

final class GameScene: SKScene, SKPhysicsContactDelegate {
    // MARK: - Visual Components
    private var scorelabel: SKLabelNode!
    private var editLabel: SKLabelNode!
    private var ballCountLabel: SKLabelNode!

    // MARK: - Private Properties
    private var score = 0 {
        didSet {
            scorelabel.text = "Score: \(score)"
        }
    }

    private var isEditingMode = false {
        didSet {
            editLabel.text = isEditingMode ? "Done" : "Edit"
        }
    }

    private var ballsCount = 5 {
        didSet {
            ballCountLabel.text = "Balls left: \(ballsCount)"
        }
    }

    private let ballColors = ["ballBlue", "ballCyan", "ballGreen", "ballGrey", "ballPurple", "ballRed", "ballYellow"]

    // MARK: - SKScene
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background.jpg")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)

        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self

        var slotX = 128
        var isGood = true
        for _ in 0...3 {
            makeSlot(at: CGPoint(x: slotX, y: 0), isGood: isGood)
            slotX += 256
            isGood.toggle()
        }

        var bouncerX = 0
        for _ in 0...4 {
            makeBouncer(at: CGPoint(x: bouncerX, y: 0))
            bouncerX += 256
        }

        makeEditLabel(at: CGPoint(x: 80, y: 700))
        makeScoreLabel(at: CGPoint(x: 980, y: 700))
        makeBallCountLabel(at: CGPoint(x: 780, y: 700))

        scene?.scaleMode = .aspectFit
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            var location = touch.location(in: self)

            let objects = nodes(at: location)
            if objects.contains(editLabel) {
                isEditingMode.toggle()
            } else {
                if isEditingMode {
                    makeBox(at: location)
                } else {
                    if location.y < 600 {
                        location.y = CGFloat(Int.random(in: 600...700))
                    }

                    if ballsCount > 0 {
                        makeBall(at: location)
                        ballsCount -= 1
                    }
                }
            }
        }
    }

    // MARK: - Public methods
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node, let nodeB = contact.bodyB.node else {
            return
        }

        if nodeA.name == "ball" {
            collisionBetween(ball: nodeA, object: nodeB)
        } else if nodeB.name == "ball" {
            collisionBetween(ball: nodeB, object: nodeA)
        }
    }

    // MARK: - Private Methods
    private func makeBall(at position: CGPoint) {
        let ball = SKSpriteNode(imageNamed: ballColors.randomElement() ?? "ballRed")
        ball.name = "ball"
        let size = CGSize(width: 64, height: 64)
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2)
        guard let ballPhysicsBody = ball.physicsBody else {
            return
        }
        ballPhysicsBody.contactTestBitMask = ballPhysicsBody.collisionBitMask
        ballPhysicsBody.restitution = 0.4
        ball.position = position
        addChild(ball)
    }

    private func makeBox(at position: CGPoint) {
        let box = SKSpriteNode(color: UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1), size: CGSize(width: Int.random(in: 16...128), height: 16))
        box.zRotation = CGFloat.random(in: 0...3)
        box.name = "box"
        box.position = position
        box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
        box.physicsBody?.isDynamic = false
        addChild(box)
    }

    private func makeScoreLabel(at position: CGPoint) {
        scorelabel = SKLabelNode(fontNamed: "Chalkduster")
        scorelabel.text = "Score: 0"
        scorelabel.horizontalAlignmentMode = .right
        scorelabel.position = position
        addChild(scorelabel)
    }

    private func makeEditLabel(at position: CGPoint) {
        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.text = "Edit"
        editLabel.position = position
        addChild(editLabel)
    }

    private func makeBallCountLabel(at position: CGPoint) {
        ballCountLabel = SKLabelNode(fontNamed: "Chalkduster")
        ballCountLabel.text = "Balls left: 5"
        ballCountLabel.horizontalAlignmentMode = .right
        ballCountLabel.position = position
        addChild(ballCountLabel)
    }

    private func makeBouncer(at position: CGPoint) {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2)
        bouncer.physicsBody?.isDynamic = false
        addChild(bouncer)
    }

    private func makeSlot(at position: CGPoint, isGood: Bool) {
        var slotBase: SKSpriteNode
        var slotGlow: SKSpriteNode

        if isGood {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotBase.name = "good"
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
        } else {
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotBase.name = "bad"
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
        }

        slotBase.position = position
        slotGlow.position = position

        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody?.isDynamic = false

        addChild(slotBase)
        addChild(slotGlow)

        slotGlow.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 10)))
    }

    private func collisionBetween(ball: SKNode, object: SKNode) {
        if object.name == "good" {
            score += 1
            ballsCount += 1
            destroy(ball: ball)
        } else if object.name == "bad" {
            score -= 1
            destroy(ball: ball)
        } else if object.name == "box" {
            object.removeFromParent()
        }
    }

    private func destroy(ball: SKNode) {
        if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
            fireParticles.position = ball.position
            addChild(fireParticles)
        }

        ball.removeFromParent()
    }
}
