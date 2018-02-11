//
//  String+Extension.swift
//  Youtech
//
//  Created by Ion Utale on 12/01/2018.
//  Copyright © 2018 Florence-Consulting. All rights reserved.
//
import Foundation

extension String
{
    func toDateFrom(_ format: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format //Your date format
        let date = dateFormatter.date(from: self) //according to date format your date string
        return date!
    }
    
    var localized: String {
        if let _ = UserDefaults.standard.string(forKey: "i18n_language") {} else {
            // we set a default, just in case
            UserDefaults.standard.set("fr", forKey: "i18n_language")
            UserDefaults.standard.synchronize()
        }
        
        let lang = UserDefaults.standard.string(forKey: "i18n_language")
        
        let path = Bundle.main.path(forResource: lang, ofType: "lproj")
        let bundle = Bundle(path: path!)
        
        return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
    }
    
    func replacePlaceholders(placeholders : [String], values : [String]) -> String {
        var placeholderIndex=0
        var tempString=self
        for placeholder in placeholders {
            tempString=tempString.replacingOccurrences(of: placeholder, with: values[placeholderIndex])
            placeholderIndex=placeholderIndex+1
        }
        return tempString
    }
}
