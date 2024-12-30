//
//  GameScene.swift
//  MilestoneProjects16-18
//
//  Created by Антон Кашников on 08/01/2024.
//

import SpriteKit

class GameScene: SKScene {
    // MARK: - Private Properties
    
    private var scoreLabel: SKLabelNode!
    private var timerLabel: SKLabelNode!
    private var gameOverLabel: SKLabelNode!
    private var newGameLabel: SKLabelNode!
    
    private var waves = [WaveType: WaveNode]()
    private var durations = [WaveType: TimeInterval]()
    private var bullets: BulletsNode!
    
    private var fireSound: SKAction!
    private var emptyGunSound: SKAction!
    private var reloadSound: SKAction!
    private var alarmSound: SKAction!
    
    private var duckTimer: Timer?
    private var gameTimer: Timer?
    
    private var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    private var timer  = 60 {
        didSet {
            timerLabel.text = "\(timer)s"
        }
    }
    
    // MARK: - SKScene
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "Background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.position = CGPoint(x: 8, y: 720)
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.fontSize = 48
        addChild(scoreLabel)
        
        timerLabel = SKLabelNode(fontNamed: "Chalkduster")
        timerLabel.text = "60s"
        timerLabel.position = CGPoint(x: 552, y: 720)
        timerLabel.horizontalAlignmentMode = .right
        timerLabel.fontSize = 48
        addChild(timerLabel)
        
        gameOverLabel = SKLabelNode(fontNamed: "Chalkduster")
        gameOverLabel.text = "Game Over"
        gameOverLabel.position = CGPoint(x: 512, y: 384)
        gameOverLabel.horizontalAlignmentMode = .center
        gameOverLabel.fontSize = 68
        gameOverLabel.zPosition = 1
        
        newGameLabel = SKLabelNode(fontNamed: "Chalkduster")
        newGameLabel.text = "New Game"
        newGameLabel.position = CGPoint(x: 512, y: 324)
        newGameLabel.horizontalAlignmentMode = .center
        newGameLabel.name = "newGame"
        newGameLabel.fontSize = 38
        newGameLabel.zPosition = 1
        
        waves[.top] = addWave(at: CGPoint(x: -82, y: 350), zPosition: 0, xScale: 1, direction: .right)
        waves[.center] = addWave(at: CGPoint(x: -82, y: 200), zPosition: 0.2, xScale: 0.75, direction: .left)
        waves[.bottom] = addWave(at: CGPoint(x: -82, y: 50), zPosition: 0.4, xScale: 0.5, direction: .right)
        
        bullets = BulletsNode()
        bullets.configure(at: CGPoint(x: 875, y: 735))
        bullets.name = "bullets"
        addChild(bullets)
        
        physicsWorld.gravity = .zero
        
        fireSound = SKAction.playSoundFileNamed("fire-sound.caf", waitForCompletion: false)
        emptyGunSound = SKAction.playSoundFileNamed("empty-gun-sound.caf", waitForCompletion: false)
        reloadSound = SKAction.playSoundFileNamed("reload-sound.caf", waitForCompletion: false)
        alarmSound = SKAction.playSoundFileNamed("alarm-sound.caf", waitForCompletion: false)
        
