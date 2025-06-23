import UIKit

final class MatchedCardsAnimator {
    // keyframes would be more convenient than chaining with completion handlers
    // but they don't play well with the flip animation, which is a transition

    static let flipDuration = 0.3
    static let matchDuration: TimeInterval = 2

    var flipToFrontAnimator: UIViewPropertyAnimator?
    var matchAnimator: UIViewPropertyAnimator?

    func cancel() {
        // could add a synchronization lock there
        flipToFrontAnimator?.stopAnimation(true)
        flipToFrontAnimator = nil

        matchAnimator?.stopAnimation(true)
        matchAnimator = nil
    }

    func start(
        oldCell: CardCollectionViewCell,
        newCell: CardCollectionViewCell,
        completion: (() -> ())? = nil
    ) {
        flipToFront(oldCell: oldCell, newCell: newCell, completion: completion)
    }

    private func flipToFront(
        oldCell: CardCollectionViewCell,
        newCell: CardCollectionViewCell,
        completion: (() -> ())? = nil
    ) {
        flipToFrontAnimator = UIViewPropertyAnimator(
            duration: MatchedCardsAnimator.flipDuration,
            curve: .linear
        )

        flipToFrontAnimator?.addAnimations {
            newCell.animateFlipTo(state: .front)
        }

        flipToFrontAnimator?.addCompletion { [weak self] _ in
            self?.match(oldCell: oldCell, newCell: newCell, completion: completion)
            self?.flipToFrontAnimator = nil
        }

        flipToFrontAnimator?.startAnimation()
    }

    private func match(
        oldCell: CardCollectionViewCell,
        newCell: CardCollectionViewCell,
        completion: (() -> ())? = nil
    ) {
        let springTiming = UISpringTimingParameters(
            dampingRatio: 0.3,
            initialVelocity: CGVector(dx: 5, dy: 5)
        )
        
        matchAnimator = UIViewPropertyAnimator(
            duration: MatchedCardsAnimator.matchDuration,
            timingParameters: springTiming
        )

        matchAnimator?.addAnimations {
            oldCell.animateMatch()
            newCell.animateMatch()
        }

        matchAnimator?.addCompletion { [weak self] _ in
            self?.matchAnimator = nil
            completion?()
        }

        matchAnimator?.startAnimation()
    }
}
