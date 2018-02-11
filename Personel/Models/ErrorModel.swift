//
//  ErrorModel.swift
//  Personel
//
//  Created by Ion Utale on 11/02/2018.
//  Copyright © 2018 Ion Utale. All rights reserved.
//

import Foundation

class ErrorModel:  Decodable {
    
    let code : Int?
    let message: String?
    
    static func defError() -> NSError {
        return NSError(domain: "telepasspay.com", code: 500, userInfo: [:])
    }
    
    static func errorModel(data: Data) -> ErrorModel? {
        do {
            let errorModel = try JSONDecoder().decode(ErrorModel.self, from: data)
            return errorModel
        } catch let jsonError {
            print("the errorModel was unable to serialize.", "\nthe jsonString is:", data.base64EncodedString().base64Decoded()!, "\n*\n*\nError:", jsonError)
            return nil
        }
    }
}

class ErrorModeDetail:  Decodable {
    let embSourceErrorDesc: String?
    let embSourceErrorCode: String?
    let embMaxParkingTime: Int64?
    
    let kdbErrorResponse: ErrorModeDetailKdb?
}

class ErrorModeDetailKdb:  Decodable {
    let code: String?
    let description: String?
    let details: [String]? // not sure
}
