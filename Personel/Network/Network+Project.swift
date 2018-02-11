//
//  Network+Project.swift
//  Personel
//
//  Created by Ion Utale on 11/02/2018.
//  Copyright © 2018 Ion Utale. All rights reserved.
//

import Foundation

extension Network {
    
    static func getTransactions(completion: @escaping([Project]?, Int?, Error?) -> ()) {
        let URL = URLs.projects
        
        sessionManager.request(URL, method: .get, parameters: [:], encoding: URLEncoding.default )
            //.validate()
            .responseJSON(completionHandler: { response in
                let statusCode = response.response?.statusCode
                switch response.result {
                case .success(let _):
                    guard let data = response.data else {
                        completion(nil, statusCode, ErrorModel.defError())
                        return
                    }
                    do {
                        let item = try JSONDecoder().decode([Project].self, from: data)
                        completion(item, statusCode, nil)
                    } catch let jsonError {
                        print(data.base64EncodedString().base64Decoded(), jsonError)
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
