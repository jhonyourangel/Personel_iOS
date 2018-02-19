//
//  GenericResponse.swift
//  Personel
//
//  Created by Ion Utale on 15/02/2018.
//  Copyright © 2018 Ion Utale. All rights reserved.
//

import Foundation

class GenericResponse: Codable {
    var msg: String?
    var project: Project?
    var transaction: Transaction?

}
