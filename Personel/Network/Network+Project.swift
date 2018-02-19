//
//  Network+Project.swift
//  Personel
//
//  Created by Ion Utale on 11/02/2018.
//  Copyright © 2018 Ion Utale. All rights reserved.
//

import Foundation
import Alamofire

extension Network {
    
    static func getProjects(completion: @escaping([Project]?, Int?, Error?) -> ()) {
        let URL = URLs.projects
        
        sessionManager.request(URL, method: .get, parameters: [:], encoding: URLEncoding.default )
            //.validate()
            .responseJSON(completionHandler: { response in
                let statusCode = response.response?.statusCode
                switch response.result {
                case .success( _):
                    guard let data = response.data else {
                        completion(nil, statusCode, ErrorModel.defError())
                        return
                    }
                    do {
                        let item = try JSONDecoder().decode([Project].self, from: data)
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
    
    static func addProject(name: String, income: Int,completion: @escaping(Project?, Int?, Error?) -> ()) {
        let URL = URLs.addProject
        let parameters: Parameters = [
            "name": name,
            "income": income
        ]
        sessionManager.request(URL, method: .post, parameters: parameters, encoding: URLEncoding.default )
            //.validate()
            .responseJSON(completionHandler: { response in
                let statusCode = response.response?.statusCode
                switch response.result {
                case .success( _):
                    guard let data = response.data else {
                        completion(nil, statusCode, ErrorModel.defError())
                        return
                    }
                    do {
                        let item = try JSONDecoder().decode(Project.self, from: data)
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
    
    static func editProject(id: String,name: String, income: Int,completion: @escaping(Project?, Int?, Error?) -> ()) {
        let URL = URLs.editProject
        let parameters: Parameters = [
            "id": id,
            "name": name,
            "income": income
        ]
        sessionManager.request(URL, method: .put, parameters: parameters, encoding: URLEncoding.default )
            //.validate()
            .responseJSON(completionHandler: { response in
                let statusCode = response.response?.statusCode
                switch response.result {
                case .success( _):
                    guard let data = response.data else {
                        completion(nil, statusCode, ErrorModel.defError())
                        return
                    }
                    do {
                        let item = try JSONDecoder().decode(Project.self, from: data)
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
    
    
    static func deleteProject(id: String, completion: @escaping(GenericResponse?, Int?, Error?) -> ()) {
        let URL = URLs.deleteProject
        let parameters: Parameters = [ "id": id ]
        
        sessionManager.request(URL, method: .delete, parameters: parameters, encoding: URLEncoding.default )
            //.validate()
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
