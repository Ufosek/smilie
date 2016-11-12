//
//  MainViewController.swift
//  Smilie
//
//  Created by Ufos on 05.11.2016.
//  Copyright © 2016 Ufos. All rights reserved.
//

import UIKit

class MainViewController: ViewController {

    private let SMILE_PROBABILITY_TRESHOLD: CGFloat = 0.5
    
    // after first smile detected, wait 2 sec
    private let SMILE_TIME: NSTimeInterval = 2.0
    
    //
    
    @IBOutlet weak var keepOnSmilingLabel: UILabel!
    @IBOutlet weak var cameraPreviewView: UIView!
    
    // from 0 to 1
    @IBOutlet weak var smileTimerWidthCnst: NSLayoutConstraint!
    //
    
    private var camera: MyCamera!
    private var smileDetector: SmileDetector!
    
    private var photoMade: Bool!
    
    // after first smile detected, wait 2 sec
    private var smileTimer: DurationTimer!
    
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.smileDetector = SmileDetector()
        
        // keep on smiling for 2 seconds...
        self.smileTimer = DurationTimer(duration: SMILE_TIME, onProgress: { (progress) in
            self.smileTimerWidthCnst.constant = CGFloat(progress) * self.view.frame.width
        }, completed: {
            self.makePhoto()
        })
        
        self.camera = MyCamera()
        self.camera.previewImage = { (image) in
            if(self.photoMade == false) {
                self.smileDetector.detectSmile(image, smileDetected: { (probability) in
                    // start timer when smile detected
                    if(probability > self.SMILE_PROBABILITY_TRESHOLD) {
                        if(!self.smileTimer.isCounting) {
                            self.smileTimer.start()
                        }
                    } else {
                        // no smile :( -> stop timer, no photo will be made
                        self.smileTimer.cancel()
                        UIView.animateWithDuration(0.5, animations: { 
                            self.smileTimerWidthCnst.constant = 0
                            self.view.layoutIfNeeded()
                        })
                    }
                })
            }
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.keepOnSmilingLabel.alpha = 0.0
        
        // init smile detector timer view
        self.smileTimerWidthCnst.constant = 0
        self.view.layoutIfNeeded()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // make another photo
        self.photoMade = false
        
        // init camera
        MyCamera.checkCameraPermissions({ 
            self.camera.start(self.cameraPreviewView, handleError: {
                self.showErrorView("Camera error")
            })
        }) {
            self.showErrorView("No permissions")
        }
        
        // show insructions
        UIView.animateWithDuration(1.0, delay: 1.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.keepOnSmilingLabel.alpha = 1.0
        }, completion: { (completed) in
            // hide
            UIView.animateWithDuration(1.0, delay: 2.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                self.keepOnSmilingLabel.alpha = 0.0
            }, completion: nil)
        })
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        camera.stop()
    }

    
    //
    
    func makePhoto() {
        if(self.photoMade == false) {
            self.camera.makePhoto({ (photoImage) in
                self.photoMade = true
                // move to next vc
                self.performSegueWithIdentifier("ShowPhoto", withCompletion: { (destVc) in
                    (destVc as! CapturedPhotoViewController).image = photoImage
                })
            })
        }
    }
    
    
    // actions

    @IBAction func galleryClicked(sender: AnyObject) {
        self.performSegueWithIdentifier("ShowGallery", sender: self)
    }


}
