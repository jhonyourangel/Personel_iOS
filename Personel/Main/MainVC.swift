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
    
    static func makeNCFromStoryboard() -> UINavigationController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainNC") as! UINavigationController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UINib(nibName: "DateRange", bundle: nil), forCellWithReuseIdentifier: "dr")
        collectionView.register(UINib(nibName: "WorkedHours", bundle: nil), forCellWithReuseIdentifier: "WorkedHours")
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
            return cell
        case 1:
            let cell: WorkedHours = collectionView.dequeueReusableCell(withReuseIdentifier: "WorkedHours", for: indexPath) as! WorkedHours
            return cell
        default:
            let cell: WorkedHours = collectionView.dequeueReusableCell(withReuseIdentifier: "WorkedHours", for: indexPath) as! WorkedHours
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       
    }
}
//extension MainVC: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//        return segmentView.selectedSegmentIndex == 0 ? kDraftSize : kMultimediaSize
//    }
//}