        startGame()
    }
    
    // MARK: - Private Properties
    
    private func startGame() {
        score = 0
        timer = 60
        
        durations[.bottom] = 6
        durations[.center] = 5
        durations[.top] = 4
        
        bullets.reload()
        
        gameOverLabel.removeFromParent()
        newGameLabel.removeFromParent()
        
        gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(decreaseTimer), userInfo: nil, repeats: true)
        duckTimer = Timer.scheduledTimer(timeInterval: 0.75, target: self, selector: #selector(generateDucks), userInfo: nil, repeats: true)
    }
    
    private func gameOver() {
        duckTimer?.invalidate()
        gameTimer?.invalidate()
        
        addChild(gameOverLabel)
        addChild(newGameLabel)
    }
    
    private func addWave(at position: CGPoint, zPosition: CGFloat, xScale: CGFloat, direction: WaveDirection) -> WaveNode {
        let wave = WaveNode()
        wave.configure(at: position, xScale: xScale, direction: direction)
        wave.zPosition = zPosition
        addChild(wave)
        wave.animate()
        return wave
    }
    
    private func addDuck(wave: WaveNode, scale: CGFloat, duration: TimeInterval, points: Int) {
        let duck = DuckNode()
        let duckType: DuckType
        
        var actualPoints = points
        
        // 4/5 chances of a good duck
        if Int.random(in: 1...5) <= 4 {
            duckType = .good
        } else {
            duckType = .bad
            actualPoints -= 1000
        }
        
        var xScale = scale * (1 / wave.xScale)
        let yScale = scale
        
        let startingPoint = wave.childrenStartingPoint
        let movement = wave.childrenMovement
        
        if wave.direction == .left {
            // reverse duck image
            xScale = -xScale
        }
        
        duck.configure(at: CGPoint(x: startingPoint, y: 100), type: duckType, points: actualPoints, xScale: xScale, yScale: yScale)
        
        // put duck behind the wave it belongs to
        duck.zPosition = -0.1
        duck.name = "duck"
        wave.addChild(duck)
        
        // animate duck
        duck.run(SKAction.sequence([
            SKAction.move(by: CGVector(dx: movement, dy: 0), duration: duration),
            SKAction.customAction(withDuration: 1) { duck, _ in
                duck.removeFromParent()
            }
        ]))
    }
    
    @objc
    private func decreaseTimer() {
        timer -= 1
        
        if timer == 4 { run(alarmSound) }
        if timer <= 0 { gameOver() }
    }
    
    @objc
    private func generateDucks() {
        // 3/5 chances to generate a duck
        if Int.random(in: 1...5) <= 3 {
            guard let bottomWave = waves[.bottom], let bottomDuration = durations[.bottom] else { return }
            addDuck(wave: bottomWave, scale: 1, duration: bottomDuration, points: 100)
        }
        
        if Int.random(in: 1...5) <= 3 {
            guard let centerWave = waves[.center], let centerDuration = durations[.center] else { return }
            addDuck(wave: centerWave, scale: 0.75, duration: centerDuration, points: 200)
        }
        
        if Int.random(in: 1...5) <= 3 {
            guard let topWave = waves[.top], let topDuration = durations[.top] else { return }
            addDuck(wave: topWave, scale: 0.5, duration: topDuration, points: 300)
        }
        
        durations[.bottom]? *= 0.996
        durations[.center]? *= 0.996
        durations[.top]? *= 0.996
    }
    
    private func showReload() {
        let reloadLabel = SKLabelNode(fontNamed: "Chalkduster")
        reloadLabel.text = "RELOAD"
        reloadLabel.position = CGPoint(x: 512, y: 384)
        reloadLabel.horizontalAlignmentMode = .center
        reloadLabel.fontSize = 80
        reloadLabel.fontColor = .red
        reloadLabel.zPosition = 1
        addChild(reloadLabel)
        
        reloadLabel.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.customAction(withDuration: 0) { reloadLabel, _ in
                reloadLabel.removeFromParent()
            }
        ]))
    }
    
    private func showTappedScore(score: Int, position: CGPoint) {
        var scoreText = ""
        var textColor: UIColor!
        var outlineColor: UIColor!
        
        if score > 0 {
            scoreText += "+"
            textColor = UIColor(red: 0, green: 0.7, blue: 0, alpha: 1)
            outlineColor = .green
        } else {
            textColor = UIColor(red: 0.7, green: 0, blue: 0, alpha: 1)
            outlineColor = UIColor(red: 1, green: 0.45, blue: 0.45, alpha: 1)
        }
        scoreText += String(score)
        
        let scoreLabel = SKLabelNode()
        scoreLabel.horizontalAlignmentMode = .center
        scoreLabel.position = position
        scoreLabel.zPosition = 1
        scoreLabel.attributedText = getAttributedText(for: scoreText, textColor: textColor, outlineColor: outlineColor)
        addChild(scoreLabel)
        
        scoreLabel.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 1),
            SKAction.customAction(withDuration: 1) { scoreLabel, _ in
                scoreLabel.removeFromParent()
            }
        ]))
    }
    
    private func getAttributedText(for text: String, textColor: UIColor, outlineColor: UIColor) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: text)
        let range = NSMakeRange(0, attributedString.length)
        attributedString.addAttribute(.font, value: UIFont(name: "Chalkduster", size: 38) as Any, range: range)
        attributedString.addAttribute(.foregroundColor, value: textColor as Any, range: range)
        attributedString.addAttribute(.strokeColor, value: outlineColor as Any, range: range)
        attributedString.addAttribute(.strokeWidth, value: -3, range: range)
        return attributedString
    }
    
    // MARK: - UIResponder
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        
        var duckTapped = false
        
        for tappedNode in tappedNodes {
            if tappedNode.name == "newGame" {
                startGame()
                return
            }
            
            //game is on
            if timer > 0 {
                if tappedNode.name == "duck" {
                    duckTapped = true
                    
                    // check bullets
                    if !bullets.remains() {
                        showReload()
                        return
                    }
                    bullets.decrease()
                    
                    // duck successfully tapped
                    if let duck = tappedNode as? DuckNode {
                        score += duck.points
                        showTappedScore(score: duck.points, position: location)
                    }
                    
                    tappedNode.removeFromParent()
                    
                    run(fireSound)
                    
                    // sometimes multiple ducks are tapped, count the first one only
                    break
                }
                
                // reload bullets tapped
                if tappedNode.name == "bullets" {
                    bullets.reload()
                    run(reloadSound)
                    return
                }
                
            }
        }
        
        // game is on and tapped elsewhere than on a duck
        if timer > 0 && !duckTapped {
            if !bullets.remains() {
                showReload()
                return
            }
            bullets.decrease()
            
            score -= 50
            showTappedScore(score: -50, position: location)
            
            run(fireSound)
        }
    }
}
