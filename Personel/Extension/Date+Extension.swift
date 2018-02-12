//
//  Date+Extension.swift
//  Youtech PROD
//
//  Created by Ion Utale on 22/01/2018.
//  Copyright © 2018 Florence-Consulting. All rights reserved.
//

import Foundation

extension Date {
    
    static func timeFrom(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.date
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.timeZone = TimeZone(abbreviation: "CET")
        return dateFormatter.string(from: date)
    }
    
    static func dateFromSimple(string: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        dateFormatter.timeZone = TimeZone(abbreviation: "CET")
        guard let date = dateFormatter.date(from: string) else {
            fatalError("ERROR: Date conversion failed due to mismatched format.")
        }
        return date
    }
    
    static func dateFrom(string: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        guard let date = dateFormatter.date(from: string) else {
            fatalError("ERROR: Date conversion failed due to mismatched format.")
        }
        return date
    }
    
    static func dateFrom(string: String, format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        guard let date = dateFormatter.date(from: string) else {
            fatalError("ERROR: Date conversion failed due to mismatched format.")
        }
        
        dateFormatter.dateFormat = format///this is what you want to convert format
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        return dateFormatter.string(from: date)
    }
    
    static func stringFrom(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        return dateFormatter.string(from: date)
    }
    
    static func stringFrom(date: Date, format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        return dateFormatter.string(from: date)
    }
    
    static var startDateMilis: Int64 {
        return Int64(Date().timeIntervalSince1970 * 1000)
    }
    
    static var millisecondsSince1970: Int64 {
        get {
            return Int64(TimeInterval(Date().timeIntervalSince1970 ) * 1000)
        }
    }
    
    var millisecondsSince1970: Int64 {
        get {
            return Int64(TimeInterval(self.timeIntervalSince1970 ) * 1000)
        }
    }
    
    static func hoursAndMinutesFrom_manualCalculation(mil: Int64) -> String {
        let minutes: Int64! = (mil / 1000 / 60) % 60
        let hours: Int64! = mil / 1000 / 60 / 60
        let minStr: String! = minutes < 10 ? "0\(minutes!)" : "\(minutes!)"
        let hourStr: String! = hours < 10 ? "0\(hours!)" : "\(hours!)"
        return minutes >= 0 ? "\(hourStr!):\(minStr!)" : "00:00"
    }
    
    static func minutesAndSecondsFrom_manualCalculation(mil: Int64) -> String {
        let seconds: Int64! = (mil / 1000 % 60)
        let minutes: Int64! = mil / 1000 / 60
        let secStr: String! = seconds < 10 ? "0\(seconds!)" : "\(seconds!)"
        let minStr: String! = minutes < 10 ? "0\(minutes!)" : "\(minutes!)"
        return seconds >= 0 ? "\(minStr!)h \(secStr!)m" : "00:00"
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
