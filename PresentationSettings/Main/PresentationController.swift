
import UIKit

/// PresentationSettings's custom presentation controller. Handles the position and sizing for the view controller's.
class PresentationController: UIPresentationController, UIAdaptivePresentationControllerDelegate {
    
    /// Presentation type must be passed in to make all the sizing and position decisions.
    let presentationType: PresentationType

    /// Should the presented controller dismiss on background tap.
    let dismissOnTap: Bool
    
    /// Should the presented controller dismiss on background Swipe.
    let dismissOnSwipe: Bool
    var dismissSwipeLimit: CGFloat

    /// DismissSwipe direction
    let dismissOnSwipeDirection: DismissSwipeDirection
    
    /// Should the presented controller use animation when dismiss on background tap.
    let dismissAnimated: Bool

    /// How the presented view controller should respond in response to keyboard presentation.
    let keyboardTranslationType: KeyboardTranslationType

    /// The frame used for a current context presentation. If nil, normal presentation.
    let contextFrameForPresentation: CGRect?

    /// If contextFrameForPresentation is set, this handles what happens when tap outside context frame.
    let shouldIgnoreTapOutsideContext: Bool

    /// A custom background view to be added on top of the regular background view.
    private(set) var customBackgroundView: UIView?

    fileprivate var conformingPresentedController: PresentationSettingsDelegate? {
        return presentedViewController as? PresentationSettingsDelegate
    }

    fileprivate var shouldObserveKeyboard: Bool {
        let should = conformingPresentedController != nil ||
            (keyboardTranslationType != .none && presentationType == .popup) // TODO: Work w/other types?
        return should
    }

    fileprivate var containerFrame: CGRect {
        return contextFrameForPresentation ?? containerView?.bounds ?? CGRect()
    }

    fileprivate var keyboardIsShowing: Bool = false

    // MARK: Background Views

    fileprivate var chromeView = UIView()

    fileprivate var backgroundView = PassthroughBackgroundView()

    fileprivate var visualEffect: UIVisualEffect?

    // MARK: Swipe gesture

    fileprivate var presentedViewIsBeingDissmissed: Bool = false

    fileprivate var presentedViewFrame: CGRect = .zero

    fileprivate var presentedViewCenter: CGPoint = .zero

    fileprivate var latestShouldDismiss: Bool = true

    fileprivate lazy var shouldSwipeBottom: Bool = {
        return self.dismissOnSwipeDirection == .default ? self.presentationType != .topHalf : self.dismissOnSwipeDirection == .bottom
    }()

    fileprivate lazy var shouldSwipeTop: Bool = {
        return self.dismissOnSwipeDirection == .default ? self.presentationType == .topHalf : self.dismissOnSwipeDirection == .top
    }()

    // MARK: - Init

    init(presentedViewController: UIViewController,
         presentingViewController: UIViewController?,
         presentationType: PresentationType,
         roundCorners: Bool?,
         cornerRadius: CGFloat,
         dropShadow: PresentingShadow?,
         dismissOnTap: Bool,
         dismissOnSwipe: Bool,
         dismissOnSwipeDirection: DismissSwipeDirection,
         dismissSwipeLimit: CGFloat,
         background: PresentationBackground,
         keyboardTranslationType: KeyboardTranslationType,
         dismissAnimated: Bool,
         contextFrameForPresentation: CGRect?,
         shouldIgnoreTapOutsideContext: Bool) {

        self.presentationType = presentationType
        self.dismissOnTap = dismissOnTap
        self.dismissOnSwipe = dismissOnSwipe
        self.dismissOnSwipeDirection = dismissOnSwipeDirection
        self.keyboardTranslationType = keyboardTranslationType
        self.dismissAnimated = dismissAnimated
        self.dismissSwipeLimit = dismissSwipeLimit
        self.contextFrameForPresentation = contextFrameForPresentation
        self.shouldIgnoreTapOutsideContext = shouldIgnoreTapOutsideContext

        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        
        setupBackground(background)
        setupCornerRadius(roundCorners: roundCorners, cornerRadius: cornerRadius)
        addDropShadow(shadow: dropShadow)
        
        if dismissOnSwipe {
            setupDismissOnSwipe()
        }

        if shouldObserveKeyboard {
            registerKeyboardObserver()
        }
    }

    // MARK: - Setup

    private func setupDismissOnSwipe() {
        let swipe = UIPanGestureRecognizer(target: self, action: #selector(presentedViewSwipe))
        presentedViewController.view.addGestureRecognizer(swipe)
    }
    
    private func setupBackground(_ back: PresentationBackground) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(chromeViewTapped))
        chromeView.addGestureRecognizer(tap)

