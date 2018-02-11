//
//  Header.swift
//  Plus
//
//  Created by Ion Utale on 17/11/2017.
//  Copyright © 2017 TPay. All rights reserved.
//

// ho importato tutto, senza controllare cosa serve realmente
import Foundation
import UIKit
import Alamofire
import CoreTelephony
import CoreLocation

// needed to pass a plain {} as parameter
extension String: ParameterEncoding {
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()
        if let theJSONData = try? JSONSerialization.data(
            withJSONObject: parameters!,
            options: []) {
            request.httpBody = theJSONData
        }
        return request
    }
}

class HeaderRequestAdapter: RequestAdapter, RequestRetrier {
    
    
    // Mark: - RequestAdapter
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        let userManager = UserManager.init()
        
        if  let accessToken: String = userManager.userToken {
            urlRequest.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        } else {
            urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        }
        return urlRequest
    }
    
    // Mark: - RequestRetrier
    func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        guard request.retryCount == 0 else { return completion(false, 0) } // only 1 retry.. we need to test it
        if let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401{
            // replace the reauth whit something better
//            Network.reauth() {
//                statusCode, error in
//                // the class user has been eliminated. send something else
//                completion(error == nil, 0.0)
//                if let err = error {
//                    print("still returns statusCode: \(statusCode), error: \(err)")
//                }
//            }
        } else {
            completion(false, 0.0)      // not a 401, not our problem
        }
    }
}
