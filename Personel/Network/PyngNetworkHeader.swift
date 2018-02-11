//
//  PyngHeader.swift
//  PyngPlus
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

class PyngHeaderRequestAdapter: RequestAdapter, RequestRetrier {
    // Mark: - header Variabels
    static private let firstPart = "dHBheS1hcHA6dHBhe"
    static private let secondPart = "S1zM2NyM3Q="
    static private let authKey = "\(firstPart)\(secondPart)"
    static var verificationText: String?
    lazy var locationManager:CLLocationManager? = CLLocationManager()
    
    public static let osName: String = "iOS"
    public static let osVersion: String = UIDevice.current.systemVersion
    
    public static var deviceId: String = {
        if let id = UIDevice.current.identifierForVendor?.uuidString {
            return id
        }
        return ""
    }()
    
    public static var appVersion: String = {
        if let strVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") {
            return "\(strVersion)"
        }
        return ""
    }()

    
    public static var connectionType: String {
        if let manager = NetworkReachabilityManager() {
            if manager.isReachableOnWWAN {
                return "CELLULAR"
            } else if manager.isReachableOnEthernetOrWiFi {
                return "WIFI"
            }
        }
        return "unknown"
    }
    
    public static var mobileNetworkType: String
    {
        let t = connectionType
        if "CELLULAR" == t {
            let telefonyInfo = CTTelephonyNetworkInfo.init()
            if let radioAccessTechnology = telefonyInfo.currentRadioAccessTechnology{
                switch radioAccessTechnology{
                case CTRadioAccessTechnologyLTE:
                    return "LTE (4G)"
                case CTRadioAccessTechnologyWCDMA:
                    return "3G"
                case CTRadioAccessTechnologyEdge:
                    return "EDGE (2G)"
                default:
                    return "Other"
                }
            }
        }
        return t
    }
    
    public func lastLocationData() -> (lat:Double, lon:Double, accurancy:Double) {
        if self.locationManager == nil {
            self.locationManager = CLLocationManager()
        }
        if let location = self.locationManager?.location {
            return ( location.coordinate.latitude, location.coordinate.longitude, location.horizontalAccuracy)
        }
        return (0, 0, 0)
    }
    
    public func location() -> CLLocation? {
        return CLLocationManager().location
    }
    
    // Mark: - RequestAdapter
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        
        
        if  let accessToken: String = PYAuthManager.sharedInstance.userToken, !(urlRequest.url?.absoluteString.hasSuffix("/token"))!{
            urlRequest.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        } else {
           // urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            urlRequest.setValue("Basic \(PyngHeaderRequestAdapter.authKey)", forHTTPHeaderField: "Authorization")
        }
        
        if PyngHeaderRequestAdapter.verificationText != nil {
            urlRequest.setValue(PyngHeaderRequestAdapter.verificationText!, forHTTPHeaderField: "X-TPay-Verification-Text")
        }

        let (lat, lon, accurancy) = self.lastLocationData()
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.setValue(PyngHeaderRequestAdapter.deviceId, forHTTPHeaderField: "X-TPay-Device-Id")
        urlRequest.setValue(PyngHeaderRequestAdapter.appVersion, forHTTPHeaderField: "X-TPay-App-Version")
        urlRequest.setValue(PyngHeaderRequestAdapter.osVersion, forHTTPHeaderField: "X-TPay-OS-Version") //
        urlRequest.setValue(PyngHeaderRequestAdapter.osName, forHTTPHeaderField: "X-TPay-OS-Type")
        urlRequest.setValue("\(lat)", forHTTPHeaderField: "X-TPay-Latitude")
        urlRequest.setValue("\(lon)", forHTTPHeaderField: "X-TPay-Longitude")
        urlRequest.setValue("\(accurancy)", forHTTPHeaderField: "X-TPay-GPS-Error")
        urlRequest.setValue(PyngHeaderRequestAdapter.connectionType, forHTTPHeaderField: "X-TPay-Connection-Type")
        urlRequest.setValue(PyngHeaderRequestAdapter.mobileNetworkType, forHTTPHeaderField: "X-TPay-Mobile-Network-Type")
        urlRequest.setValue("\(Int(Date().timeIntervalSince1970))", forHTTPHeaderField: "X-TPay-App-Millis")
        
        return urlRequest
    }
    
    // Mark: - RequestRetrier
    func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        guard request.retryCount == 0 else { return completion(false, 0) } // only 1 retry.. we need to test it
        if let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401{
            PyngNetwork.reauth() {
                statusCode, error in
                // the class user has been eliminated. send something else
                completion(error == nil, 0.0)
                if let err = error {
                    print("still returns statusCode: \(statusCode), error: \(err)")
                }
            }
        } else {
            completion(false, 0.0)      // not a 401, not our problem
        }
    }
}
