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
    
    fileprivate let BOUNCE_DURATION: TimeInterval = 0.3
    fileprivate let BOUNCE_BACK_DURATION: TimeInterval = 0.1
    
    //
    
    fileprivate var isAnimating: Bool = false
    
    override var isHighlighted: Bool {
        didSet {
            if(isHighlighted) {
                self.bounce()
            } else {
                self.bounceBack()
            }
        }
    }
    
    //
    
    fileprivate func bounce() {
        if(!self.isAnimating) {
            self.isAnimating = true
            UIView.animate(withDuration: BOUNCE_DURATION, delay: 0, options: UIViewAnimationOptions(), animations: {
                self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }) { (finished) in
                self.isAnimating = false
                
                if(!self.isHighlighted) {
                    self.bounceBack()
                }
            }
        }
    }
    
    fileprivate func bounceBack() {
        if(!self.isAnimating) {
            self.isAnimating = true
            UIView.animate(withDuration: BOUNCE_BACK_DURATION, delay: 0, options: UIViewAnimationOptions(), animations: {
                self.transform = CGAffineTransform(scaleX: 1, y: 1)
            }) { (finished) in
                self.isAnimating = false
            }
        }
    }

}
