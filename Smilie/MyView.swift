//
//  MyView.swift
//  MakeAppBiz
//
//  Created by Ufos on 03.03.2016.
//  Copyright © 2016 makeapp. All rights reserved.
//

import Foundation
import UIKit


//

extension UIView {
    
    func updateView() {
        self.setNeedsUpdateConstraints()
        self.updateConstraintsIfNeeded()
        
        // update layout
        self.layoutIfNeeded()
        self.setNeedsLayout()
    }
    
    var autolayoutCalculatedHeight: CGFloat {
        self.setNeedsUpdateConstraints()
        self.updateConstraintsIfNeeded()
        
        // update layout
        self.layoutIfNeeded()
        self.setNeedsLayout()
        
        // makes magic
        // !!! REMEMBER !!! it will only work when constraints are made from top to bottom !
        let size = self.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        
        return size.height
    }
    
    func autolayoutCalculatedHeight(extraHeight: CGFloat=0) {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.x, self.frame.width, self.autolayoutCalculatedHeight + extraHeight)
    }
    
    //
    
    func loadViewFromNib(nibName: String) -> UIView {
        return NSBundle.mainBundle().loadNibNamed(nibName, owner: self, options: nil).last as! UIView
    }
    
    
    //
    
    func testPoint(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        if(self.pointInside(point, withEvent: event) == true && self.tag > 0) {
            return true
        }
        for sview in self.subviews {
            if(sview.tag > 0 && sview.testPoint(self.convertPoint(point, toView: sview), withEvent: event) == true) {
                return true
            }
        }
        return false
    }
    
    //
    
    func move(x x: CGFloat, y: CGFloat) {
        self.frame = CGRect(x: self.frame.origin.x + x, y: self.frame.origin.y + y, width: self.bounds.width, height: self.bounds.height)
    }
    
    func setPos(x x: CGFloat, y: CGFloat) {
        self.frame = CGRect(x: x, y: y, width: self.bounds.width, height: self.bounds.height)
    }
    
    func resize(tw tw: CGFloat, th: CGFloat) {
        self.frame = self.frame.resize(tw: tw, th: th)
    }
    
    func setSize(w w: CGFloat, h: CGFloat) {
        self.frame = CGRect(x: self.frame.origin.x , y: self.frame.origin.y, width: w, height: h)
    }
    
    //
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor {
        get {
            return UIColor.gray
        }
        set {
            self.layer.borderColor = newValue.CGColor
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    // good only when size is defined and constant
    @IBInspectable var hasShadow: Bool {
        get {
            return true
        }
        set {
            if(newValue == true) {
                self.layer.shadowColor = UIColor.blackColor().CGColor
                self.layer.shadowOffset = CGSizeMake(0, 0)
                self.layer.shadowOpacity = 0.4
                self.layer.masksToBounds = false
            }
        }
    }
    
    
}
