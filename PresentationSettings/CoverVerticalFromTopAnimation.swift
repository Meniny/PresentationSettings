
import Foundation

public class CoverVerticalFromTopAnimation: PresentingAnimation {

    override public func transform(containerFrame: CGRect, finalFrame: CGRect) -> CGRect {
        var initialFrame = finalFrame
        initialFrame.origin.y = 0 - initialFrame.size.height
        return initialFrame
    }

}
