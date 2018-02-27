//
//  Network+Transacrion.swift
//  Personel
//
//  Created by Ion Utale on 15/02/2018.
//  Copyright © 2018 Ion Utale. All rights reserved.
//

import Foundation
import Alamofire

extension Network {
    
    static func getTransactions(startTime: String = "",
                                endTime: String = "",
        completion: @escaping([Transaction]?, Int?, Error?) -> ()) {
        let URL = URLs.transactions
        
        var parameters: Parameters = [
            "startTime": startTime,
            "endTime": endTime
        ]
        
        // in history there is no range selection, this will force getting all of the transactions
        if startTime == "" {
            parameters = [:]
        }
        
        sessionManager.request(URL, method: .get, parameters: parameters, encoding: URLEncoding.default )
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
                        let item = try JSONDecoder().decode([Transaction].self, from: data)
                        completion(item, statusCode, nil)
                    } catch let jsonError {
                        print(data.base64EncodedString().base64Decoded() as Any, jsonError)
                        completion( nil, statusCode, jsonError as NSError)
                    }
                case .failure(let error):
                    if let data = response.data {
                        print(error)
                        print(data.base64EncodedString().base64Decoded() as Any)
                        completion(nil, statusCode, getNSError( data: data) ?? error as NSError)
                    } else {
                        completion(nil, statusCode, error as NSError)
                    }
                }
            })
    }
    
    static func addTransaction(description: String,
                               startTime: String,
                               endTime: String,
                               userId: String,
                               projectName: String,
                               completion: @escaping(Transaction?, Int?, Error?) -> ()) {
        let URL = URLs.addTransaction
        let parameters: Parameters = [
            "description": description,
            "startTime": startTime,
            "endTime": endTime,
            "userId": userId,
            "projectName": projectName
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
                        let item = try JSONDecoder().decode(Transaction.self, from: data)
                        completion(item, statusCode, nil)
                    } catch let jsonError {
                        print(data.base64EncodedString().base64Decoded() as Any, jsonError)
                        completion( nil, statusCode, jsonError as NSError)
                    }
                case .failure(let error):
                    if let data = response.data {
                        print(error.localizedDescription, statusCode as Any)
                        completion(nil, statusCode, getNSError( data: data) ?? error as NSError)
                    } else {
                        completion(nil, statusCode, error as NSError)
                    }
                }
            })
    }

    static func editTransaction(id: String,
                                description: String,
                               startTime: String,
                               endTime: String,
                               userId: String,
                               projectName: String,
                               completion: @escaping(Transaction?, Int?, Error?) -> ()) {
        let URL = URLs.editTransaction
        let parameters: Parameters = [
            "id" : id,
            "description": description,
            "startTime": startTime,
            "endTime": endTime,
            "userId": userId,
            "projectName": projectName
        ]
        sessionManager.request(URL, method: .put, parameters: parameters, encoding: URLEncoding.default )
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
                        let item = try JSONDecoder().decode(GenericResponse.self, from: data)
                        completion(item.transaction, statusCode, nil)
                    } catch let jsonError {
                        print(data.base64EncodedString().base64Decoded() as Any, jsonError)
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
    
    
    static func deleteTransaction(id: String, completion: @escaping(GenericResponse?, Int?, Error?) -> ()) {
        let URL = URLs.deleteTransaction
        let parameters: Parameters = [ "id": id ]
        
        sessionManager.request(URL, method: .delete, parameters: parameters, encoding: URLEncoding.default )
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
                        let item = try JSONDecoder().decode(GenericResponse.self, from: data)
                        completion(item, statusCode, nil)
                    } catch let jsonError {
                        print(data.base64EncodedString().base64Decoded() as Any, jsonError)
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
}
