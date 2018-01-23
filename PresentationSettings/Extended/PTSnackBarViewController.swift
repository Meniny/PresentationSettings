//
//  PTSnackBarViewController.swift
//  Pods-Sample
//
//  Created by 李二狗 on 2018/1/23.
//

import UIKit

public enum SafeAreaBottomPadding: CGFloat {
    case normal = 0
    case iPhoneX = 16
}

open class PTSnackBarViewController: UIViewController {

    @IBOutlet weak var containerBottomMarginConstraint: NSLayoutConstraint!
    @IBOutlet open weak var imageView: UIImageView!
    @IBOutlet open weak var containerView: UIView!
    @IBOutlet open weak var titleLabel: UILabel!
    @IBOutlet open weak var contentLabel: UILabel!
    
    open private(set) var image: UIImage?
    open private(set) var message: String
    open private(set) var informativeText: String?
    
    @IBOutlet weak var gestureView: UIView!
    
    open var backgroundColor: UIColor = UIColor.white
    open var messageTextColor: UIColor = UIColor.darkText
    open var informativeTextColor: UIColor = UIColor.lightGray
    
    public init(image: UIImage, message: String, informativeText: String?) {
        self.image = image
        self.message = message
        self.informativeText = informativeText
        super.init(nibName: "PTSnackBarViewController", bundle: Bundle.init(for: type(of: self)))
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.image = nil
        self.message = "Notification"
        self.informativeText = nil
        super.init(coder: aDecoder)
    }
    
    open private(set) var swipeGesture: UISwipeGestureRecognizer?
    open private(set) var tapGesture: UITapGestureRecognizer?
    
    open class var estimatedHeight: CGFloat {
        if UIApplication.iPhoneX {
            return SafeAreaBottomPadding.iPhoneX.rawValue + 80
        }
        return SafeAreaBottomPadding.normal.rawValue + 80
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
            self.containerBottomMarginConstraint.constant = SafeAreaBottomPadding.iPhoneX.rawValue + 8
        }
        
        self.tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(tap))
        if let tapG = self.tapGesture {
            self.gestureView.addGestureRecognizer(tapG)
        }
        
        self.swipeGesture = UISwipeGestureRecognizer.init(target: self, action: #selector(swipe))
        self.swipeGesture?.direction = .down
        if let swipeG = self.swipeGesture {
            self.containerView.addGestureRecognizer(swipeG)
        }
    }
    
    @objc
    open func tap() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc
    open func swipe() {
        self.dismiss(animated: true, completion: nil)
    }
    
    open lazy var snackSettings: PresentationSettings = {
        let settings = PresentationSettings.fullScreen
        settings.dismissOnTap = true
        settings.dismissOnSwipe = true
        settings.dismissOnSwipeDirection = .bottom
        return settings
    }()
    
    open func presented(by viewController: UIViewController, animated: Bool = true, completion: (() -> Void)?) {
        viewController.present(viewController: self, settings: self.snackSettings, animated: animated, completion: completion)
    }
}
