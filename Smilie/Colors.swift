//
//  Colors.swift
//  Shareink
//
//  Created by ufos on 05.07.2015.
//  Copyright (c) 2015 ufos. All rights reserved.
//

import Foundation
import UIKit


extension UIColor {
    
    convenience init(r: Int, g: Int, b: Int, a: CGFloat = 1) {
        self.init(red: CGFloat(r)/CGFloat(255), green: CGFloat(g)/CGFloat(255), blue: CGFloat(b)/CGFloat(255), alpha: a)
    }
    
    convenience init(hex: String) {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = (cString as NSString).substringFromIndex(1)
        }
        
        let rString = (cString as NSString).substringToIndex(2)
        let gString = ((cString as NSString).substringFromIndex(2) as NSString).substringToIndex(2)
        let bString = ((cString as NSString).substringFromIndex(4) as NSString).substringToIndex(2)
        
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        NSScanner(string: rString).scanHexInt(&r)
        NSScanner(string: gString).scanHexInt(&g)
        NSScanner(string: bString).scanHexInt(&b)
        
        
        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
    }
    
    //
    
    
    static var grayLight: UIColor {
        return UIColor(r: 248, g: 248, b: 248)
    }
    
    static var grayMedium: UIColor {
        return UIColor(r: 235, g: 235, b: 235)
    }
    
    static var grayMediumLight: UIColor {
        return UIColor(r: 243, g: 243, b: 243)
    }
    
    static var gray: UIColor {
        return UIColor(r: 230, g: 230, b: 230)
    }
    
    static var grayDark: UIColor {
        return UIColor(r: 188, g: 188, b: 188)
    }
    
    static var dark: UIColor {
        return UIColor(r: 25, g: 25, b: 25)
    }
    
    static var green: UIColor {
        return UIColor(r: 27, g: 175, b: 0)
    }
    
    static var gold: UIColor {
        return UIColor(r: 224, g: 197, b: 18)
    }
    
    //
    
    static var dark1: UIColor {
        return UIColor(r: 58, g: 65, b: 79)
    }
    
    static var dark2: UIColor {
        return UIColor(r: 58 + 20, g: 65 + 20, b: 79 + 20)
    }
    
    static var tiffanyBlue: UIColor {
        return UIColor(hex: "#76E7D3")
    }
    
    static var gray2: UIColor {
        return UIColor(hex: "#E6E6E6")
    }
    
    static var gray3: UIColor {
        return UIColor(r: 245, g: 245, b: 245)
    }

    static var superLightGray: UIColor {
        return UIColor(r: 250, g: 250, b: 250)
    }
    
    static var blue1: UIColor {
        return UIColor(hex: "#96ACD9")
    }
    
    
    
    // FESTIVAL
    
    static var mainRed: UIColor {
        return UIColor(r: 156, g: 20, b: 25)
    }
    
    static var mainGray: UIColor {
        return UIColor(hex: "#6d6d6d")
    }
    
    //
    
    //
    
    static var transparentHighlight: UIColor {
        return UIColor(r: 255, g: 255, b: 255, a: 0.1)
    }

    

}