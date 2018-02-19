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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //UserManager().userToken = nil
        if let token = UserManager().userToken {
            print(token)
            self.view.window?.rootViewController = MainVC.makeTabBarFromStoryboard()
        }
    }
    
    static func makeVCFromStoryboard() -> Login {
        return UIStoryboard(name: "Enrollment", bundle: nil).instantiateViewController(withIdentifier: "login") as! Login
    }
    
    static func login() {
        UIApplication.shared.keyWindow?.rootViewController = Login.makeVCFromStoryboard()
    }
    
    @IBAction func login() {
        loginBtn.startAnimation()
        Network.login(username: emailTF.text!, password: passwordTF.text!) { (user, statusCode, error) in
            
            if error != nil {
                self.presentBanner(title: "Error", message: "unable to login, please try again")
                self.loginBtn.stopAnimation()
                return
            }
            
            UserManager().userToken = user?.token
            UserManager().user = user
            self.loginBtn.stopAnimation(animationStyle: .expand, revertAfterDelay: 0.0, completion: {
                // login went well go to main view
                self.view.window?.rootViewController = MainVC.makeTabBarFromStoryboard()
            })
        }
    }
}
