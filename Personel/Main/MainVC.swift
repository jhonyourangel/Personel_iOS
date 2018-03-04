//
//  MainVC.swift
//  Personel
//
//  Created by Ion Utale on 11/02/2018.
//  Copyright © 2018 Ion Utale. All rights reserved.
//

import UIKit

class MainVC: ViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var transactions: [Transaction]! = [];
    var workedMin: Int = 0
    var earned: Int = 0
    
    var beginRangeDate: Date! = Calendar.current.date(byAdding: .month, value: -1, to: Date())
    var endRangeDate: Date! = Date()
    
    static func makeNCFromStoryboard() -> UINavigationController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainNC") as! UINavigationController
    }
    
    static func makeTabBarFromStoryboard() -> UITabBarController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainTabBar") as! UITabBarController
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UINib(nibName: "DataRangeCollView", bundle: nil), forCellWithReuseIdentifier: "dr")
        collectionView.register(UINib(nibName: "WorkedHours", bundle: nil), forCellWithReuseIdentifier: "WorkedHours")
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.startLoader()
        getTransactions(beginDate: beginRangeDate, endDate: endRangeDate)
    }
    
    func getTransactions(beginDate: Date,
                         endDate: Date) {
        let startDateStr = Date.stringUTCDateFrom(date: beginDate)
        let endDateStr = Date.stringUTCDateFrom(date: endDate)
        
        // don't know where to put those

        Network.getTransactions(startTime: startDateStr, endTime: endDateStr) { (trans, sc, error) in
            self.stopLoader()
            if error != nil {
                self.presentBanner(title: "Error", message: "unable to get transactions.\(error?.localizedDescription ?? "")")
                return
            }
            self.transactions = trans
            let workedMin = self.getWorkedMinutes(trans: trans!)
            self.workedMin = workedMin
            
            self.collectionView.reloadData()
        }
    }
    
    func getWorkedMinutes(trans: [Transaction]) -> Int {
        var wMin = 0
        earned = 0
        _ = trans.map { (t) in
            wMin += t.workedMinutes
            if let proj = UserManager.projects.filter({ $0.name == t.projectName }).first {
                self.earned += proj.income! * (t.workedMinutes / 60) / 100
            }
        }
        
        return wMin
    }
}

extension MainVC: UICollectionViewDelegate {}
extension MainVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.row {
        case 0:
            let cell: DateRange = collectionView.dequeueReusableCell(withReuseIdentifier: "dr", for: indexPath) as! DateRange
            cell.startDay.text = Date.stringDateFrom(date: beginRangeDate, format: "dd")
            cell.startMonth.text = Date.stringDateFrom(date: beginRangeDate, format: "MMM")
            cell.startYear.text = Date.stringDateFrom(date: beginRangeDate, format: "yyyy")

            cell.endDay.text = Date.stringDateFrom(date: endRangeDate, format: "dd")
            cell.endMonth.text = Date.stringDateFrom(date: endRangeDate, format: "MMM")
            cell.endYear.text = Date.stringDateFrom(date: endRangeDate, format: "yyyy")
            
            return cell
        case 1:
            let cell: WorkedHours = collectionView.dequeueReusableCell(withReuseIdentifier: "WorkedHours", for: indexPath) as! WorkedHours
            cell.workedHours.text = Date.hoursAndMinutesFrom_manualCalculation(mil: Int64(workedMin * 60000))
            cell.earned.text = "\(self.earned)€"
            return cell
        default:
            let cell: WorkedHours = collectionView.dequeueReusableCell(withReuseIdentifier: "WorkedHours", for: indexPath) as! WorkedHours
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let calendarVC = CalendarVC.makeVCFromStoryboard()
            calendarVC.delegate = self
            self.present(calendarVC, animated: true, completion: nil)
        }
    }
}
extension MainVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch indexPath.row {
        case 0:
            return CGSize(width: 310.0, height: 49.0)
        default:
            return CGSize(width: 310.0, height: 274.0)
        }
    }
}

extension MainVC: CalendarDelegate {
    func selectedRange(beginRD: Date, endRD: Date) {
        // to do
        self.beginRangeDate = beginRD
        self.endRangeDate = endRD
        
        getTransactions(beginDate: beginRD, endDate: endRD)
    }
}

