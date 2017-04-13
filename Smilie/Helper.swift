//
//  Helper.swift
//  Shareink
//
//  Created by ufos on 30.06.2015.
//  Copyright (c) 2015 ufos. All rights reserved.
//

import Foundation
import UIKit


//
// in viewDidlayoutSubviews
// autocalculate height
// changing headerView frame doesnt work
// you have to re-set it
/*
let headerView = self.tableView.tableHeaderView
headerView?.autolayoutCalculatedHeight(isIPAD() ? 200 : 0)
self.tableView.tableHeaderView = headerView
*/

//

func isIPAD () -> Bool { return UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad }
func isIPhone() -> Bool { return !isIPAD() }

// Log only when DEV

func log(_ string: String) {
    let formatter = DateFormatter()
    formatter.dateFormat = "hh:mm:ss:SSS"
    print("[\(formatter.string(from: Date()))] : " +  string)
}

//

func rand(max: Int) -> Int {
    return Int(arc4random_uniform(UInt32(max)))
}


//

func stringForKey(_ key: String) -> String {
    return NSLocalizedString(key, comment: "")
}


// time in msc
func delay(_ time: TimeInterval, withCompletion completion: @escaping () -> ()) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(UInt64(time) * NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: { () -> Void in
        completion()
    })
}


//


// do smth in background threads (queues)
func workInBackground(_ work: (()->())?, completed: (()->())?) {
    DispatchQueue.global(qos: .background).async {
        // do the time consuming work
        work?()
        
        // complete in main queue (thread)
        DispatchQueue.main.async(execute: {
            completed?()
        })
    }
}


//
let degreesToRadians: (CGFloat) -> CGFloat = {
    return $0 / 180.0 * CGFloat(M_PI)
}


//

extension Array {
    var randomElem: AnyObject {
        return self[rand(max: self.count)] as AnyObject
    }
}


//

extension String {
    // remove html tags
    var plainText: String {
        let text = self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
        return text.replacingOccurrences(of: "\n", with: "")
    }
}


//

extension UIScrollView {
    // adjust contentOffset to make view be just above keyboard
    func offsetAdjustToView(_ view: UIView, withKeyboardheight keyboardHeight: CGFloat) -> CGFloat {
        let pos = view.superview!.convert(view.frame.origin, to: self.superview!)
        return self.contentOffset.y - (self.superview!.frame.height - keyboardHeight - pos.y - view.frame.height)
    }
}

//

extension CGRect {
    func resize(tw: CGFloat, th: CGFloat) -> CGRect{
        return CGRect(x: self.origin.x, y: self.origin.y, width: self.size.width + tw, height: self.size.height + th)
    }
    
    func rectWithHeight(_ height: CGFloat) -> CGRect{
        return CGRect(x: self.origin.x, y: self.origin.y, width: self.size.width, height: height)
    }
    
    func move(_ dx: CGFloat, dy: CGFloat) -> CGRect{
        return CGRect(x: self.origin.x + dx, y: self.origin.y + dy, width: self.size.width, height: self.size.height)
    }
    
    func setX(_ x: CGFloat) -> CGRect{
        return CGRect(x: x, y: self.origin.y, width: self.size.width, height: self.size.height)
    }
}

//

extension UIFont {
    
    func bold(withSize: CGFloat=0) -> UIFont {
        let descriptor = self.fontDescriptor.withSymbolicTraits(UIFontDescriptorSymbolicTraits.traitBold)
        return UIFont(descriptor: descriptor!, size: withSize)
    }
}

//

extension UILabel {
    func configurePreferredMaxLayoutWidth() {
        self.preferredMaxLayoutWidth = self.frame.width
    }
}


//

extension Data {
    var hexString: String {
        let bytes = UnsafeBufferPointer<UInt8>(start: (self as NSData).bytes.bindMemory(to: UInt8.self, capacity: self.count), count:self.count)
        return bytes.map { String(format: "%02hhx", $0) }.reduce("", { $0 + $1 })
    }
}

//


extension Int {
    var timeString: String {
        let h = self / 60
        let m = self % 60
        
        return ((h < 10) ? "0" : "") + "\(h):" + ((m < 10) ? "0" : "") + "\(m)"
    }
}

//

// safe [0] checking
extension Array {
    subscript (safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

//

extension UIButton {
    func enable(_ enabled: Bool) {
        self.isEnabled = enabled
        self.alpha = enabled ? 1 : 0.2
    }
}

//


//

protocol ScrollDelegate: class {
    func didScroll(_ pos: CGFloat)
}

//


//

