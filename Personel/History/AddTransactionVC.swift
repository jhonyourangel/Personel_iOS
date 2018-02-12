//
//  AddTransactionVC.swift
//  Personel
//
//  Created by Ion Utale on 11/02/2018.
//  Copyright © 2018 Ion Utale. All rights reserved.
//

import UIKit
import TransitionButton

class AddTransactionVC: ViewController {
    @IBOutlet weak var projectPicker: UIPickerView!
    @IBOutlet weak var startTimePicker: UIDatePicker!
    @IBOutlet weak var endTimePicker: UIDatePicker!
    @IBOutlet weak var stringDateTF: UITextField!

    @IBOutlet weak var saveBtn: TransitionButton!
    
    var projects: [Project]! = UserManager.projects
    
    var selectedProjectId: String! = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startTimePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        endTimePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboardByTappingOutside))
        
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func hideKeyboardByTappingOutside() {
        self.view.endEditing(true)
    }
    
    @objc func dateChanged(_ sender: UIDatePicker) {
        let componenets = Calendar.current.dateComponents([.hour, .minute], from: sender.date)
        if let hour = componenets.hour, let min = componenets.minute {
            print("\(hour)", "\(min)")
        }
    }
    
    func getTimeFrom( picker: UIDatePicker) -> String {
        let componenets = Calendar.current.dateComponents([.hour, .minute], from: picker.date)
        if let hour = componenets.hour, let min = componenets.minute {
            return ("\(hour):\(min)")
        }
        return ("00:00")
    }
    
    @IBAction func addTransaction() {
        print(Date.stringFrom(date: startTimePicker.date))
        print(Date.stringFrom(date: endTimePicker.date))
        let startDate = "\(stringDateTF.text!) \(Date.timeFrom(date:startTimePicker.date))"
        let endDate = "\(stringDateTF.text!) \(Date.timeFrom(date:endTimePicker.date))"
       
        saveBtn.startAnimation()
        self.startLoader()
        
        Network.addTransaction(description: "no desc", startTime: startDate, endTime: endDate, userId: "5a7ef4378e4301390d3de91d", projectId: selectedProjectId) { (tran, statusCode, error) in
            self.saveBtn.stopAnimation()
            self.stopLoader()
            if error != nil {
                self.presentBanner(title: "error", message: (error?.localizedDescription)!)
                return
            }
            self.presentBanner(title: "trasaction saved", message: "")

        }
        
    }
}

extension AddTransactionVC: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
        print(row)

        selectedProjectId = projects[row]._id
        print(projects[row].name, selectedProjectId)
    }
}

extension AddTransactionVC: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return projects.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return projects[row].name!
    }
}
