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
    
    
    //
    
    @IBOutlet weak var keepOnSmilingLabel: UILabel!
    @IBOutlet weak var cameraPreviewView: UIView!
    
    //
    
    private var camera: MyCamera!
    private var smileDetector: SmileDetector!
    
    private var photoMade: Bool!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        log("viewDidLoad")
        
        self.smileDetector = SmileDetector()
        
        self.camera = MyCamera()
        self.camera.previewImage = { (image) in
            if(self.photoMade == false) {
                self.smileDetector.detectSmile(image, smileDetected: { (probability) in
                    // make photo when smile detected
                    if(probability > self.SMILE_PROBABILITY_TRESHOLD) {
                        // only 1 photo at once
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
                })
            }
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.keepOnSmilingLabel.alpha = 0.0
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        log("DID APPEAR")
        
        self.photoMade = false
        
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

    @IBAction func galleryClicked(sender: AnyObject) {
        self.performSegueWithIdentifier("ShowGallery", sender: self)
    }


}
