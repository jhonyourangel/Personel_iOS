//
//  Logout.swift
//  Personel
//
//  Created by Ion Utale on 26/02/2018.
//  Copyright © 2018 Ion Utale. All rights reserved.
//

import UIKit

class Logout:ViewController {
    
    
    @IBAction func logout () {
        UserManager().logout()
        Login.login()
    }
}
