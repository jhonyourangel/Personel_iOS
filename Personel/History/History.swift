//
//  History.swift
//  Personel
//
//  Created by Ion Utale on 11/02/2018.
//  Copyright © 2018 Ion Utale. All rights reserved.
//

import UIKit

class History: ViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    var transactions: [Transaction]! = [];
    @IBOutlet weak var addBtn: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UINib(nibName: "HistoryRecordView", bundle: nil), forCellWithReuseIdentifier: "history")
        
        Network.getTransactions { (trans, sc, error) in
            if error != nil {
                self.presentBanner(title: "Error", message: "unable to get transactions.\(error?.localizedDescription ?? "")")
                return
            }
            self.transactions = trans
            self.collectionView.reloadData()
        }
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    @IBAction func addTransaction(_ sender: Any) {
        self.performSegue(withIdentifier: "addTransaction", sender: self)
    }
}

extension History: UICollectionViewDelegate {}
extension History: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return transactions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: HistoryRecordView = collectionView.dequeueReusableCell(withReuseIdentifier: "history", for: indexPath) as! HistoryRecordView
        let t = transactions[indexPath.row]
        
//        cell.projectNameL.text = t.projectId
        cell.startTimeL.text = Date.stringFrom(date: t.startTime!, format: "HH:mm")
        cell.endTimeL.text = Date.stringFrom(date: t.endTime!, format: "HH:mm")
        cell.workedTimeL.text = Date.hoursAndMinutesFrom_manualCalculation(mil: Int64(t.workedMinutes * 60000))
        cell.billed = t.billed
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}
