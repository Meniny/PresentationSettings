//
//  PTNotificationViewController.swift
//  Pods-Sample
//
//  Created by 李二狗 on 2018/1/23.
//

import UIKit

public enum StatusBarHeight: CGFloat {
    case normal = 20
    case iPhoneX = 44
}

open class PTNotificationViewController: UIViewController {
    @IBOutlet weak var containerTopMarginConstraint: NSLayoutConstraint!
    @IBOutlet open weak var imageView: UIImageView!
    @IBOutlet open weak var containerView: UIView!
    @IBOutlet open weak var titleLabel: UILabel!
    @IBOutlet open weak var contentLabel: UILabel!
    
    open private(set) var image: UIImage?
    open private(set) var message: String
    open private(set) var informativeText: String?
    
    open var backgroundColor: UIColor = UIColor.white
    open var messageTextColor: UIColor = UIColor.darkText
    open var informativeTextColor: UIColor = UIColor.lightGray
    
    public init(image: UIImage, message: String, informativeText: String?) {
        self.image = image
        self.message = message
        self.informativeText = informativeText
        super.init(nibName: "PTNotificationViewController", bundle: Bundle.init(for: type(of: self)))
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.image = nil
        self.message = "Notification"
        self.informativeText = nil
        super.init(coder: aDecoder)
    }
    
    open private(set) var swipeGesture: UISwipeGestureRecognizer?
    
    open class var estimatedHeight: CGFloat {
        if UIApplication.iPhoneX {
            return StatusBarHeight.iPhoneX.rawValue + 80
        }
        return StatusBarHeight.normal.rawValue + 80
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imageView.image = self.image
        self.titleLabel.text = self.message
        self.contentLabel.text = self.informativeText
        
        self.imageView.layer.cornerRadius = 3
        self.imageView.clipsToBounds = true
        
        self.containerView.backgroundColor = self.backgroundColor
        self.titleLabel.textColor = self.messageTextColor
        self.contentLabel.textColor = self.informativeTextColor
        
        if UIApplication.iPhoneX {
            self.containerTopMarginConstraint.constant = StatusBarHeight.iPhoneX.rawValue + 8
        }
        
        self.swipeGesture = UISwipeGestureRecognizer.init(target: self, action: #selector(swipe))
        self.swipeGesture?.direction = .up
        if let swipeG = self.swipeGesture {
            self.containerView.addGestureRecognizer(swipeG)
        }
    }
    
    @objc
    open func swipe() {
        self.dismiss(animated: true, completion: nil)
    }
    
    open lazy var notificationSettings: PresentationSettings = {
        let height = PTNotificationViewController.estimatedHeight
        let presentationType = PresentationType.custom(width: .fluid(percentage: 1), height: .custom(size: Float(height)), center: .customOrigin(origin: .zero))
        let settings = PresentationSettings.init(presentationType: presentationType)
        settings.dismissOnTap = true
        settings.dismissOnSwipe = true
        settings.dismissOnSwipeDirection = .top
        settings.transitionType = TransitionType.coverVerticalFromTop
        settings.dismissAnimated = true
        settings.dismissTransitionType = TransitionType.coverVerticalFromTop
        return settings
    }()
    
    open func presented(by viewController: UIViewController, animated: Bool = true, completion: (() -> Void)?) {
        viewController.present(viewController: self, settings: self.notificationSettings, animated: animated, completion: completion)
    }

}
