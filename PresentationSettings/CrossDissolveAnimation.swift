
import Foundation

public class CrossDissolveAnimation: PresentingAnimation {

    override public func beforeAnimation(using transitionContext: PresentingTransitionContext) {
        transitionContext.animatingView?.alpha = transitionContext.isPresenting ? 0.0 : 1.0
    }

    override public func performAnimation(using transitionContext: PresentingTransitionContext) {
        transitionContext.animatingView?.alpha = transitionContext.isPresenting ? 1.0 : 0.0
    }

    override public func afterAnimation(using transitionContext: PresentingTransitionContext) {
        transitionContext.animatingView?.alpha = 1.0
    }

}
