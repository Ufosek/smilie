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

func isIPAD () -> Bool { return UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad }
func isIPhone() -> Bool { return !isIPAD() }

// Log only when DEV

func log(string: String) {
    let formatter = NSDateFormatter()
    formatter.dateFormat = "hh:mm:ss:SSS"
    print("[\(formatter.stringFromDate(NSDate()))] : " +  string)
}

//

func stringForKey(key: String) -> String {
    return NSLocalizedString(key, comment: "")
}


// time in msc
func delay(time: NSTimeInterval, withCompletion completion: () -> ()) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(UInt64(time) * NSEC_PER_SEC)), dispatch_get_main_queue(), { () -> Void in
        completion()
    })
}


//


// do smth in background threads (queues)
func workInBackground(work: (()->())?, completed: (()->())?) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
        // do the time consuming work
        work?()
        
        // complete in main queue (thread)
        dispatch_async(dispatch_get_main_queue(), { 
            completed?()
        })
    }
}


//
let degreesToRadians: (CGFloat) -> CGFloat = {
    return $0 / 180.0 * CGFloat(M_PI)
}


//

extension String {
    // remove html tags
    var plainText: String {
        let text = self.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: .RegularExpressionSearch, range: nil)
        return text.stringByReplacingOccurrencesOfString("\n", withString: "")
    }
}


//

extension UIScrollView {
    // adjust contentOffset to make view be just above keyboard
    func offsetAdjustToView(view: UIView, withKeyboardheight keyboardHeight: CGFloat) -> CGFloat {
        let pos = view.superview!.convertPoint(view.frame.origin, toView: self.superview!)
        return self.contentOffset.y - (self.superview!.frame.height - keyboardHeight - pos.y - view.frame.height)
    }
}

//

extension CGRect {
    func resize(tw tw: CGFloat, th: CGFloat) -> CGRect{
        return CGRectMake(self.origin.x, self.origin.y, self.size.width + tw, self.size.height + th)
    }
    
    func rectWithHeight(height: CGFloat) -> CGRect{
        return CGRectMake(self.origin.x, self.origin.y, self.size.width, height)
    }
    
    func move(dx: CGFloat, dy: CGFloat) -> CGRect{
        return CGRectMake(self.origin.x + dx, self.origin.y + dy, self.size.width, self.size.height)
    }
    
    func setX(x: CGFloat) -> CGRect{
        return CGRectMake(x, self.origin.y, self.size.width, self.size.height)
    }
}

//

extension UIFont {
    
    func bold(withSize withSize: CGFloat=0) -> UIFont {
        let descriptor = self.fontDescriptor().fontDescriptorWithSymbolicTraits(UIFontDescriptorSymbolicTraits.TraitBold)
        return UIFont(descriptor: descriptor, size: withSize)
    }
}

//

extension UILabel {
    func configurePreferredMaxLayoutWidth() {
        self.preferredMaxLayoutWidth = self.frame.width
    }
}


//

extension NSData {
    var hexString: String {
        let bytes = UnsafeBufferPointer<UInt8>(start: UnsafePointer(self.bytes), count:self.length)
        return bytes.map { String(format: "%02hhx", $0) }.reduce("", combine: { $0 + $1 })
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
    func enable(enabled: Bool) {
        self.enabled = enabled
        self.alpha = enabled ? 1 : 0.2
    }
}

//


//

protocol ScrollDelegate: class {
    func didScroll(pos: CGFloat)
}

//


