//
//  ViewController.swift
//  Personel
//
//  Created by Ion Utale on 11/02/2018.
//  Copyright © 2018 Ion Utale. All rights reserved.
//

import UIKit
import BRYXBanner

class ViewController: UIViewController {
    var connectionsCount: Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func presentAlert(title: String = "", message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func presentBanner(title: String, message: String, backgroundColor: UIColor = .ySecondaryColor) {
        let banner = Banner(title: title, subtitle: message, backgroundColor: backgroundColor)
        banner.dismissesOnTap = true
        banner.show(duration: 3.0)
        
    }
    
    // this may not work. if not just import in every view controler that you are using the 2 methods bellow
    func startLoader() {
        connectionsCount += 1
        print("**** connection count:", connectionsCount)
        if let navLoading = self.navigationController?.navigationBar as? NavigationBarWithLoading {
            navLoading.startLoading(.red)
        }
    }
    
    func stopLoader() {
        connectionsCount -= 1
        //        connectionsCount = connectionsCount < 0 ? 0 : connectionsCount
        print("**** connection count:", connectionsCount)
        if connectionsCount < 1, let navLoading = self.navigationController?.navigationBar as? NavigationBarWithLoading {
            navLoading.stopLoading()
        }
    }
}