        if !shouldIgnoreTapOutsideContext {
            let tap = UITapGestureRecognizer(target: self, action: #selector(chromeViewTapped))
            backgroundView.addGestureRecognizer(tap)
        }

        switch back {
        case .blur(let style):
            visualEffect = UIBlurEffect(style: style)
            break
        case .color(let c, let a):
            chromeView.backgroundColor = c.withAlphaComponent(a)
            break
        case .view(let v):
            customBackgroundView = v
            break
        }
    }

    private func setupCornerRadius(roundCorners: Bool?, cornerRadius: CGFloat) {
        let shouldRoundCorners = roundCorners ?? presentationType.shouldRoundCorners
        if shouldRoundCorners {
            presentedViewController.view.layer.cornerRadius = cornerRadius
            presentedViewController.view.layer.masksToBounds = true
        } else {
            presentedViewController.view.layer.cornerRadius = 0
        }
    }
    
    private func addDropShadow(shadow: PresentingShadow?) {
        guard let shadow = shadow else {
            presentedViewController.view.layer.masksToBounds = true
            presentedViewController.view.layer.shadowOpacity = 0
            return
        }

        presentedViewController.view.layer.masksToBounds = false
        if let shadowColor = shadow.shadowColor?.cgColor {
            presentedViewController.view.layer.shadowColor = shadowColor
        }
        if let shadowOpacity = shadow.shadowOpacity {
            presentedViewController.view.layer.shadowOpacity = shadowOpacity
        }
        if let shadowOffset = shadow.shadowOffset {
            presentedViewController.view.layer.shadowOffset = shadowOffset
        }
        if let shadowRadius = shadow.shadowRadius {
            presentedViewController.view.layer.shadowRadius = shadowRadius
        }
    }
    
    fileprivate func registerKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(PresentationController.keyboardWasShown(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PresentationController.keyboardWillHide(notification:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    fileprivate func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }

}

// MARK: - UIPresentationController

extension PresentationController {
    
    // MARK: Presentation
    
    override var frameOfPresentedViewInContainerView: CGRect {
        var presentedViewFrame = CGRect.zero
        let containerBounds = containerFrame
        let size = self.size(forChildContentContainer: presentedViewController, withParentContainerSize: containerBounds.size)
        
        let origin: CGPoint
        // If the Presentation Type's calculate center point returns nil
        // this means that the user provided the origin, not a center point.
        if let center = getCenterPointFromType() {
            origin = calculateOrigin(center, size: size)
        } else {
            origin = getOriginFromType() ?? CGPoint(x: 0, y: 0)
        }
        
        presentedViewFrame.size = size
        presentedViewFrame.origin = origin

        return presentedViewFrame
    }
    
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        let width = getWidthFromType(parentSize)
        let height = getHeightFromType(parentSize)
        return CGSize(width: CGFloat(width), height: CGFloat(height))
    }
    
    override func containerViewWillLayoutSubviews() {
        guard !keyboardIsShowing else {
            return // prevent resetting of presented frame when the frame is being translated
        }
        chromeView.frame = containerFrame
        presentedView!.frame = frameOfPresentedViewInContainerView
    }
    
    // MARK: Animation
    
    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else {
            return
        }

        setupBackgroundView()

        backgroundView.frame = containerView.bounds
        chromeView.frame = containerFrame

        containerView.insertSubview(backgroundView, at: 0)
        containerView.insertSubview(chromeView, at: 1)

        if let customBackgroundView = customBackgroundView {
            chromeView.addSubview(customBackgroundView)
            customBackgroundView.frame = chromeView.bounds
            customBackgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }

        var blurEffectView: UIVisualEffectView?
        if visualEffect != nil {
            let view = UIVisualEffectView()
            view.frame = chromeView.bounds
            view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            chromeView.insertSubview(view, at: 0)
            blurEffectView = view
        } else {
            chromeView.alpha = 0.0
        }

        guard let coordinator = presentedViewController.transitionCoordinator else {
            chromeView.alpha = 1.0
            return
        }

        coordinator.animate(alongsideTransition: { context in
            blurEffectView?.effect = self.visualEffect
            self.chromeView.alpha = 1.0
        }, completion: nil)
    }
    
    override func dismissalTransitionWillBegin() {
        guard let coordinator = presentedViewController.transitionCoordinator else {
            chromeView.alpha = 0.0
            return
        }

        coordinator.animate(alongsideTransition: { context in
            self.chromeView.alpha = 0.0
        }, completion: nil)
    }

    // MARK: - Animation Helper's

    func setupBackgroundView() {
        if shouldIgnoreTapOutsideContext {
            backgroundView.shouldPassthrough = true
            backgroundView.passthroughViews = presentingViewController.view.subviews
        } else {
            backgroundView.shouldPassthrough = false
            backgroundView.passthroughViews = []
        }
    }

}

// MARK: - Sizing, Position

