//
//  ViewController.swift
//  Sample
//
//  Created by Meniny on 2018-01-22.
//  Copyright © 2018年 Meniny. All rights reserved.
//

import UIKit
import PresentationSettings

public enum CellData: String {
    case confirm = "Confirm Alert"
    case loading = "Loading"
    case notification = "Notification"
    case snackBar = "Snack bar"
    case custom = "Custom View Controller"
    
    public var selector: Selector {
        switch self {
        case .confirm:
            return #selector(ViewController.showAlert)
        case .notification:
            return #selector(ViewController.showNotification)
        case .snackBar:
            return #selector(ViewController.showSnackBar)
        case .loading:
            return #selector(ViewController.showLoading)
        case .custom:
            return #selector(ViewController.showCustom)
        }
    }
}

class ViewController: UITableViewController {

    let cells: [CellData] = [
        .confirm,
        .loading,
        .notification,
        .snackBar,
        .custom
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.tableView.tableFooterView = UIView.init()
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    @objc
    func showAlert() {
        let alert = PTConfirmController.init()
        alert.addAction(AlertAction.init(title: "Done", style: .default, handler: nil))
        alert.addAction(AlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        present(viewController: alert, settings: .default, animated: true, completion: nil)
    }
    
    @objc
    func showNotification() {
        let noti = PTNotificationViewController.init(image: UIImage.init(named: "Doggie")!, message: "Warning!", informativeText: "Hands up!\nYour are under attack!")
        noti.backgroundColor = UIColor.init(white: 0, alpha: 0.7)
        noti.messageTextColor = UIColor.white
        noti.informativeTextColor = UIColor.lightText
        noti.presented(by: self, animated: true, completion: nil)
    }
    
    @objc
    func showSnackBar() {
        let snack = PTSnackBarViewController.init(image: UIImage.init(named: "Doggie")!, message: "Warning!", informativeText: "Hands up!\nYour are under attack!")
        snack.presented(by: self, animated: true, completion: nil)
    }
    
    @objc
    func showLoading() {
        let loading = PTLoadingViewController.init(message: nil)
//        let loading = PTLoadingViewController.init(message: "Loading ...")
        present(viewController: loading, settings: .default, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            loading.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc
    func showCustom() {
        let sb = UIStoryboard.init(name: "Main", bundle: nil)
        let controller = sb.instantiateViewController(withIdentifier: "Test") as! TestViewController
        present(viewController: controller, settings: .default, animated: true, completion: nil)
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        let data = self.cells[indexPath.row]
        cell?.textLabel?.text = data.rawValue
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cells.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = self.cells[indexPath.row]
        self.perform(data.selector)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

