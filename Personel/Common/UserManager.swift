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
    private let kToken = "token"
    private let kUserTokenKey = "userToken"
    private let kUserTokenExpDate = "userTokenExpDate"
    private let kProjects = "projects"
    private let kStartTimeSlider = "startTimeSlider"
    private let kEndTimeSlider = "endTimeSlider"
    private let kUser = "user"

    static var projects: [Project]! {
        get {
            if  let encoded = UserDefaults.standard.object(forKey: UserManager().kProjects) {
                if let decoded = try? JSONDecoder().decode([Project].self, from: encoded as! Data) {
                    return decoded
                }
            }
            return []
        }
        set (newValue) {
            if let newValue = newValue , let encoded = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(encoded, forKey: UserManager().kProjects)
            } else {
                UserDefaults.standard.removeObject(forKey: UserManager().kProjects)
            }
        }
    }
    
    static var startTimeSlider: CGFloat {
        get {
            if  let encoded = UserDefaults.standard.object(forKey: UserManager().kStartTimeSlider) {
                return encoded as! CGFloat
            }
            return 6 * 60 * 60
        }
        set (newValue) {
                UserDefaults.standard.set(newValue, forKey: UserManager().kStartTimeSlider)
            
        }
    }

    static var endTimeSlider: CGFloat {
        get {
            if  let encoded = UserDefaults.standard.object(forKey: UserManager().kEndTimeSlider) {
                return encoded as! CGFloat
            }
            return 13 * 60 * 60
        }
        set (newValue) {
            UserDefaults.standard.set(newValue, forKey: UserManager().kEndTimeSlider)
        }
    }

    static func keyChain() -> Keychain {
        return Keychain(server:  "http://localhost", protocolType: .http)
    }
    
    var token: Token? {
        get {
            if  let encoded = UserDefaults.standard.object(forKey: self.kToken) {
                if let tokenObj = try? JSONDecoder().decode(Token.self, from: encoded as! Data) {
                    return tokenObj
                }
            }
            return nil
        }
        
        set (newValue) {
            if let newValue = newValue , let encoded = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(encoded, forKey: self.kToken)
            } else {
                UserDefaults.standard.removeObject(forKey: self.kToken)
            }
        }
    }
    
    var user: User? {
        get {
            if  let encoded = UserDefaults.standard.object(forKey: self.kUser) {
                if let decoded = try? JSONDecoder().decode(User.self, from: encoded as! Data) {
                    return decoded
                }
            }
            return nil
        }
        set (newValue) {
            if let newValue = newValue , let encoded = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(encoded, forKey: self.kUser)
            } else {
                // not sure about the remove function
                UserDefaults.standard.removeObject(forKey: self.kUser)
            }
        }
    }
    
    init() {
        let kc = UserManager.keyChain()
    }
    
    func logout() {
        self.token = nil
        
        let keychain = UserManager.keyChain()
        do {
            try keychain.remove( kUserTokenKey)
        } catch let error {
            print("error: \(error)")
        }
    }
}
