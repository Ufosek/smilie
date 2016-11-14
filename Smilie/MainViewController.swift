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
    @IBOutlet weak var introView: UIView!
    
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
    
    private var isIntroVisible: Bool!
    
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.smileDetector = SmileDetector()
        
        self.isIntroVisible = true
        
        // keep on smiling for 2 seconds...
        self.smileTimer = DurationTimer(duration: SMILE_TIME, onProgress: { (progress) in
            log("ON PROGRESS = '\(progress)")
            self.smileTimerWidthCnst.constant = CGFloat(progress) * self.view.frame.width
        }, completed: {
            self.makePhoto()
        })
        
        self.camera = MyCamera()
        self.camera.previewImage = { (image) in
            self.smileDetector.detectSmile(image, smileDetected: { (probability) in
                if(self.photoMade == false && self.isIntroVisible == false) {
                    log("SMIEL DETECTED= '\(probability)")
                    
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
                }
            })
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        log("viewWillAppear")
        
        self.keepOnSmilingLabel.alpha = 0.0
        
        // init smile detector timer view
        self.smileTimerWidthCnst.constant = 0
        self.view.layoutIfNeeded()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        log("viewDidAppear")
        
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
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        log("viewWillDisappear")
        
        camera.stop()
    }

    
    override func viewDidFirstAppear() {
        // show insructions
        UIView.animateWithDuration(1.0, delay: 2.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.introView.alpha = 0.0
        }, completion: { (completed) in
            self.isIntroVisible = false
            self.showKeppOnSmiling()
        })
    }
    
    
    private func showKeppOnSmiling() {
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
    
    //
    
    func makePhoto() {
        if(self.photoMade == false) {
            log("MAKE PHOTO")
            self.smileTimer.cancel()
            
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
