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
    
    var project: Project!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTF.text = project.name
        incomeTF.text = "\(project.income!)"
    }
    
    @IBAction func saveProject() {
        if project._id == nil {
            addProject()
            return
        }
        editProject()
    }
    
    func addProject() {
        saveBtn.startAnimation()
        self.startLoader()
        Network.addProject(name: nameTF.text!, income: Int(incomeTF.text!)!) { (proj, statusCode, error) in
            self.saveBtn.stopAnimation()
            self.stopLoader()
            if error != nil {
                self.presentBanner(title: "error", message: (error?.localizedDescription)!)
                return
            }
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func editProject() {
        saveBtn.startAnimation()
        self.startLoader()
        Network.editProject(id: project._id!, name: nameTF.text!, income: Int(incomeTF.text!)!) { (proj, statusCode, error) in
            self.saveBtn.stopAnimation()
                self.stopLoader()
                if error != nil {
                    self.presentBanner(title: "error", message: (error?.localizedDescription)!)
                    return
                }
                // maybe pop back at this point
            self.navigationController?.popViewController(animated: true)

            }
        }
    
}

extension AddProjectVC: UITextFieldDelegate {
    
}
