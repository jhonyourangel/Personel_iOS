
//
//  Network.swift
//  PyngPlus
//
//  Created by emiliano on 23/10/2017.
//  Copyright © 2017 TPay. All rights reserved.
//

import UIKit
import Alamofire


class Network: NSObject {
    
    struct ApiUrl {
        static let baseDomainString = Config.baseDomainString
        static let profileEntryPoint = baseDomainString + "/users/profile/"
        static let authEntryPoint = baseDomainString + "/uaa/"
        static let devicesEntryPoint = baseDomainString + "/devices/"
        static let supportEntryPoint = baseDomainString + "/support/"
        
        static let servicesEntryPoint = baseDomainString + "/services/"
        static let servicesFuelEntryPoint = servicesEntryPoint + "fuel"
        static let servicesParkingEntryPoint = servicesEntryPoint + "parkings"
    }
    
    struct WebUrl {
        static let home = "https://pyngplus.telepasspay.com"
        static let registrationUrl = home + "/"
        static let requestCredentialsUrl = home + "/"
        
        static let acceptConditions = home + "/#/webview/term-conditions/register"
        static let discoverHowToUse = home + "/webviews/scopri-come-funziona.html"
        static let legalInfo = home + "/#/webview/term-conditions/menu"
        static let acceptConditionsParking = home + "/#/webview/term-conditions/park"
        static let acceptConditionsFuel = home + "/#/webview/term-conditions/fuel"
        static let enumFAQ = home + "/#/webview/faq"
        static let enumActiveService = "https://www.telepass.com/it/privati"

        static let urlLegalInfo = home + "/#/webview/term-conditions/menu"
        static let assistance = home + "/telepass-pay/assistenza"
        static let normeDiUtilizzo = home + "/#/webview/term-conditions/menu2"
        static let migrationFromPyngUrl = "https://www.telepass.com/it/pyng-family"
        static let vote = "https://appstore.com/pyng" //Not used
        
        static let activeService = "https://www.telepass.com/it/privati"
        static let pyngplus = "https://www.telepass.com/it/pyng-plus"
        static let parkingSticker = "https://firebasestorage.googleapis.com/v0/b/pyng-da3a0.appspot.com/o/public%2FTagliando.pdf?alt=media"
    }
    
    public static let kGrantType_2fa = "2fa"
    public static let kGrantType_phone_number_pin = "phone_number_pin"
    public static let k_refresh_token_2fa = "refresh_token_2fa"
    public static let k_refresh_token_phone_number_pin = "refresh_token_phone_number_pin"


    static let sessionManager: Alamofire.SessionManager = {
        let pyngHeader = PyngHeaderRequestAdapter()
        
        let sessionManager = Alamofire.SessionManager.default
        sessionManager.session.configuration.timeoutIntervalForRequest = 10
        sessionManager.adapter = pyngHeader
        sessionManager.retrier = pyngHeader
        return sessionManager
    }()
    
    
    
    static func getNSError( data: Data) -> NSError? {
        do {
            let error = try JSONDecoder().decode(ErrorModel.self, from: data)
            let code = error.code ?? 500
            if let msg = error.errorMessage() {
                var dict:[String:Any] = [NSLocalizedDescriptionKey: msg]
                if let embSourceErrorCode = error.details?.embSourceErrorCode, let time = error.details?.embMaxParkingTime, embSourceErrorCode == "013" {
                    dict[ErrorModel.kMaxParkingTime] = time
                }
                return NSError(domain: "telepasspay.com", code: code, userInfo: dict)
            }
        } catch _ {}
        return nil
    }
    
    static func getNSError(code: Int, message: String) -> NSError? {
        return NSError(domain: "telepasspay.com", code: code, userInfo: [NSLocalizedDescriptionKey: message])
    }
    
