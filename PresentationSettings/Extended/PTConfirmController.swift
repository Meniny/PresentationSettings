
import UIKit

public typealias AlertActionHandler = ((AlertAction) -> Void)

/// Describes each action that is going to be shown in the 'PTConfirmController'
public class AlertAction {

    public let title: String
    public let style: AlertActionStyle
    public let handler: AlertActionHandler?

    /**
     Initialized an 'AlertAction'

     - parameter title:   The title for the action, that will be used as the title for a button in the alert controller
     - parameter style:   The style for the action, that will be used to style a button in the alert controller.
     - parameter handler: The handler for the action, that will be called when the user clicks on a button in the alert controller.

     - returns: An inmutable AlertAction object
     */
    public init(title: String, style: AlertActionStyle, handler: AlertActionHandler?) {
        self.title = title
        self.style = style
        self.handler = handler
    }

}

/**
 Describes the style for an action, that will be used to style a button in the alert controller.

 - Default:     Green text label. Meant to draw attention to the action.
 - Cancel:      Gray text label. Meant to be neutral.
 - Destructive: Red text label. Meant to warn the user about the action.
 */
public enum AlertActionStyle {

    case `default`
    case cancel
    case destructive
    case custom(textColor: UIColor)

    /**
     Decides which color to use for each style

     - returns: UIColor representing the color for the current style
     */
    func color() -> UIColor {
        switch self {
        case .default:
            return ColorPalette.greenColor
        case .cancel:
            return ColorPalette.grayColor
        case .destructive:
            return ColorPalette.redColor
        case let .custom(color):
            return color
        }
    }

}

private struct ColorPalette {
    static let grayColor = UIColor(red: 151.0/255.0, green: 151.0/255.0, blue: 151.0/255.0, alpha: 1)
    static let greenColor = UIColor(red: 58.0/255.0, green: 213.0/255.0, blue: 91.0/255.0, alpha: 1)
    static let redColor = UIColor(red: 255.0/255.0, green: 103.0/255.0, blue: 100.0/255.0, alpha: 1)
}

/// UIViewController subclass that displays the alert
open class PTConfirmController: UIViewController {

    /// Text that will be used as the title for the alert
    open var titleText: String?

    /// Text that will be used as the body for the alert
    open var bodyText: String?

    /// If set to false, alert wont auto-dismiss the controller when an action is clicked. Dismissal will be up to the action's handler. Default is true.
    open var autoDismiss: Bool = true

    /// If autoDismiss is set to true, then set this property if you want the dismissal to be animated. Default is true.
    open var dismissAnimated: Bool = true

    fileprivate var actions = [AlertAction]()

    @IBOutlet open weak var titleLabel: UILabel!
    @IBOutlet open weak var bodyLabel: UILabel!
    @IBOutlet open weak var firstButton: UIButton!
    @IBOutlet open weak var secondButton: UIButton!
    @IBOutlet open weak var firstButtonWidthConstraint: NSLayoutConstraint!

    public convenience init() {
        self.init(nibName: "PTConfirmController", bundle: Bundle.init(for: type(of: self)))
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        if actions.isEmpty {
            let okAction = AlertAction(title: "Done", style: .default, handler: nil)
            addAction(okAction)
        }
        
        if actions.count == 1 {
            // If only one action, second button will have been removed from superview
            // So, need to add constraint for first button trailing to superview
            if let f = self.firstButtonWidthConstraint {
                self.view.removeConstraint(f)
            }
            //            let views: [String: UIView] = ["button" : firstButton]
            //            let constraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[button]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
            //            view.addConstraints(constraints)
            let constraint = NSLayoutConstraint.init(item: firstButton, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: 0)
            view.addConstraint(constraint)
            view.layoutIfNeeded()
        }
        
        setupFonts()
        setupLabels()
        setupButtons()
    }

    // MARK: AlertAction's

    /**
     Adds an 'AlertAction' to the alert controller. There can be maximum 2 actions. Any more will be ignored. The order is important.

     - parameter action: The 'AlertAction' to be added
     */
    open func addAction(_ action: AlertAction) {
        guard actions.count < 2 else { return }
        actions += [action]
    }

    // MARK: Setup

    fileprivate func setupFonts() {
        titleLabel.font = UIFont.systemFont(ofSize: 17)
        bodyLabel.font = UIFont.systemFont(ofSize: 14)
        firstButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        secondButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
    }

    fileprivate func setupLabels() {
        titleLabel.text = titleText ?? "Alert"
        bodyLabel.text = bodyText ?? "This is an alert."
    }

    fileprivate func setupButtons() {
        guard let firstAction = actions.first else { return }
        apply(firstAction, toButton: firstButton)
        if actions.count == 2 {
            let secondAction = actions.last!
            apply(secondAction, toButton: secondButton)
        } else {
            secondButton.removeFromSuperview()
        }
    }

    fileprivate func apply(_ action: AlertAction, toButton: UIButton) {
        let title = action.title.uppercased()
        let style = action.style
        toButton.setTitle(title, for: UIControlState())
        toButton.setTitleColor(style.color(), for: UIControlState())
    }

    // MARK: IBAction's

    @IBAction private func didSelectFirstAction(_ sender: AnyObject) {
        guard let firstAction = actions.first else { return }
        if let handler = firstAction.handler {
            handler(firstAction)
        }
        dismiss()
    }

    @IBAction private func didSelectSecondAction(_ sender: AnyObject) {
        guard let secondAction = actions.last, actions.count == 2 else { return }
        if let handler = secondAction.handler {
            handler(secondAction)
        }
        dismiss()
    }

    // MARK: Helper's

    open func dismiss() {
        guard autoDismiss else { return }
        self.dismiss(animated: dismissAnimated, completion: nil)
    }

}
