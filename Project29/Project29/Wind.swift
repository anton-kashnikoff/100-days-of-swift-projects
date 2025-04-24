import UIKit

struct Wind {
    enum HDirection {
        case left, right, none
    }
    
    enum VDirection {
        case up, down, none
    }
    
    enum Speed: CaseIterable {
        case slow, medium, fast
    }
    
    private var color: UIColor {
        if hDir == .none && vDir == .none {
            return .green
        }
        
        return switch speed {
        case .slow: .yellow
        case .medium: .orange
        case .fast: .red
        }
    }
    
    private var speedGravityModifier: Double {
        let speedModifier: Double = switch speed {
        case .slow: 1
        case .medium: 2
        case .fast: 3
        }

        // if wind blows diagonally, share the speed between each direction
        if hDir != .none && vDir != .none {
            return speedModifier / 2
        }

        return speedModifier
    }

    var letter: String
    var hDir: HDirection
    var vDir: VDirection
    var speed: Speed
    
    var text: NSAttributedString {
        let letterAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: color]
        let windAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.white]
        
        let firstString = NSMutableAttributedString(string: letter + letter + letter, attributes: letterAttributes)
        let secondString = NSAttributedString(string: " Wind ", attributes: windAttributes)
        let thirdString = NSAttributedString(string: letter + letter + letter, attributes: letterAttributes)

        firstString.append(secondString)
        firstString.append(thirdString)

        return firstString
    }
    
    private func getHorizontalGravity(player: Int, gravityModifier: Double) -> Double {
        var hGravity = Double()
        
        switch hDir {
        case .left:
            hGravity -= gravityModifier
        case .right:
            hGravity += gravityModifier
        case .none:
            break
        }
        
        return hGravity
    }
    
    private func getVerticalGravity(gravityModifier: Double) -> Double {
        var vGravity = -9.8
        
        switch vDir {
        case .up:
            vGravity += gravityModifier
        case .down:
            vGravity -= gravityModifier
        case .none:
            break
        }
        
        return vGravity
    }
    
    func getGravity(player: Int) -> CGVector {
        let gravityModifier = speedGravityModifier
        let hGravity = getHorizontalGravity(player: player, gravityModifier: gravityModifier)
        let vGravity = getVerticalGravity(gravityModifier: gravityModifier)
        
        return CGVector(dx: hGravity, dy: vGravity)
    }
}

extension Wind {
    static var randomWind: Wind {
        let speed = Speed.allCases.randomElement()!
        
        return [
            Wind(letter: "↑", hDir: .none, vDir: .up, speed: speed),
            Wind(letter: "↗", hDir: .right, vDir: .up, speed: speed),
            Wind(letter: "→", hDir: .right, vDir: .none, speed: speed),
            Wind(letter: "↘", hDir: .right, vDir: .down, speed: speed),
            Wind(letter: "↓", hDir: .none, vDir: .down, speed: speed),
            Wind(letter: "↙", hDir: .left, vDir: .down, speed: speed),
            Wind(letter: "←", hDir: .left, vDir: .none, speed: speed),
            Wind(letter: "↖", hDir: .left, vDir: .up, speed: speed),
            Wind(letter: "·", hDir: .none, vDir: .none, speed: speed),
        ].randomElement()!
    }
}