    static func login( username: String?, password: String?, phoneNumber: String?, completion: @escaping(Int, NSError?) ->()) {
        let URL = ApiUrl.authEntryPoint + "oauth/token"
        
        var parameters: Parameters = [
            "device_id": PyngHeaderRequestAdapter.deviceId,
            "client_id": "tpay-app",
            "grant_type": phoneNumber == nil ? kGrantType_2fa : kGrantType_phone_number_pin
        ]
        // login with phone number
        if phoneNumber != nil {
            parameters["phone_number"] = phoneNumber!
        }
        // login with username and password
        else {
            parameters["username"] = username!
            parameters["password"] = password!
        }
        
        sessionManager.request(URL, method: .post, parameters: parameters, encoding: URLEncoding.default )
            //.validate()
            .responseJSON(completionHandler: { response in
                let statusCode = response.response?.statusCode
                switch response.result {
                case .success(let value):
                    
                    if let res = value as? NSDictionary {
                        // if the access token is not nil means that the old token is expired
                        if res.value(forKey: "access_token") != nil {
                            // save the new access_token
                            let pyAuth = PYAuthManager.sharedInstance
                            let tokenExpireExtension: Double = res.value(forKey: "expires_in") as! Double
                            
                            pyAuth.userTokenExpireDate = Date(timeIntervalSince1970: TimeInterval(Date.real.timeIntervalSince1970 + tokenExpireExtension))
                            pyAuth.userToken = res.value(forKey: "access_token") as? String
                            pyAuth.userRefreshToken = res.value(forKey: "refresh_token") as? String ?? ""
                            // save the grant_type
                            pyAuth.grantType = phoneNumber == nil ? kGrantType_2fa : kGrantType_phone_number_pin
                            completion(statusCode!,  nil)
                        } else if let data = response.data {
                            completion( statusCode!, self.getNSError(data: data) ?? ErrorModel.defError())
                        }
                    } else {
                        let error = NSError.init(domain: "telepasspay.com", code: 401, userInfo: [NSLocalizedDescriptionKey:"error"])
                        completion(401, error)
                    }
                case .failure(let error):
                    let code = statusCode ?? error._code
                    if let data = response.data {
                        completion( code, self.getNSError(data: data) ?? error as NSError)
                    } else {
                        completion( code, error as NSError)
                    }
                }
            })
    }
    
