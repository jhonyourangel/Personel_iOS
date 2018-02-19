
//
//  Network.swift
//  Plus
//
//  Created by emiliano on 23/10/2017.
//  Copyright © 2017 TPay. All rights reserved.
//

import UIKit
import Alamofire


class Network: NSObject {
    struct URLs {
         static let base = "http://192.168.1.220:8080/api"
//        static let base = "http://mean-personel.a3c1.starter-us-west-1.openshiftapps.com/api"
        static let login = "\(base)/login"
        
        static let transaction = "\(base)/ios/transaction"
        static let transactions = "\(base)/ios/transactions"
        static let editTransaction = "\(base)/ios/editTransaction"
        static let addTransaction = "\(base)/ios/addTransaction"
        static let deleteTransaction = "\(base)/ios/deleteTransaction"

        static let project = "\(base)/ios/project"
        static let projects = "\(base)/ios/projects"
        static let editProject = "\(base)/ios/editProject"
        static let addProject = "\(base)/ios/addProject"
        static let deleteProject = "\(base)/ios/deleteProject"
    }

    
    static let sessionManager: Alamofire.SessionManager = {
        let Header = HeaderRequestAdapter()
        
        let sessionManager = Alamofire.SessionManager.default
        sessionManager.session.configuration.timeoutIntervalForRequest = 10
        sessionManager.adapter = Header
        sessionManager.retrier = Header
        return sessionManager
    }()
   
    static func getNSError( data: Data) -> NSError? {
        do {
            let error = try JSONDecoder().decode(ErrorModel.self, from: data)
            let code = error.code ?? 500
            if let msg = error.message {
                let dict:[String:Any] = [NSLocalizedDescriptionKey: msg]
                return NSError(domain: "telepasspay.com", code: code, userInfo: dict)
            }
        } catch _ {}
        return nil
    }
    
    static func getNSError(code: Int, message: String) -> NSError? {
        return NSError(domain: "telepasspay.com", code: code, userInfo: [NSLocalizedDescriptionKey: message])
    }
    
    static func login(username: String, password: String, completion: @escaping(User?, Int?, Error?) -> ()) {
        let URL = URLs.login
        
        let parameters: Parameters = [
            "email": username,
            "password": password
        ]
        
        sessionManager.request(URL, method: .post, parameters: parameters, encoding: URLEncoding.default )
        .validate()
        .responseJSON(completionHandler: { response in
            let statusCode = response.response?.statusCode
            switch response.result {
            case .success( _):
                guard let data = response.data else {
                    completion(nil, statusCode, ErrorModel.defError())
                    return
                }
                do {
                    let item = try JSONDecoder().decode(User.self, from: data)
                    completion(item, statusCode, nil)
                } catch let jsonError {
                    completion( nil, statusCode, jsonError as NSError)
                }
            case .failure(let error):
                if let data = response.data {
                    completion(nil, statusCode, getNSError( data: data) ?? error as NSError)
                } else {
                    completion(nil, statusCode, error as NSError)
                }
            }
        })
    }
    
    // todo add refresh token
    // todo add log out
}
