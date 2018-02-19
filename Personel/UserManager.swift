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
    
    static var projects: [Project]! {
        get {
            if  let encoded = UserDefaults.standard.object(forKey: "projects") {
                if let decoded = try? JSONDecoder().decode([Project].self, from: encoded as! Data) {
                    return decoded
                }
            }
            return []
        }
        set (newValue) {
            if let newValue = newValue , let encoded = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(encoded, forKey: "projects")
            } else {
                // not sure about the remove function
                UserDefaults.standard.removeObject(forKey: "projects")
            }
        }
    }

    static func keyChain() -> Keychain {
        return Keychain(server:  "http://localhost", protocolType: .http)
    }
    
    var userToken: String? {
        didSet {
            UserManager.keyChain()[kUserTokenKey] = self.userToken
        }
    }
    
    var user: User? {
        get {
            if  let encoded = UserDefaults.standard.object(forKey: "user") {
                if let decoded = try? JSONDecoder().decode(User.self, from: encoded as! Data) {
                    return decoded
                }
            }
            return nil
        }
        set (newValue) {
            if let newValue = newValue , let encoded = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(encoded, forKey: "user")
            } else {
                // not sure about the remove function
                UserDefaults.standard.removeObject(forKey: "user")
            }
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
