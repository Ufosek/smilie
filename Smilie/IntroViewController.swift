//
//  IntroViewController.swift
//  Smilie
//
//  Created by Ufos on 14.11.2016.
//  Copyright © 2016 Ufos. All rights reserved.
//

import UIKit

class IntroViewController: ViewController {

    //
    
    @IBOutlet weak var firstInfoLabel: UILabel!
    @IBOutlet weak var secondInfoLabel: UILabel!
    
    // -30
    @IBOutlet weak var firstInfoLabelCenterXCnst: NSLayoutConstraint!
    
    // 50
    @IBOutlet weak var secondInfoLabelCenterXCnst: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.firstInfoLabel.alpha = 0.0
        self.secondInfoLabel.alpha = 0.0
        
        
    }
    
    override func viewDidFirstAppear() {

        self.firstInfoLabelCenterXCnst.constant =  -self.view.frame.width
        self.secondInfoLabelCenterXCnst.constant =  self.view.frame.width
        
        self.view.layoutIfNeeded()
        
        UIView.animateWithDuration(1.5, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.firstInfoLabel.alpha = 1.0
            self.firstInfoLabelCenterXCnst.constant = -30
            
            self.view.layoutIfNeeded()
        }) { (finished) in }
        
        UIView.animateWithDuration(1.5, delay: 1.5, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.secondInfoLabel.alpha = 1.0
            self.secondInfoLabelCenterXCnst.constant = 50
            
            self.view.layoutIfNeeded()
        }) { (finished) in
            delay(1.0, withCompletion: {
                self.performSegueWithIdentifier("Start", sender: self)
            })
        }
    }


}
