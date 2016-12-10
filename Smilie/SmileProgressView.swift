//
//  SmileProgressView.swift
//  Smilie
//
//  Created by Ufos on 19.11.2016.
//  Copyright © 2016 Ufos. All rights reserved.
//

import UIKit

class SmileProgressView: NibView {

    fileprivate let HEIGHT: CGFloat = 40
    
    //
    
    fileprivate var isAnimating: Bool = false
    
    //
    
    override func nibName() -> String {
        return "SmileProgressView"
    }
    

    //
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: HEIGHT, height: HEIGHT))
        self.onProgress(0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func onProgress(_ progress: Double) {
        if let parent = self.superview {
            let height = CGFloat(HEIGHT)
            let width = height + parent.frame.width * CGFloat(progress)
            self.frame = CGRect(x: 0, y: parent.frame.height - height,  width: width, height: height)
            parent.layoutIfNeeded()
        }
    }
    
    func hideAnim() {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions(), animations: {
            self.onProgress(0)
        }, completion: { (completed) in })
    }
    
}
