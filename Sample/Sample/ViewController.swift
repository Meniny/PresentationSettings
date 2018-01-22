//
//  ViewController.swift
//  Sample
//
//  Created by Meniny on 2018-01-22.
//  Copyright © 2018年 Meniny. All rights reserved.
//

import UIKit
import PresentationSettings

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func showAlert(_ sender: UIButton) {
        let alert = PTAlertController.init()
        present(viewController: alert, settings: .default, animated: true, completion: nil)
    }
    
    @IBAction func showCustom(_ sender: UIButton) {
        let sb = UIStoryboard.init(name: "Main", bundle: nil)
        let controller = sb.instantiateViewController(withIdentifier: "Test") as! TestViewController
        present(viewController: controller, settings: .default, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

