//
//  PTLoadingViewController.swift
//  Pods-Sample
//
//  Created by 李二狗 on 2018/1/23.
//

import UIKit

open class PTLoadingViewController: UIViewController {

    @IBOutlet open weak var containerView: UIView!
    @IBOutlet open weak var infoLabel: UILabel!
    @IBOutlet open weak var activityIndicator: UIActivityIndicatorView!
    
    open private(set) var messageText: String? = nil
    
    public init(message: String?) {
        self.messageText = message
        super.init(nibName: "PTLoadingViewController", bundle: Bundle.init(for: type(of: self)))
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.messageText = ""
        super.init(coder: aDecoder)
    }
    
    open func changeMessage(_ message: String?) {
        self.messageText = message
        self.infoLabel.text = self.messageText
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clear
        self.containerView.backgroundColor = UIColor.white
        self.containerView.layer.cornerRadius = 5
        self.containerView.clipsToBounds = true
        self.activityIndicator.backgroundColor = UIColor.clear
        self.activityIndicator.color = UIColor.lightGray
        self.activityIndicator.startAnimating()
        self.infoLabel.text = self.messageText
    }

    deinit {
        self.activityIndicator.stopAnimating()
    }
}
