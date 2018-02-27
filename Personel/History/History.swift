//
//  History.swift
//  Personel
//
//  Created by Ion Utale on 11/02/2018.
//  Copyright © 2018 Ion Utale. All rights reserved.
//

import UIKit

class History: ViewController {
    @IBOutlet weak var tableView: UITableView!
    var transactions: [Transaction]! = [];
    @IBOutlet weak var addBtn: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "HistoryRecordViewCell", bundle: nil), forCellReuseIdentifier: "historyCell")

    }
    
    fileprivate func getTransactions() {
        Network.getTransactions { (trans, sc, error) in
            self.stopLoader()
            if error != nil {
                self.presentBanner(title: "Error", message: "unable to get transactions.\(error?.localizedDescription ?? "")")
                return
            }
            self.transactions = trans
            self.tableView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.startLoader()
        getTransactions()
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "addTransaction" {
            let destination = segue.destination as! AddTransactionVC
            destination.transaction = sender as? Transaction
        }
    }
    
    @IBAction func addTransaction(_ sender: Any) {
        self.performSegue(withIdentifier: "addTransaction", sender: self)
    }
}

extension History: UITableViewDelegate {}
extension History: UITableViewDataSource {
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            let trans = transactions[indexPath.row]
            self.startLoader()
            Network.deleteTransaction(id: trans._id!, completion: { (genericResposne, statusCode, error) in
                self.stopLoader()
                
                //                print(genericResposne?.msg, genericResposne?.project?._id, genericResposne?.project?.name)
                
                if error != nil {
                    self.presentBanner(title: "Error", message: "The projet could not be deleted", backgroundColor: .white)
                } else {
                    self.getTransactions()
                }
            })
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: HistoryRecordViewCell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath) as! HistoryRecordViewCell
        let t = transactions[indexPath.row]
        
        
        if let proj = UserManager.projects.filter({ $0.name == t.projectName }).first {
            print(proj.income!, proj.name!, t.projectName!)
            cell.projectNameL.text = proj.name!
            cell.earnedL.text = "\(proj.income! * (t.workedMinutes / 60) / 100)€"
        } else {
            cell.projectNameL.text = ""
            cell.earnedL.text = "0.0€"
        }
        
        cell.dateL.text = Date.stringDateFrom(date: t.startTime!, format: "dd MMMM yyyy")
        cell.startTimeL.text = Date.stringDateFrom(date: t.startTime!, format: "HH:mm")
        cell.endTimeL.text = Date.stringDateFrom(date: t.endTime!, format: "HH:mm")
        cell.workedTimeL.text = Date.hoursAndMinutesFrom_manualCalculation(mil: Int64(t.workedMinutes * 60000))
        
        cell.billedImage.image = t.billed! ? #imageLiteral(resourceName: "coin (8)") : #imageLiteral(resourceName: "coin_black")

        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "addTransaction", sender: transactions[indexPath.row])
    }
}
