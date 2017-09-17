//
//  DataSource.swift
//  Shareink
//
//  Created by ufos on 01.07.2015.
//  Copyright (c) 2015 ufos. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class ActionManager
{
    // instance (lazy)
    static let instance = ActionManager()
    
    func performAction(_ method: Alamofire.HTTPMethod, url: String, params: [String : Any], encoding: ParameterEncoding = URLEncoding.default, completed : @escaping (_ success : Bool, _ response: JSON?, _ errorCode: Int?) -> ())
    {
        
        request("\(SessionManager.BASE_URL)\(url)", method: method, parameters: params, encoding: encoding, headers: [:])
            .validate(statusCode: [200])
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                
                if(response.result.error == nil) {
                    let jsonData = JSON(response.result.value!)
                    let success = jsonData["success"].boolValue
                    let errorCode = jsonData["error_code"].intValue
                    
                    log("request = \(String(describing: response.request)), response = \(String(describing: response.result.value))")
                    
                    completed(success, jsonData, errorCode)
                } else {
                    log("request = \(String(describing: response.request)), error = \(String(describing: response.result.error))")
                    
                    completed(false, nil, response.response?.statusCode)
                }
        }
    }

    
    //

    
    
    static func addSmile() {
        let timestamp = Int64(Date().timeIntervalSince1970)
        let hash = (timestamp%102) * 8
        
        self.addSmile(timestamp, hash: hash) { (success, response, errorCode) in
            log("ADD SMILE - \(success)")
        }
    }
    
    //
    
    static func addSmile(_ timestamp: Int64, hash: Int64, completed : @escaping (_ success : Bool, _ response: JSON?, _ errorCode: Int?) -> ()) {
        ActionManager.instance.performAction(HTTPMethod.post, url: "add_smile", params: ["timestamp" : timestamp, "val" : hash], completed: completed)
    }
    
    //
}

//

