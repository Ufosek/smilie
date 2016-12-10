//
//  DataManager.swift
//  Smilie
//
//  Created by Ufos on 13.11.2016.
//  Copyright © 2016 Ufos. All rights reserved.
//

import Foundation


class DataManager {
    
    fileprivate static let CURRENT_PHOTO_KEY = "CurrentPhotoKey"
    
    //
    
    static var currentPhotoNumber: Int {
        let userDefaults = UserDefaults.standard
        return userDefaults.integer(forKey: CURRENT_PHOTO_KEY)
    }
    
    static func incrementCurrentPhotoNumber() {
        let userDefaults = UserDefaults.standard
        userDefaults.set(DataManager.currentPhotoNumber+1, forKey: CURRENT_PHOTO_KEY)
        userDefaults.synchronize()
    }
    
}