    public static func logout( completion: @escaping(Error?) ->()) {
        let URL = "\(ApiUrl.authEntryPoint)logout"
        
        var parameters: Parameters = [
            "refreshToken": PYAuthManager.sharedInstance.userRefreshToken
        ]
        
        if let token =  PYAuthManager.sharedInstance.appRegistrationId  {
            parameters["appRegistrationId"] = token
        }

        sessionManager.request(URL, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate()
            .responseJSON(completionHandler: { response in
                switch response.result {
                case .success:
                    completion( nil)
                case .failure(let error):
                    completion( error as Error)
                }
            })
    }
    
    static func reauth( completion: @escaping(Int, NSError?) ->()) {
        let URL = ApiUrl.authEntryPoint + "oauth/token"
        
        let parameters: Parameters = [
            "refresh_token" : PYAuthManager.sharedInstance.userRefreshToken ,
            "grant_type": PYAuthManager.sharedInstance.grantType == kGrantType_2fa ? k_refresh_token_2fa : k_refresh_token_phone_number_pin,
          //  "grant_type": k_refresh_token_2fa,
            "device_id": PyngHeaderRequestAdapter.deviceId
        ]
        // removed validate() to avoid infinite loop on retry
        sessionManager.request(URL, method: .post, parameters: parameters, encoding: URLEncoding.default)
            .responseJSON(completionHandler: { response in
                switch response.result {
                    
                case .success(let value):
                    let code = response.response?.statusCode ?? 500
                    if let responseDict = value as? NSDictionary {
                        // if the access token is not nil means that the old token is expired
                        if code == 200 && responseDict.value(forKey: "access_token") != nil {
                            // save the new access_token
                            let pyAuth = PYAuthManager.sharedInstance
                            let tokenExpireExtension: Double = responseDict.value(forKey: "expires_in") as! Double
                            
                            pyAuth.userTokenExpireDate = Date(timeIntervalSince1970: TimeInterval(Date.real.timeIntervalSince1970 + tokenExpireExtension))
                            pyAuth.userToken = responseDict.value(forKey: "access_token") as? String
                            pyAuth.userRefreshToken = responseDict.value(forKey: "refresh_token") as! String
                            completion(200,  nil)
                        } else {
                            if let data = response.data {
                                completion( code, self.getNSError(data: data) ?? ErrorModel.defError() as NSError)
                            } else {
                                completion( code, ErrorModel.defError() as NSError)
                            }
                        }
                    } else {
                        completion(401, ErrorModel.defError() )
                    }
                case .failure(let error):
                    let code = response.response?.statusCode ?? error._code
                    if let data = response.data {
                        completion( code, self.getNSError(data: data) ?? error as NSError)
                    } else {
                        completion( code, error as NSError)
                    }
                }
            })
    }
    
    public static func getProfile(completion: @escaping(UserProfile?, Error?) ->()) {
        let URL = "\(ApiUrl.profileEntryPoint)me"
        
        let req = sessionManager.request(URL, method: .get, parameters: [:], encoding: URLEncoding.default)
        
        req.validate().responseJSON(completionHandler: { response in
            //guard let statusCode = response.response?.statusCode else { return }
            
            switch response.result {
            case .success:
                do {
                    let item = try JSONDecoder().decode(UserProfile.self, from: response.data!)
                    completion(item, nil)
                } catch let jsonError {
                    print("Error serializing json: ", jsonError)
                    completion(nil, jsonError as NSError)
                }
                
            case .failure(let error):
                completion(nil, error as NSError)
            }
        })
    }
    
    public static func changePassword(oldPsw: String, newPsw: String, completion: @escaping(Error?) ->()) {
        let URL = "\(ApiUrl.profileEntryPoint)me/password"
        
        let p: Parameters = [
            "oldPassword": oldPsw,
            "newPassword": newPsw]
        
        let req = sessionManager.request(URL, method: .put, parameters: p, encoding: JSONEncoding.default)
        
        req.responseJSON(completionHandler: { response in
            let statusCode = response.response?.statusCode ?? 0
            
            switch response.result {
            case .success(let value):
                
                let response = value as? NSDictionary
                if let errorCode = response?["code"] as? Int, let errorMessage = response?["message"] as? String {
                    let message = (statusCode == 409 && errorCode == 804) ? "key_modify_password_error" : errorMessage
                    
                    let error = getNSError(code: errorCode, message: message)
                    completion(error)
                    
                } else {
                    completion(nil)
                }
                
            case .failure(let error):
                completion(error as NSError)
            }
        })
    }

    public static func getTransaction(from: Date?, to: Date?, completion: @escaping([Transaction]?, NSError?) ->()) {
        let URL = ApiUrl.profileEntryPoint + "transactions"
        
        let p: Parameters = [
            //Opzionali
            //"serviceCode": serviceCode,
            //"contractCode": contractCode,
            //"plateNumber": platenumber,
            //"countryCode": countryCode,
            "fromDate": from?.millisecondsSince1970 ?? NSNull(),
            "toDate": to?.millisecondsSince1970 ?? NSNull(),
            
            //Obbligatori
            "limit" : 10000,
            "offset": 0,
            
            //Order by
            "orderBy": "creationDate", //"amount", "creationDate", "serviceCode"
            "desc": "true",
            ]
        
        sessionManager.request(URL, method: .get, parameters: p, encoding: URLEncoding.default)
            .validate()
            .responseJSON(completionHandler: { response in
                switch response.result {
                case .success:
                    if let data = response.data {
                        do {
                            let item = try JSONDecoder().decode([Transaction].self, from: data)
                            completion(item, nil)
                        } catch let jsonError {
                            completion(nil, jsonError as NSError)
                        }
                    } else {
                        let error = NSError.init(domain: "telepasspay.com", code: 500, userInfo: [NSLocalizedDescriptionKey:"error"])
                        completion(nil, error)
                    }
                case .failure(let error):
                    if let data = response.data {
                        completion( nil, self.getNSError(data: data) ?? error as NSError)
                    } else {
                        completion( nil, error as NSError)
                    }
                }
            })
    }
    
    public static func transactionExpensesNote(ids: [String], completion: @escaping(Data?, NSError?) ->()) {
        let URL = ApiUrl.profileEntryPoint + "me/reports/expenses"
        
        let p: Parameters = [
            "txCollection": ids
        ]
        
        sessionManager.request(URL, method: .post, parameters: p, encoding: "")
            .responseJSON(completionHandler: { response in
                guard let data = response.data else { return }
                
                switch response.result {
                case .success:
                    do {
                        let item = try JSONDecoder().decode(ExpensesNoteResponse.self, from: data)
                        
                            completion(item.reportBytes, nil)
                    } catch let jsonError {
                        completion(nil, jsonError as NSError)
                    }
                case .failure(let error):
                    completion(nil, error as NSError)
                }
            })
    }
    
    // Mark -
    public static func getTrx( trxId:String, completion: @escaping( PYTpayTransaction?, NSError?) ->()) {
        let URL = "\(ApiUrl.profileEntryPoint)transactions/\(trxId)"
        sessionManager.request(URL, method: .get, parameters: [:], encoding: URLEncoding.default).validate()
            .responseJSON(completionHandler: { response in
                
                guard let data = response.data else { return }
                
                switch response.result {
                case .success:
                    do {
                        let item = try JSONDecoder().decode(PYTpayTransaction.self, from: data)
                        completion(item, nil)
                    } catch let jsonError {
                        completion( nil, jsonError as NSError)
                    }
                case .failure(let error):
                    completion( nil, getNSError( data: data) ?? error as NSError)
                }
            })
    }
    
    public static func acceptedTandC( servie: ServiceCode, completion: @escaping(Error?) ->()) {
        let URL = "\(ApiUrl.profileEntryPoint)me/services/\(servie.serviceId)/accept"

        _sessionManager.request(URL, method: .put, parameters: nil, encoding: JSONEncoding.default)
            .validate().responseJSON(completionHandler: { response in
            
            switch response.result {
            case .success(let value):
                
                let response = value as? NSDictionary
                if let errorCode = response?["code"] as? Int, let errorMessage = response?["message"] as? String {
                    let error = getNSError(code: errorCode, message: errorMessage)
                    completion(error)
                } else {
                    completion(nil)
                }
                
            case .failure(let error):
                completion(error as NSError)
            }
        })
    }
    
    // Mark -
   /* public static func webHookLog(params: Parameters) {
        Alamofire.request("https://testwebhooks.com/c/pyngfuel",method: .post,parameters: params, encoding: JSONEncoding.default)
    }*/
    
   
}
