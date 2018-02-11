//
//  Transaction.swift
//  Personel
//
//  Created by Ion Utale on 11/02/2018.
//  Copyright © 2018 Ion Utale. All rights reserved.
//

import Foundation

class Transaction: Codable {
    var creationDate: Date?
    var editDate: Date?
    var billed: Bool?
    var _id: String?
    var id: String?
    var description: String?
    var startTime: Date?
    var endTime: Date?
    var userId: String?
    var projectId: String?
    
    var workedMinutes: Int! = 0
    
    private enum CodingKeys: String, CodingKey {
        case creationDate
        case editDate
        case billed
        case _id
        case id
        case description
        case startTime
        case endTime
        case userId
        case projectId
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        _id = try container.decode(String.self, forKey: ._id)
        id = try container.decode(String.self, forKey: .id)
        billed = try container.decode(Bool.self, forKey: .billed)
        description = try container.decode(String.self, forKey: .description)
//        userId = try container.decode(String.self, forKey: .userId)
//        projectId = try container.decode(String.self, forKey: .projectId)

        var dateString = try container.decode(String.self, forKey: .creationDate)
        creationDate = Date.dateFrom(string: dateString)
        
        dateString = try container.decode(String.self, forKey: .editDate)
        editDate = Date.dateFrom(string: dateString)
        
        dateString = try container.decode(String.self, forKey: .startTime)
        startTime = Date.dateFrom(string: dateString)
        
        dateString = try container.decode(String.self, forKey: .endTime)
        endTime = Date.dateFrom(string: dateString)
        
        workedMinutes = Int(endTime!.millisecondsSince1970 - startTime!.millisecondsSince1970) / 60000
        print(Date.stringFrom(date: startTime!),Date.stringFrom(date:  endTime!), workedMinutes)
    }
}

