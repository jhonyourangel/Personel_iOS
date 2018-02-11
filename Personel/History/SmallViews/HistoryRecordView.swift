//
//  HistoryRecordView.swift
//  Personel
//
//  Created by Ion Utale on 11/02/2018.
//  Copyright © 2018 Ion Utale. All rights reserved.
//

import UIKit

class HistoryRecordView: UICollectionViewCell {
    @IBOutlet weak var dateL: UILabel!
    
    @IBOutlet weak var startTimeL: UILabel!
    @IBOutlet weak var endTimeL: UILabel!
    @IBOutlet weak var workedTimeL: UILabel!
    @IBOutlet weak var earnedL: UILabel!

    @IBOutlet weak var projectNameL: UILabel!
    
    @IBOutlet weak var billedImage: UIImageView!
    
    var billed: Bool! {
        didSet{
            billedImage.image = self.billed ? #imageLiteral(resourceName: "coin (8)") : #imageLiteral(resourceName: "coin_black")
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
