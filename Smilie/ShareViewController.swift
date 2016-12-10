//
//  ShareViewController.swift
//  Smilie
//
//  Created by Ufos on 05.11.2016.
//  Copyright © 2016 Ufos. All rights reserved.
//

import UIKit

class ShareViewController: ViewController {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var galleryCheckbox: Checkbox!
    @IBOutlet weak var shareCheckbox: Checkbox!
    @IBOutlet weak var keepOnSmilingLabel: UILabel!
    
    
    fileprivate var camera: MyCamera!
    fileprivate var smileDetector: SmileDetector!
    fileprivate var isSmileDetected: Bool = false
    fileprivate var isCameraAvailable: Bool = false
    
    fileprivate var smileProgressView: SmileProgressView!
    // after first smile detected, wait 2 sec
    fileprivate var smileTimer: DurationTimer!
    
    fileprivate var filteredImage: UIImage!
    
    //
    
    var image: UIImage!
    
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.photoImageView.image = self.image
        
        initCamera()
        initSmile()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.isSmileDetected = false
        
        // start camera
        self.camera.start(self.view, shouldShowView: false, handleError: {
            self.showErrorView("Camera error")
        })
        
        
    }
    override func viewDidFirstAppear() {
        self.showKeppOnSmiling()
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        log("SHAREVIEW DID DISAPPEAR")
        
        self.smileProgressView.onProgress(0)
        self.camera.stop()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.keepOnSmilingLabel.alpha = 0.0
    }
    
    
    //
    
    fileprivate func initCamera() {
        self.smileDetector = SmileDetector()
        self.camera = MyCamera()
        self.camera.previewImage = { (image) in
            self.smileDetector.detectSmile(image, smileDetected: { (probability, faceRect, faceFeature) in
                if(!self.isSmileDetected) {
                    if(probability > SMILE_PROBABILITY_TRESHOLD) {
                        // start timer when smile detected
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
                self.isSmileDetected = true
                self.share()
        })
        
        self.smileProgressView = SmileProgressView(frame: CGRect.zero)
        self.view.addSubview(self.smileProgressView)
        self.smileProgressView.onProgress(0)
    }
    
    
    // image processing
    fileprivate func addMaskOnImage(_ image: UIImage) -> UIImage {
        let mask = UIImage(named: "smile_orange")!
        
        let textFont = UIFont(name: "Helvetica Bold", size: 45)!
        
        // Setup the font attributes that will be later used to dictate how the text should be drawn
        let textFontAttributes = [
            NSFontAttributeName: textFont,
            NSForegroundColorAttributeName: UIColor.white,
            ]
        
        var newImage = image.imageWithImage(mask, atLocation: CGPoint(x: 30, y: 30), withSize: CGSize(width: 150, height: 150))
        newImage = newImage.imageWithText("#0000001", atLocation: CGPoint(x: 190, y: 150/2), withAttributes: textFontAttributes)
        
        return newImage
    }
    
    fileprivate func share() {
        //
        if(galleryCheckbox.isSelected) {
            self.showSmilieLoadingView()
            
            // add filters
            workInBackground({
                self.filteredImage = self.addMaskOnImage(self.image)
            }) {
                delay(2.0, withCompletion: {
                    self.hideSmilieLoadingView()
                    self.smileProgressView.hideAnim()
                    self.performSegueWithIdentifier("ShowGallery", withCompletion: { (destVc) in
                        let galleryVc = (destVc as! GalleryViewController)
                        galleryVc.image = self.filteredImage
                        galleryVc.shouldShareWithFriends = self.shareCheckbox.isSelected
                    })
                })
            }
        } else if(shareCheckbox.isSelected) {
            self.shareWithFriends()
        }

    }
    
    fileprivate func shareWithFriends() {
        if(shareCheckbox.isSelected) {
            
            self.showSmilieLoadingView()
            
            workInBackground({
                self.image = self.addMaskOnImage(self.image)
            }) {
                let activityVc = UIActivityViewController(activityItems: [self.image], applicationActivities: nil)
                activityVc.completionWithItemsHandler = { (activity, success, items, error) in
                    self.hideSmilieLoadingView()
                    self.isSmileDetected = false
                    self.smileProgressView.hideAnim()
                }
                self.present(activityVc, animated: true, completion: nil)
            }
        }
    }
    

    fileprivate func showKeppOnSmiling() {
        // show insructions
        UIView.animate(withDuration: 1.0, delay: 1.0, options: UIViewAnimationOptions(), animations: {
            self.keepOnSmilingLabel.alpha = 1.0
        }, completion: { (completed) in
            // hide
            UIView.animate(withDuration: 1.0, delay: 2.0, options: UIViewAnimationOptions(), animations: {
                self.keepOnSmilingLabel.alpha = 0.0
            }, completion: nil)
        })
    }
    
    // Actions

    
    @IBAction func exitClicked(_ sender: AnyObject) {
        self.camera.stop()
        self.dismissfadeOut()
    }

}
