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
    
    // 0
    @IBOutlet weak var firstInfoLabelCenterXCnst: NSLayoutConstraint!
    
    // 0
    @IBOutlet weak var secondInfoLabelCenterXCnst: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.firstInfoLabel.alpha = 0.0
        self.secondInfoLabel.alpha = 0.0
        
        
    }
    
    override func viewDidFirstAppear() {
        self.performSegue(withIdentifier: "Start", sender: self)
        
        /*
        self.firstInfoLabelCenterXCnst.constant =  -self.view.frame.width
        self.secondInfoLabelCenterXCnst.constant =  self.view.frame.width
        
        self.view.layoutIfNeeded()
        
        UIView.animate(withDuration: 1.5, delay: 1.5, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.firstInfoLabel.alpha = 1.0
            self.firstInfoLabelCenterXCnst.constant = 0
            
            self.view.layoutIfNeeded()
        }) { (finished) in }
        
        UIView.animate(withDuration: 1.5, delay: 3.0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.secondInfoLabel.alpha = 1.0
            self.secondInfoLabelCenterXCnst.constant = 0
            
            self.view.layoutIfNeeded()
        }) { (finished) in
            
            // delay and ask for permissions
            delay(1.0, withCompletion: {
                MyCamera.checkCameraPermissions({
                    self.performSegue(withIdentifier: "Start", sender: self)
                }) {
                    self.showErrorView("No permissions")
                }
            })
        }*/
    }


}
