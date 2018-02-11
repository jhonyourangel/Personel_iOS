//
//  AddProjectVC.swift
//  Personel
//
//  Created by Ion Utale on 11/02/2018.
//  Copyright © 2018 Ion Utale. All rights reserved.
//

import UIKit
import TransitionButton

class AddProjectVC: ViewController {
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var incomeTF: UITextField!
    @IBOutlet weak var saveBtn: TransitionButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func saveProject() {
        
    }
}

extension AddProjectVC: UITextFieldDelegate {
    
}
