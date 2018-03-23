//
//  History.swift
//  Personel
//
//  Created by Ion Utale on 11/02/2018.
//  Copyright © 2018 Ion Utale. All rights reserved.
//

import UIKit
import SwipeCellKit

class History: ViewController {
    @IBOutlet weak var tableView: UITableView!
    var transactions: [Transaction]! = [];
    @IBOutlet weak var addBtn: UINavigationItem!

    @IBOutlet weak var dateRange: DateRange!
    var beginRangeDate: Date! = Calendar.current.date(byAdding: .month, value: -1, to: Date())
    var endRangeDate: Date! = Date()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "HistoryRecordViewCell", bundle: nil), forCellReuseIdentifier: "historyCell")
        
    }
    
    fileprivate func getTransactions(beginDate: Date,
                         endDate: Date) {
        let startDateStr = Date.stringUTCDateFrom(date: beginDate)
        let endDateStr = Date.stringUTCDateFrom(date: endDate)
        
        // don't know where to put those
        self.startLoader()
        Network.getTransactions(startTime: startDateStr, endTime: endDateStr) { (trans, sc, error) in
            self.stopLoader()
            if error != nil {
                self.presentBanner(title: "Error", message: "unable to get transactions.\(error?.localizedDescription ?? "")")
                return
            }
            self.transactions = trans
            self.tableView.reloadData()
        }
    }
    
    // func ready to be removed
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
        updateDateRangeView()
        getTransactions(beginDate: beginRangeDate, endDate: endRangeDate)
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
    
    func updateDateRangeView() {
        dateRange.startDay.text = Date.stringDateFrom(date: beginRangeDate, format: "dd")
        dateRange.startMonth.text = Date.stringDateFrom(date: beginRangeDate, format: "MMM")
        dateRange.startYear.text = Date.stringDateFrom(date: beginRangeDate, format: "yyyy")
        
        dateRange.endDay.text = Date.stringDateFrom(date: endRangeDate, format: "dd")
        dateRange.endMonth.text = Date.stringDateFrom(date: endRangeDate, format: "MMM")
        dateRange.endYear.text = Date.stringDateFrom(date: endRangeDate, format: "yyyy")
    }
    
    @IBAction func changeDateRange() {
        let calendarVC = CalendarVC.makeVCFromStoryboard()
        calendarVC.delegate = self
        self.present(calendarVC, animated: true, completion: nil)
    }
    
    @IBAction func addTransaction(_ sender: Any) {
        self.performSegue(withIdentifier: "addTransaction", sender: nil)
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
                if error != nil {
                    self.presentBanner(title: "Error", message: "The transaction could not be deleted", backgroundColor: .white)
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
        
        cell.delegate = self
        
        let t = transactions[indexPath.row]
        
        if let proj = UserManager.projects.filter({ $0.name == t.projectName }).first {
//            print(proj.income!, proj.name!, t.projectName!)
            cell.projectNameL.text = proj.name!
            cell.earnedL.text = "\(proj.income! * (t.workedMinutes / 60) / 100)€"
        } else {
            cell.projectNameL.text = ""
            cell.earnedL.text = "0.0€"
        }
        
        cell.dateL.text = Date.stringDateFrom(date: t.startTime!, format: "dd MMMM yyyy", timeZone: "CET")
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

extension History: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        let t = transactions[indexPath.row]
        
        if orientation == .left {
            let billedAction = SwipeAction(style: .destructive, title: "Billed") { action, indexPath in
                // handle action by updating model with deletion
                self.startLoader()
                                
                Network.editTransaction(id: t._id!,
                                        description: "no desc",
                                        startTime: Date.stringDateFrom(date: t.startTime!, format: "yyyy-MM-dd HH:mm:ss"),
                                        endTime: Date.stringDateFrom(date: t.endTime!, format: "yyyy-MM-dd HH:mm:ss"),
                                        userId: t.userId! ,
                                        projectName: t.projectName!,
                                        billed: !t.billed! ) { (tran, statusCode, error) in
                                            self.stopLoader()
                                            if error != nil {
                                                self.presentBanner(title: "error", message: (error?.localizedDescription)!)
                                                return
                                            }
                                            self.presentBanner(title: "trasaction saved", message: "")
                                            self.transactions[indexPath.row].billed = !t.billed!
                                            (self.tableView.cellForRow(at: indexPath) as! HistoryRecordViewCell).billedImage.image = t.billed! ? #imageLiteral(resourceName: "coin (8)") : #imageLiteral(resourceName: "coin_black")
                }
            }
            // customize the action appearance
            billedAction.image = !t.billed! ? #imageLiteral(resourceName: "coin (8)") : #imageLiteral(resourceName: "coin_black")
            billedAction.title = !t.billed! ? "Billed" : "Not Billed"
            return [billedAction]
        }
        else /*if orientation == .left*/ {
            let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
                // handle action by updating model with deletion
                self.transactions.remove(at: indexPath.row)
                self.startLoader()
                Network.deleteTransaction(id: t._id!, completion: { (genericResposne, statusCode, error) in
                    self.stopLoader()
                    if error != nil {
                        self.presentBanner(title: "Error", message: "The transaction could not be deleted", backgroundColor: .white)
                    } else {
                        self.getTransactions()
                    }
                })
            }

            return [deleteAction]
        }
        
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = orientation == .left ? .selection : .destructive
        options.transitionStyle = .border
        
        return options
    }
    
}

extension History: CalendarDelegate {
    func selectedRange(beginRD: Date, endRD: Date) {
        // to do
        self.beginRangeDate = beginRD
        self.endRangeDate = endRD
        updateDateRangeView()
        getTransactions(beginDate: beginRD, endDate: endRD)
    }
}


