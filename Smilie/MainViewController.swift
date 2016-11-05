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
    
    @IBOutlet weak var cameraPreviewView: UIView!
    
    //
    
    private var camera: MyCamera!
    private var smileDetector: SmileDetector!
    
    private var photoMade: Bool!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.smileDetector = SmileDetector()
        
        self.camera = MyCamera()
        self.camera.previewImage = { (image) in
            if(self.photoMade == false) {
                self.smileDetector.detectSmile(image, smileDetected: { (probability) in
                    // make photo when smile detected
                    if(probability > self.SMILE_PROBABILITY_TRESHOLD) {
                        self.camera.makePhoto({ (photoImage) in
                            self.performSegueWithIdentifier("ShowPhoto", withCompletion: { (destVc) in
                                (destVc as! CapturedPhotoViewController).image = photoImage
                            })
                        })
                    }
                })
            }
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.photoMade = false
        
        MyCamera.checkCameraPermissions({ 
            self.camera.start(self.cameraPreviewView, handleError: { 
                self.showErrorView("Camera error")
            })
        }) {
            self.showErrorView("No permissions")
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        camera.stop()
    }



}
