import UIKit

final class FlipCardAnimator {
    static let flipDuration = 0.3

    // store those to make current animation cancellable
    var flipAnimator: UIViewPropertyAnimator?

    func cancel() {
        flipAnimator?.stopAnimation(true)
        flipAnimator = nil
    }

    func flipTo(state: CardState, cell: CardCollectionViewCell) {
        flipAnimator = UIViewPropertyAnimator(
            duration: FlipCardAnimator.flipDuration,
            curve: .linear
        )

        flipAnimator?.addAnimations {
            cell.animateFlipTo(state: state)
        }

        flipAnimator?.addCompletion { [weak self] _ in
            self?.flipAnimator = nil
        }

        flipAnimator?.startAnimation()
    }
}
