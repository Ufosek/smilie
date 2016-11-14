//
//  DataManager.swift
//  Smilie
//
//  Created by Ufos on 13.11.2016.
//  Copyright © 2016 Ufos. All rights reserved.
//

import Foundation


class DataManager {
    
    private static let CURRENT_PHOTO_KEY = "CurrentPhotoKey"
    
    //
    
    static var currentPhotoNumber: Int {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        return userDefaults.integerForKey(CURRENT_PHOTO_KEY)
    }
    
    static func incrementCurrentPhotoNumber() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setInteger(DataManager.currentPhotoNumber+1, forKey: CURRENT_PHOTO_KEY)
        userDefaults.synchronize()
    }
    
}