//
//  String+Extension.swift
//  Youtech
//
//  Created by Ion Utale on 12/01/2018.
//  Copyright © 2018 Florence-Consulting. All rights reserved.
//
import Foundation

extension String
{
    func base64Encoded() -> String? {
        if let data = self.data(using: .utf8) {
            return data.base64EncodedString()
        }
        return nil
    }
    
    func base64Decoded() -> String? {
        if let data = Data(base64Encoded: self) {
            return String(data: data , encoding: .utf8)
        }
        return nil
    }
}
