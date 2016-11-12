//
//  BounceButton.swift
//  Smilie
//
//  Created by Ufos on 12.11.2016.
//  Copyright © 2016 Ufos. All rights reserved.
//

import UIKit

class BounceButton: UIButton {

    //
    
    private let BOUNCE_DURATION: NSTimeInterval = 0.3
    private let BOUNCE_BACK_DURATION: NSTimeInterval = 0.1
    
    //
    
    private var isAnimating: Bool = false
    
    override var highlighted: Bool {
        didSet {
            if(highlighted) {
                self.bounce()
            } else {
                self.bounceBack()
            }
        }
    }
    
    //
    
    private func bounce() {
        if(!self.isAnimating) {
            self.isAnimating = true
            UIView.animateWithDuration(BOUNCE_DURATION, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                self.transform = CGAffineTransformMakeScale(0.8, 0.8)
            }) { (finished) in
                self.isAnimating = false
                
                if(!self.highlighted) {
                    self.bounceBack()
                }
            }
        }
    }
    
    private func bounceBack() {
        if(!self.isAnimating) {
            self.isAnimating = true
            UIView.animateWithDuration(BOUNCE_BACK_DURATION, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                self.transform = CGAffineTransformMakeScale(1, 1)
            }) { (finished) in
                self.isAnimating = false
            }
        }
    }

}
