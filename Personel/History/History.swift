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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.startLoader()
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: HistoryRecordViewCell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath) as! HistoryRecordViewCell
        let t = transactions[indexPath.row]
        
        cell.projectId = t.projectId
        cell.workedTime = t.workedMinutes
        
        cell.startTimeL.text = Date.stringFrom(date: t.startTime!, format: "HH:mm")
        cell.endTimeL.text = Date.stringFrom(date: t.endTime!, format: "HH:mm")
        cell.workedTimeL.text = Date.hoursAndMinutesFrom_manualCalculation(mil: Int64(t.workedMinutes * 60000))
        cell.billed = t.billed
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "addTransaction", sender: transactions[indexPath.row])
    }
}
