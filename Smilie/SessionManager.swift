//
//  DataManager.swift
//  Shareink
//
//  Created by ufos on 01.07.2015.
//  Copyright (c) 2015 ufos. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import CoreLocation


public class SessionManager {

    
    //

    static let BASE_URL: String = "http://vps314642.ovh.net:3232/"



    // instance (lazy)
    static let instance = SessionManager()

    //
    
    
    init() {
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30 // seconds
    }
    
    func clear() {
        
    }
    

}

//



