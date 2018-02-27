//
//  Token.swift
//  Personel
//
//  Created by Ion Utale on 11/02/2018.
//  Copyright © 2018 Ion Utale. All rights reserved.
//

import Foundation

class Token: Codable {
    var token: String!
    
    // decoded token
    var _id: String?
    var email: String?
    var name: String?
    var profileImage: String?
    var exp: Int64?
    var iat: Int64?
    
    var expDate: Date?
    
    func tokenToData(t: String) -> Data {
        //splitting JWT to extract payload
        let arr = t.components(separatedBy: ".")
        
        var base64String = arr[1] as String
        if base64String.count % 4 != 0 {
            let padlen = 4 - base64String.count % 4
            base64String += String.init(repeating: "=", count: padlen)
        }
        
        return NSData(base64Encoded: base64String, options: [])! as Data
    }
    
    func jsonToToken(tJson: Data) -> Token {
        return try! JSONDecoder().decode(Token.self, from: tJson)
    }
}


