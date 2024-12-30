import PlaygroundSupport
import UIKit

extension UIView {
    func bounceOut(duration: TimeInterval) {
        Self.animate(withDuration: duration) { [unowned self] in
            self.transform = .init(scaleX: 0.0001, y: 0.0001)
        }
    }
}

let view = UIView(frame: .init(origin: .zero, size: .init(width: 350, height: 350)))
view.backgroundColor = .white

let label = UILabel()
label.font = .systemFont(ofSize: 38)
label.text = "ANIMATION"
label.translatesAutoresizingMaskIntoConstraints = false
label.textAlignment = .center
view.addSubview(label)

NSLayoutConstraint.activate([
    label.leadingAnchor.constraint(equalTo: view.leadingAnchor), label.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    label.topAnchor.constraint(equalTo: view.topAnchor), label.bottomAnchor.constraint(equalTo: view.bottomAnchor)
])

PlaygroundPage.current.liveView = view
label.bounceOut(duration: 3)


extension Int {
    func times(_ completion: @escaping () -> Void) {
        if self <= 0 { return }

        for _ in 0..<self {
            completion()
        }
    }
}

5.times { print("Hello!") }

extension Array where Element: Comparable {
    mutating func remove(item: Element) {
        if let index = firstIndex(of: item) {
            remove(at: index)
        }
    }
}

var numbers = [1, 2, 3, 4, 5]
numbers.remove(item: 3)
