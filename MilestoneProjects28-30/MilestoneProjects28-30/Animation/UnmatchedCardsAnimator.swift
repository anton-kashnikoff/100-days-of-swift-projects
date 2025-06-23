import UIKit

final class UnmatchedCardsAnimator {
    // keyframes would be more convenient than chaining with completion handlers
    // but they don't play well with the flip animation, which is a transition

    private static let flipDuration = 0.3
    private static let waitDuration: TimeInterval = 1

    private var flipToFrontAnimator: UIViewPropertyAnimator?
    private var waiter: DispatchWorkItem?
    private var flipToBackAnimator: UIViewPropertyAnimator?

    func start(
        oldCell: CardCollectionViewCell,
        newCell: CardCollectionViewCell,
        completion: (() -> ())? = nil
    ) {
        flipToFront(oldCell: oldCell, newCell: newCell, completion: completion)
    }

    func cancel() {
        // could add a synchronization lock there
        waiter?.cancel()
        waiter = nil

        flipToFrontAnimator?.stopAnimation(true)
        flipToFrontAnimator = nil

        flipToBackAnimator?.stopAnimation(true)
        flipToBackAnimator = nil
    }

    func forceFlipToBack(
        oldCell: CardCollectionViewCell,
        newCell: CardCollectionViewCell
    ) {
        cancel()
        flipToBack(oldCell: oldCell, newCell: newCell)
    }

    private func flipToFront(
        oldCell: CardCollectionViewCell,
        newCell: CardCollectionViewCell,
        completion: (() -> ())? = nil
    ) {
        flipToFrontAnimator = UIViewPropertyAnimator(
            duration: UnmatchedCardsAnimator.flipDuration,
            timingParameters: UICubicTimingParameters()
        )

        flipToFrontAnimator?.addAnimations {
            newCell.animateFlipTo(state: .front)
        }

        flipToFrontAnimator?.addCompletion { [weak self] _ in
            self?.wait(oldCell: oldCell, newCell: newCell, completion: completion)
            self?.flipToFrontAnimator = nil
        }

        flipToFrontAnimator?.startAnimation()
    }

    private func wait(
        oldCell: CardCollectionViewCell,
        newCell: CardCollectionViewCell,
        completion: (() -> ())? = nil
    ) {
        waiter = DispatchWorkItem { [weak self] in
            self?.flipToBack(oldCell: oldCell, newCell: newCell, completion: completion)
            self?.waiter = nil
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + UnmatchedCardsAnimator.waitDuration, execute: waiter!)
    }

    private func flipToBack(
        oldCell: CardCollectionViewCell,
        newCell: CardCollectionViewCell,
        completion: (() -> ())? = nil
    ) {
        flipToBackAnimator = UIViewPropertyAnimator(
            duration: UnmatchedCardsAnimator.flipDuration,
            timingParameters: UICubicTimingParameters()
        )

        flipToBackAnimator?.addAnimations {
            oldCell.animateFlipTo(state: .back)
            newCell.animateFlipTo(state: .back)
        }

        flipToBackAnimator?.addCompletion { [weak self] position in
            self?.flipToBackAnimator = nil
            if position == .end {
                completion?()
            }
        }

        flipToBackAnimator?.startAnimation()
    }
}
