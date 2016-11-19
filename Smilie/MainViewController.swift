//
//  MainViewController.swift
//  Smilie
//
//  Created by Ufos on 05.11.2016.
//  Copyright © 2016 Ufos. All rights reserved.
//

import UIKit


//

let SMILE_PROBABILITY_TRESHOLD: CGFloat = 0.5
// after first smile detected, wait 2 sec
let SMILE_TIME: NSTimeInterval = 1.2

//

class MainViewController: ViewController {
    
    //
    @IBOutlet weak var introView: UIView!
    
    @IBOutlet weak var keepOnSmilingLabel: UILabel!
    @IBOutlet weak var cameraPreviewView: UIView!

    //
    
    private var smileProgressView: SmileProgressView!
    // after first smile detected, wait 2 sec
    private var smileTimer: DurationTimer!
    
    
    private var camera: MyCamera!
    private var smileDetector: SmileDetector!
    
    private var photoMade: Bool!
    

    
    private var isIntroVisible: Bool!
    
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.isIntroVisible = true
        
        //
        self.initCamera()
        self.initSmile()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        
        self.keepOnSmilingLabel.alpha = 0.0
        
        self.smileProgressView.onProgress(0)
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
        
        //
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        camera.stop()
    }

    
    override func viewDidFirstAppear() {
        // hide intro view
        UIView.animateWithDuration(0.3, delay: 1.5, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.introView.transform = CGAffineTransformMakeScale(1.2, 1.2)
        }, completion: { (completed) in
            self.introView.cornerRadius = 30
            UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                self.introView.alpha = 0.0
                self.introView.transform = CGAffineTransformMakeScale(0.01, 0.01)
            }, completion: { (completed) in
                // show insructions
                    self.introView.hidden = true
                    self.isIntroVisible = false
                    self.showKeppOnSmiling()
            })
        })
    }

    
    //
    
    private func initCamera() {
        self.smileDetector = SmileDetector()
        self.camera = MyCamera()
        self.camera.previewImage = { (image) in
            self.smileDetector.detectSmile(image, smileDetected: { (probability) in
                if(self.photoMade == false && self.isIntroVisible == false) {
                    //log("SMIEL DETECTED= '\(probability)")
                    
                    // start timer when smile detected
                    if(probability > SMILE_PROBABILITY_TRESHOLD) {
                        if(!self.smileTimer.isCounting) {
                            self.smileTimer.start()
                        }
                    } else if(self.smileTimer.isCounting) {
                        // no smile :( -> stop timer, no photo will be made
                        self.smileTimer.cancel()
                        
                        self.smileProgressView.hideAnim()
                    }
                }
            })
        }
    }
    
    private func initSmile() {
        // keep on smiling for 2 seconds...
        self.smileTimer = DurationTimer(duration: SMILE_TIME, onProgress: { (progress) in
            self.smileProgressView.onProgress(progress)
        }, completed: {
                self.makePhoto()
        })
        
        
        self.smileProgressView = SmileProgressView(frame: CGRectZero)
        self.view.addSubview(self.smileProgressView)
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
