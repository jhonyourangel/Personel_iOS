//
//  UserManager.swift
//  Personel
//
//  Created by Ion Utale on 11/02/2018.
//  Copyright © 2018 Ion Utale. All rights reserved.
//

import Foundation
import KeychainAccess

class UserManager {
    private let kUserTokenKey = "userToken"

    static func keyChain() -> Keychain {
        return Keychain(server:  "http://localhost", protocolType: .http)
    }
    
    var userToken: String? {
        didSet {
            UserManager.keyChain()[kUserTokenKey] = self.userToken
        }
    }
    
    init() {
        let kc = UserManager.keyChain()
        self.userToken = try! kc.getString( kUserTokenKey) ?? nil
    }
    
    func logout() {
        self.userToken = nil
        
        let keychain = UserManager.keyChain()
        do {
            try keychain.remove( kUserTokenKey)
        } catch let error {
            print("error: \(error)")
        }
    }
}
