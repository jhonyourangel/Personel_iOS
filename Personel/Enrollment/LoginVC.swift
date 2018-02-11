//
//  Enrollment.swift
//  Personel
//
//  Created by Ion Utale on 11/02/2018.
//  Copyright © 2018 Ion Utale. All rights reserved.
//

import UIKit
import TransitionButton

class Login: ViewController{
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var loginBtn: TransitionButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    @IBAction func login() {
        loginBtn.startAnimation()
        Network.login(username: emailTF.text!, password: passwordTF.text!) { (token, statusCode, error) in
            
            if error != nil {
                self.presentBanner(title: "Error", message: "unable to login, please try again")
                self.loginBtn.stopAnimation()
                return
            }
            
            UserManager().userToken = token?.token
            self.loginBtn.stopAnimation(animationStyle: .expand, revertAfterDelay: 0.0, completion: {
                // login went well go to main view
                self.view.window?.rootViewController = MainVC.makeNCFromStoryboard()
            })
            // add code here
        }
    }
}
