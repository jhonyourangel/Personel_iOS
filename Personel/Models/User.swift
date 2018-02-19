//
//  User.swift
//  Personel
//
//  Created by Ion Utale on 15/02/2018.
//  Copyright © 2018 Ion Utale. All rights reserved.
//

import Foundation

class User: Codable {
    var token: String? // this is only at login
    
    var _id: String!
    var name: String?
    var surname: String?
    var username: String?
    var email: String?
    // get profile image
}
