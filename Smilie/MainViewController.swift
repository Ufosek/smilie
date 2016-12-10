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

    //
    
    fileprivate var smileProgressView: SmileProgressView!
    // after first smile detected, wait 2 sec
    fileprivate var smileTimer: DurationTimer!
    
    
    fileprivate var camera: MyCamera!
    fileprivate var smileDetector: SmileDetector!
    
    fileprivate var photoMade: Bool!
    

    
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

        
        self.keepOnSmilingLabel.alpha = 0.0
        
        self.smileProgressView.onProgress(0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        camera.stop()
    }

    
    override func viewDidFirstAppear() {
        // hide intro view
        UIView.animate(withDuration: 0.3, delay: 1.5, options: UIViewAnimationOptions(), animations: {
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
                    self.showKeppOnSmiling()
            })
        })
    }

    
    //
    
    fileprivate func initCamera() {
        self.smileDetector = SmileDetector()
        self.camera = MyCamera()
        self.camera.previewImage = { (image) in
            self.smileDetector.detectSmile(image, smileDetected: { (probability, faceFeatures) in
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
    
    fileprivate func initSmile() {
        // keep on smiling for 2 seconds...
        self.smileTimer = DurationTimer(duration: SMILE_TIME, onProgress: { (progress) in
            self.smileProgressView.onProgress(progress)
        }, completed: {
                self.makePhoto()
        })
        
        
        self.smileProgressView = SmileProgressView(frame: CGRect.zero)
        self.view.addSubview(self.smileProgressView)
    }

    
    fileprivate func showKeppOnSmiling() {
        // show insructions
        UIView.animate(withDuration: 1.0, delay: 2.0, options: UIViewAnimationOptions(), animations: {
            self.keepOnSmilingLabel.alpha = 1.0
            }, completion: { (completed) in
                // hide
                UIView.animate(withDuration: 1.0, delay: 2.0, options: UIViewAnimationOptions(), animations: {
                    self.keepOnSmilingLabel.alpha = 0.0
                    }, completion: nil)
        })
    }
    
    //
    
    func makePhoto() {
        if(self.photoMade == false) {
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

    @IBAction func galleryClicked(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "ShowGallery", sender: self)
    }


}
