//
//  DateRange.swift
//  Personel
//
//  Created by Ion Utale on 11/02/2018.
//  Copyright © 2018 Ion Utale. All rights reserved.
//

import UIKit

class DateRange: UICollectionViewCell {
    @IBOutlet weak var startDay: UILabel!
    @IBOutlet weak var startMonth: UILabel!
    @IBOutlet weak var startYear: UILabel!
    
    @IBOutlet weak var endDay: UILabel!
    @IBOutlet weak var endMonth: UILabel!
    @IBOutlet weak var endYear: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
