//
//  SmileProgressView.swift
//  Smilie
//
//  Created by Ufos on 19.11.2016.
//  Copyright © 2016 Ufos. All rights reserved.
//

import UIKit

class SmileProgressView: NibView {

    private let HEIGHT: CGFloat = 40
    
    //
    
    private var isAnimating: Bool = false
    
    //
    
    override func nibName() -> String {
        return "SmileProgressView"
    }
    

    //
    
    override init(frame: CGRect) {
        super.init(frame: CGRectMake(0, 0, HEIGHT, HEIGHT))
        self.onProgress(0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func onProgress(progress: Double) {
        if let parent = self.superview {
            let height = CGFloat(HEIGHT)
            let width = height + parent.frame.width * CGFloat(progress)
            self.frame = CGRectMake(0, parent.frame.height - height,  width, height)
            parent.layoutIfNeeded()
        }
    }
    
    func hideAnim() {
        UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.onProgress(0)
        }, completion: { (completed) in })
    }
    
}
