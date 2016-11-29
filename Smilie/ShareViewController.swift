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
    
    
    private var camera: MyCamera!
    private var smileDetector: SmileDetector!
    private var isSmileDetected: Bool = false
    private var isCameraAvailable: Bool = false
    
    private var smileProgressView: SmileProgressView!
    // after first smile detected, wait 2 sec
    private var smileTimer: DurationTimer!
    
    private var filteredImage: UIImage!
    
    //
    
    var image: UIImage!
    
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.photoImageView.image = self.image
        
        initCamera()
        initSmile()
    }
    
    override func viewDidAppear(animated: Bool) {
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
    
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        log("SHAREVIEW DID DISAPPEAR")
        
        self.smileProgressView.onProgress(0)
        self.camera.stop()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.keepOnSmilingLabel.alpha = 0.0
    }
    
    
    //
    
    private func initCamera() {
        self.smileDetector = SmileDetector()
        self.camera = MyCamera()
        self.camera.previewImage = { (image) in
            self.smileDetector.detectSmile(image, smileDetected: { (probability, faceRect) in
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
    
    private func initSmile() {
        // keep on smiling for 2 seconds...
        self.smileTimer = DurationTimer(duration: SMILE_TIME, onProgress: { (progress) in
            self.smileProgressView.onProgress(progress)
            }, completed: {
                self.isSmileDetected = true
                self.share()
        })
        
        self.smileProgressView = SmileProgressView(frame: CGRectZero)
        self.view.addSubview(self.smileProgressView)
        self.smileProgressView.onProgress(0)
    }
    
    
    // image processing
    private func addMaskOnImage(image: UIImage) -> UIImage {
        let mask = UIImage(named: "smile_orange")!
        
        let textFont = UIFont(name: "Helvetica Bold", size: 45)!
        
        // Setup the font attributes that will be later used to dictate how the text should be drawn
        let textFontAttributes = [
            NSFontAttributeName: textFont,
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            ]
        
        var newImage = image.imageWithMask(mask, atLocation: CGPointMake(30, 30), withSize: CGSizeMake(150, 150))
        newImage = newImage.imageWithText("#0000001", atLocation: CGPointMake(190, 150/2), withAttributes: textFontAttributes)
        
        return newImage
    }
    
    private func share() {
        //
        if(galleryCheckbox.selected) {
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
                        galleryVc.shouldShareWithFriends = self.shareCheckbox.selected
                    })
                })
            }
        } else if(shareCheckbox.selected) {
            self.shareWithFriends()
        }

    }
    
    private func shareWithFriends() {
        if(shareCheckbox.selected) {
            
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
                self.presentViewController(activityVc, animated: true, completion: nil)
            }
        }
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
    
    // Actions

    
    @IBAction func exitClicked(sender: AnyObject) {
        self.camera.stop()
        self.dismissfadeOut()
    }

}
