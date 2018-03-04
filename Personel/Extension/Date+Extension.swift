//
//  Date+Extension.swift
//  Youtech PROD
//
//  Created by Ion Utale on 22/01/2018.
//  Copyright © 2018 Florence-Consulting. All rights reserved.
//

import UIKit

extension Date {
    
    static func secondsFrom(date: Date) -> CGFloat {
        // 2018-02-20T08:10:00.000Z
        // this looks awkword but it makes sens
        // i am taking just the hours and minutes from the date
        // because the circular slider returns the date in the current year
        // and wee need it to convert it to time for convenience
        // the bellow line will fix it
        let newDate = "1970-01-01T\(Date.stringTimeFrom(date: date)):00.000Z"
        let seconds = Date.dateWithFullAttributesFrom(string: newDate).timeIntervalSince1970
        return CGFloat(seconds)
    }
    
    static func stringTimeFrom(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        return dateFormatter.string(from: date)
    }
    
    static func dateWithFullAttributesFrom(string: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        guard let date = dateFormatter.date(from: string) else {
            fatalError("ERROR: Date conversion failed due to mismatched format.")
        }
        return date
    }
    
    static func stringUTCDateFrom(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        return dateFormatter.string(from: date)
    }
    
    static func stringDateFrom(date: Date, format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        return dateFormatter.string(from: date)
    }
    
    static var millisecondsSince1970: Int64 {
        get {
            return Int64(TimeInterval(Date().timeIntervalSince1970 ) * 1000)
        }
    }
    
    var millisecondsSince1970: Int64 {
        get {
            return Date.millisecondsSince1970
        }
    }
    
    static func hoursAndMinutesFrom_manualCalculation(mil: Int64) -> String {
        let minutes: Int64! = (mil / 1000 / 60) % 60
        let hours: Int64! = mil / 1000 / 60 / 60
        let minStr: String! = minutes < 10 ? "0\(minutes!)" : "\(minutes!)"
        let hourStr: String! = hours < 10 ? "0\(hours!)" : "\(hours!)"
        return minutes >= 0 ? "\(hourStr!):\(minStr!)" : "00:00"
    }
    
    static func dateFromJsonMilis(intDate: Int64) -> Date {
        return Date(timeIntervalSince1970: Double(intDate))
    }
}

extension TimeInterval {
    
    func format() -> String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .abbreviated
        formatter.maximumUnitCount = 1
        return formatter.string(from: self)
    }
}