fileprivate extension PresentationController {

    func getWidthFromType(_ parentSize: CGSize) -> Float {
        guard let size = presentationType.size() else {
            if case .dynamic = presentationType {
                return Float(presentedViewController.view.systemLayoutSizeFitting(UILayoutFittingCompressedSize).width)
            }
            return 0
        }

        return size.width.calculateWidth(parentSize)
    }

    func getHeightFromType(_ parentSize: CGSize) -> Float {
        guard let size = presentationType.size() else {
            if case .dynamic = presentationType {
                return Float(presentedViewController.view.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height)
            }
            return 0
        }

        return size.height.calculateHeight(parentSize)
    }

    func getCenterPointFromType() -> CGPoint? {
        let containerBounds = containerFrame
        let position = presentationType.position()
        return position.calculateCenterPoint(containerBounds)
    }

    func getOriginFromType() -> CGPoint? {
        let position = presentationType.position()
        return position.calculateOrigin()
    }

    func calculateOrigin(_ center: CGPoint, size: CGSize) -> CGPoint {
        let x: CGFloat = center.x - size.width / 2
        let y: CGFloat = center.y - size.height / 2
        return CGPoint(x: x, y: y)
    }
    
}

// MARK: - Gesture Handling

extension PresentationController {

    @objc func chromeViewTapped(gesture: UIGestureRecognizer) {
        guard dismissOnTap else {
            return
        }

        guard conformingPresentedController?.presentedControllerShouldDismiss?(keyboardShowing: keyboardIsShowing) ?? true else {
            return
        }

        if gesture.state == .ended {
            if shouldObserveKeyboard {
                removeObservers()
            }
            presentingViewController.dismiss(animated: dismissAnimated, completion: nil)
        }
    }

    @objc func presentedViewSwipe(gesture: UIPanGestureRecognizer) {
        guard dismissOnSwipe else {
            return
        }

        if gesture.state == .began {
            presentedViewFrame = presentedViewController.view.frame
            presentedViewCenter = presentedViewController.view.center

            let directionDown = gesture.translation(in: presentedViewController.view).y > 0
            if (shouldSwipeBottom && directionDown) || (shouldSwipeTop && !directionDown) {
                latestShouldDismiss = conformingPresentedController?.presentedControllerShouldDismiss?(keyboardShowing: keyboardIsShowing) ?? true
            }
        } else if gesture.state == .changed {
            swipeGestureChanged(gesture: gesture)
        } else if gesture.state == .ended || gesture.state == .cancelled {
            swipeGestureEnded()
        }
    }



    // MARK: Helper's

    func swipeGestureChanged(gesture: UIPanGestureRecognizer) {
        let amount = gesture.translation(in: presentedViewController.view)

        if shouldSwipeTop && amount.y > 0 {
            return
        } else if shouldSwipeBottom && amount.y < 0 {
            return
        }

        var swipeLimit: CGFloat = dismissSwipeLimit
        if shouldSwipeTop {
            swipeLimit = -swipeLimit
        }

        presentedViewController.view.center = CGPoint(x: presentedViewCenter.x, y: presentedViewCenter.y + amount.y)

        let dismiss = shouldSwipeTop ? (amount.y < swipeLimit) : ( amount.y > swipeLimit)
        if dismiss && latestShouldDismiss {
            presentedViewIsBeingDissmissed = true
            presentedViewController.dismiss(animated: dismissAnimated, completion: nil)
        }
    }

    func swipeGestureEnded() {
        guard !presentedViewIsBeingDissmissed else {
            return
        }

        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 1,
                       options: [],
                       animations: {
            self.presentedViewController.view.frame = self.presentedViewFrame
        }, completion: nil)
    }

}

// MARK: - Keyboard Handling

extension PresentationController {

    @objc func keyboardWasShown(notification: Notification) {
        if let keyboardFrame = notification.keyboardEndFrame() {
            let presentedFrame = frameOfPresentedViewInContainerView
            let translatedFrame = keyboardTranslationType.getTranslationFrame(keyboardFrame: keyboardFrame, presentedFrame: presentedFrame)
            if translatedFrame != presentedFrame {
                UIView.animate(withDuration: notification.keyboardAnimationDuration() ?? 0.5, animations: {
                    self.presentedView?.frame = translatedFrame
                })
            }
            keyboardIsShowing = true
        }
    }

    @objc func keyboardWillHide (notification: Notification) {
        if keyboardIsShowing {
            let presentedFrame = frameOfPresentedViewInContainerView
            if self.presentedView?.frame !=  presentedFrame {
                UIView.animate(withDuration: notification.keyboardAnimationDuration() ?? 0.5, animations: {
                    self.presentedView?.frame = presentedFrame
                })
            }
            keyboardIsShowing = false
        }
    }

}
