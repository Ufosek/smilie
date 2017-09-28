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
let SMILE_TIME: TimeInterval = 1.2

//

class MainViewController: ViewController {
    
    //
    @IBOutlet weak var introView: UIView!
    
    @IBOutlet weak var keepOnSmilingLabel: UILabel!
    @IBOutlet weak var cameraPreviewView: UIView!

    // 8; -x
    @IBOutlet weak var keepOnSmilingTrailingCnst: NSLayoutConstraint!
    //
    
    fileprivate var smileProgressView: SmileProgressView!
    // after first smile detected, wait 2 sec
    fileprivate var smileTimer: DurationTimer!
    
    
    fileprivate var camera: MyCamera!
    fileprivate var faceFeaturesDetector: FaceFeaturesDetector!
    
    fileprivate var photoMade: Bool!
    

    fileprivate var isSmileDetected: Bool = false
    
    fileprivate var isIntroVisible: Bool!
    
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.isIntroVisible = true
        
        //
        self.initCamera()
        self.initSmile()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.smileProgressView.onProgress(0)
        self.keepOnSmilingTrailingCnst.constant = 8
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // make another photo
        self.photoMade = false
        self.isSmileDetected = false
        
        // init camera
        MyCamera.checkCameraPermissions({
            log("START CAMERA")
            self.camera.start(self.cameraPreviewView, handleError: {
                self.showErrorView("Camera error")
            })
        }) {
            self.showErrorView("No permissions")
        }
        
        //
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        camera.stop()
    }

    
    override func viewDidFirstAppear() {
        // hide intro view
        UIView.animate(withDuration: 0.3, delay: 0.5, options: UIViewAnimationOptions(), animations: {
            self.introView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }, completion: { (completed) in
            self.introView.cornerRadius = 30
            UIView.animate(withDuration: 1.0, delay: 0.0, options: UIViewAnimationOptions(), animations: {
                self.introView.alpha = 0.0
                self.introView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }, completion: { (completed) in
                // show insructions
                self.introView.isHidden = true
                self.isIntroVisible = false
                self.keepOnSmilingLabel.alpha = 1.0
            })
        })
        
        self.keepOnSmilingLabel.alpha = 0.0
    }

    
    //
    
    fileprivate func initCamera() {
        self.faceFeaturesDetector = FaceFeaturesDetector()
        self.camera = MyCamera()
        self.camera.previewImage = { (image) in
            self.faceFeaturesDetector.detectSmile(image, smileDetected: { (probability, faceFeatures) in
                
                if(self.photoMade == false && self.isIntroVisible == false && self.isSmileDetected == false) {
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
                        
                        // update SMILE TO SHARE text
                        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions(), animations: {
                            self.keepOnSmilingTrailingCnst.constant = 8
                            self.view.layoutIfNeeded()
                        }, completion: { (completed) in })
                    }
                }
            })
        }
    }
    
    fileprivate func initSmile() {
        // keep on smiling for 2 seconds...
        self.smileTimer = DurationTimer(duration: SMILE_TIME, onProgress: { (progress) in
            self.smileProgressView.onProgress(progress)
            
            // update SMILE TO SHARE
            let textPos = self.view.frame.width - self.keepOnSmilingLabel.frame.width
            let smiliePos = self.view.frame.width * CGFloat(progress) + 50
            
            self.keepOnSmilingTrailingCnst.constant = min(8, -(smiliePos - textPos))
            self.keepOnSmilingLabel.setNeedsLayout()
        }, completed: {
                self.smileTimer.cancel()
                self.isSmileDetected = true
                self.makePhoto()
        })
        
        
        self.smileProgressView = SmileProgressView(frame: CGRect.zero)
        self.view.addSubview(self.smileProgressView)
    }
    
    //
    
    func makePhoto() {
        if(self.photoMade == false) {
            self.smileTimer.cancel()
            
            // iphone7: size = (2320.0, 3088.0)
            // iphone 5: size = (960.0, 1280.0)
            self.camera.makePhoto({ (photoImage) in
                log("PHOTO DONE size = \(photoImage.size)")
                self.photoMade = true

                self.performSegueWithIdentifier("ShowPhoto", withCompletion: { (destVc) in
                    (destVc as! CapturedPhotoViewController).image = photoImage
                })
            })
        }
    }
    
    
    // actions

    @IBAction func galleryClicked(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "ShowGallery", sender: self)
    }


}
