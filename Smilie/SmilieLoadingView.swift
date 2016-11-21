//
//  SmilieLoadingView.swift
//  Smilie
//
//  Created by Ufos on 22.11.2016.
//  Copyright © 2016 Ufos. All rights reserved.
//

import UIKit

class SmilieLoadingView: NibView {
    
    static let SMILIE_TAG = 192834
    
    @IBOutlet weak var smilieImageView: UIImageView!

    override func nibName() -> String {
        return "SmilieLoadingView"
    }
    
    // rotate image
    func startAnim() {
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        
        rotationAnimation.fromValue = 0.0
        rotationAnimation.toValue = Float(M_PI * 2.0)
        rotationAnimation.duration = 1.0
        rotationAnimation.repeatCount = Float.infinity
        
        self.smilieImageView.layer.addAnimation(rotationAnimation, forKey: "smilie_loading_view_anim_key")
    }
    
}


extension ViewController {
    
    func showSmilieLoadingView() {
        self.hideSmilieLoadingView()
        let smilieLoadingView = SmilieLoadingView(frame: self.view.frame)
        smilieLoadingView.tag = SmilieLoadingView.SMILIE_TAG
        smilieLoadingView.alpha = 0
        self.view.addSubview(smilieLoadingView)
        smilieLoadingView.startAnim()
        
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            smilieLoadingView.alpha = 1
        }, completion: { (completed) in })
    }
    
    func hideSmilieLoadingView() {
        self.view.viewWithTag(SmilieLoadingView.SMILIE_TAG)?.removeFromSuperview()
    }
    
}