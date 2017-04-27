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
    
    @IBOutlet weak var smileImageView: UIImageView!
    @IBOutlet weak var textLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.smileImageView.alpha = 0.0
        self.textLabel.alpha = 0.0
    }
    
    override func viewDidFirstAppear() {
        
        
        self.view.layoutIfNeeded()
        
        UIView.animate(withDuration: 1.5, delay: 1.5, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.smileImageView.alpha = 1.0
            
            self.view.layoutIfNeeded()
        }) { (finished) in }
        
        
        UIView.animate(withDuration: 1.5, delay: 3.5, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.textLabel.alpha = 1.0
            
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
        }
    }


}
