//
//  UIColor+Extension.swift
//  Youtech
//
//  Created by Ion Utale on 15/01/2018.
//  Copyright © 2018 Florence-Consulting. All rights reserved.
//

import UIKit


extension UIColor {
    
    static var dark = UIColor.initSimple(red: 48, green: 48, blue: 48, alpha: 1.0)
    static var darkBlue = UIColor.initSimple(red: 0, green: 42, blue: 79, alpha: 1.0)

    static func initSimple(red: Double, green: Double, blue: Double, alpha: Double) -> UIColor {
        return UIColor.init(red: CGFloat(red/255.0), green: CGFloat(green/255.0), blue: CGFloat(blue/255.0), alpha: 1.0)
    }
    
    open class var ySecondaryColor: UIColor {
        return UIColor(red: 111/255.0, green: 111/255.0, blue: 111/255.0, alpha: 1)
    }
}
