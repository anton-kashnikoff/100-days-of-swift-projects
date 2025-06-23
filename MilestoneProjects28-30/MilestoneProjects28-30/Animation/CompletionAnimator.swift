import UIKit

final class CompletionAnimator {
    static let betweenCardsDelay = 0.05
    static let completeDuration: TimeInterval = 2

    var animators = [UIViewPropertyAnimator]()
    var worker: DispatchWorkItem?

    func cancel() {
        worker?.cancel()

        animators.forEach { animator in
            animator.stopAnimation(true)
        }
   }

    func start(
        cards: [Card],
        collectionView: UICollectionView,
        completion: (() -> ())? = nil
    ) {
        complete(cards: cards, collectionView: collectionView)
    }

    func complete(cards: [Card], collectionView: UICollectionView) {
        worker = DispatchWorkItem { [weak self] in
            var delay = TimeInterval()

            for i in 0..<cards.count {
                // worker.cancel() does not cancel current task, do it ourselves
                if (self?.worker?.isCancelled ?? false) { return }

                guard let cell = collectionView.cellForItem(
                    at: IndexPath(
                        item: i,
                        section: .zero
                    )
                ) as? CardCollectionViewCell else {
                    continue
                }

                let springTiming = UISpringTimingParameters(
                    dampingRatio: 0.3,
                    initialVelocity: CGVector(dx: 5, dy: 5)
                )
                
                let animator = UIViewPropertyAnimator(
                    duration: MatchedCardsAnimator.matchDuration,
                    timingParameters: springTiming
                )

                animator.addAnimations {
                    cell.animateCompleteGame()
                }

                animator.addCompletion { [weak self] _ in
                    self?.animators.removeAll { $0 === animator }
                }

                self?.animators.append(animator)

                animator.startAnimation(afterDelay: delay)

                // 50ms to start animating each card with a delay
                delay += CompletionAnimator.betweenCardsDelay
            }
        }

        worker?.perform()
    }
}
