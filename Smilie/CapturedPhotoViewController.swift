//
//  ImageViewController.swift
//  Smilie
//
//  Created by Ufos on 31.10.2016.
//  Copyright © 2016 Ufos. All rights reserved.
//

import UIKit
import GPUImage
import SACountingLabel
import AudioToolbox


class CapturedPhotoViewController: ViewController {

    fileprivate let SHARE_COLOR_VIEW_ANIM_DURATION: TimeInterval = 0.8
    fileprivate let NUMBER_ANIM_DURATION: TimeInterval = 1.0
    
    
    //

    //
    @IBOutlet weak var shakeItLabel: UILabel!
    @IBOutlet weak var smileToShareLabel: UILabel!
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var filteredPhotoImageView: UIImageView!

    @IBOutlet weak var numberLabel: SACountingLabel!

    @IBOutlet weak var counterView: UIView!
    
    // 8 ; -x
    @IBOutlet weak var smileToShareTrailingCnst: NSLayoutConstraint!
    
    //
    
    fileprivate var smileProgressView: SmileProgressView!
    // after first smile detected, wait 2 sec
    fileprivate var smileTimer: DurationTimer!
    
    fileprivate var camera: MyCamera!
    fileprivate var faceFeaturesDetector: FaceFeaturesDetector!

    fileprivate var isSmileDetected: Bool = false

    fileprivate var filteredImageManager: FilteredImageManager!
    
    //
    
    fileprivate var filteredImage: UIImage!
    
    
    //
    
    var image: UIImage! {
        didSet {
            log("DID SET")
            self.filteredImage = self.image
        }
    }
    
    var faceRect: CGRect!

    
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        log("viewDidLoad")
        
        // set current image without filters in background
        self.photoImageView.image = image
        //self.photoImageView.alpha = 0.0
        
        // not visible filtered
        self.filteredPhotoImageView.alpha = 0
        
        // to get shake event
        self.becomeFirstResponder()
    }
    
    override func viewDidFirstAppear() {
        log("CviewDidFirstAppear size = \(self.view.frame)")
        
        self.checkSmile()
        
        self.camera = MyCamera()
        
        self.smileToShareLabel.alpha = 0.0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        log("CAPTURED DID APPEAR")
        
        self.isSmileDetected = false
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        self.smileProgressView?.onProgress(0)
        self.camera.stop()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.shakeItLabel.alpha = 0.0
        self.counterView.alpha = 0.0
    }
    
    
    // SHAKE
    
    // We are willing to become first responder to get shake motion
    override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }
    
    // Enable detection of shake motion
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            log("START ADD EYES")
            
            self.filteredImageManager.addRandomEeyes { (filteredImage) in
                self.filteredImage = filteredImage
                self.filteredPhotoImageView.image = self.filteredImage
                log("END ADD EYES")
            }
        }
    }
    
    //
    
    fileprivate func checkSmile() {
        self.showSmilieLoadingView()
        FaceFeaturesDetector().detectSmile(self.image, smileDetected: { (probability, faceFeatures) in
            if(probability > 0.5) {

                // processing image
                self.filteredImageManager = FilteredImageManager(image: self.image, currentNumber: DataManager.currentPhotoNumber, viewSize: self.view.frame, faceFeatures: faceFeatures)
                self.filteredImageManager.processImage({ (filteredImage) in
                    DataManager.incrementCurrentPhotoNumber()
                    // hide loading and show water fountains
                    self.hideSmilieLoadingView(removed: {
                        //self.animateNumber()
                        self.showKeppOnSmiling()
                        
                        // start camera (to detect smile)
                        self.camera.start(self.view, shouldShowView: false, handleError: {
                            self.showErrorView("Camera error")
                        })
                    })
                    self.filteredImage = filteredImage
                    
                    self.showFilteredPhoto()
                })

                // init camera
                self.initCamera()
                self.initSmileDetecting()
                
                // show current photo with anim
                UIView.animate(withDuration: 0.5, animations: {
                    self.photoImageView.alpha = 1.0
                })
            } else {
                self.hideSmilieLoadingView()
                self.camera.stop()
                self.showErrorView("No smile :(")
                self.dismissfadeOut()
            }
        })
    }
    
    fileprivate func initCamera() {
        self.faceFeaturesDetector = FaceFeaturesDetector()
        self.camera.previewImage = { (image) in
            self.faceFeaturesDetector.detectSmile(image, smileDetected: { (probability, faceFeatures) in
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
                        
                        // update SMILE TO SHARE text
                        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions(), animations: {
                            self.smileToShareTrailingCnst.constant = 8
                            self.view.layoutIfNeeded()
                        }, completion: { (completed) in })
                    }
                }
            })
            
            //
            
            
        }
    }
    
    fileprivate func initSmileDetecting() {
        // keep on smiling for 2 seconds...
        self.smileTimer = DurationTimer(duration: SMILE_TIME, onProgress: { (progress) in
            self.smileProgressView.onProgress(progress)
            
            // update SMILE TO SHARE
            let textPos = self.view.frame.width - self.smileToShareLabel.frame.width
            let smiliePos = self.view.frame.width * CGFloat(progress) + 50

            self.smileToShareTrailingCnst.constant = min(8, -(smiliePos - textPos))
            self.smileToShareLabel.setNeedsLayout()
            
        }, completed: {
            self.isSmileDetected = true
            self.share()
        })
        
        self.smileProgressView = SmileProgressView(frame: CGRect.zero)
        self.view.addSubview(self.smileProgressView)
        self.smileProgressView.onProgress(0)
    }

    
    func animateNumber() {
        self.counterView.alpha = 1
        let currentNumber = DataManager.currentPhotoNumber
        
        numberLabel.countFrom(fromValue: 0, to: Float(currentNumber), withDuration: NUMBER_ANIM_DURATION, andAnimationType: SACountingLabel.AnimationType.EaseInOut, andCountingType: SACountingLabel.CountingType.Int)
        
        DataManager.incrementCurrentPhotoNumber()
    }
    
    
    fileprivate func showKeppOnSmiling() {
        // show insructions
        UIView.animate(withDuration: 1.0, delay: 2.0, options: UIViewAnimationOptions(), animations: {
            self.shakeItLabel.alpha = 1.0
        }, completion: { (completed) in
            // hide
            UIView.animate(withDuration: 1.0, delay: 1.0, options: UIViewAnimationOptions(), animations: {
                self.shakeItLabel.alpha = 0.0
            }, completion: nil)
        })
    }
    
    fileprivate func showFilteredPhoto() {
        // show filterd photo
        self.filteredPhotoImageView.image = self.filteredImage

        let shareViewInitSize: CGFloat = 50
        let animView = UIView(frame: CGRect(x: (self.view.frame.width - shareViewInitSize)/2, y: (self.view.frame.height - shareViewInitSize)/2, width: shareViewInitSize, height: shareViewInitSize))
        animView.cornerRadius = shareViewInitSize/2
        animView.backgroundColor = UIColor.orange
        animView.transform = CGAffineTransform(scaleX: 1, y: 1)
        self.view.insertSubview(animView, aboveSubview: self.photoImageView)
        
        self.filteredPhotoImageView.backgroundColor = UIColor.yellowBackground
        
        UIView.animate(withDuration: SHARE_COLOR_VIEW_ANIM_DURATION, delay: 0, options: UIViewAnimationOptions(), animations: {
            let scale = 3 * (self.view.frame.height / animView.frame.height)
            animView.transform = CGAffineTransform(scaleX: scale, y: scale)
            self.filteredPhotoImageView.alpha = 1.0
            self.smileToShareLabel.alpha = 1.0
        }) { (finished) in }
    }
    
    //
    
    
    fileprivate func share() {
        if(self.filteredImageManager.isProcessing == false) {
            let activityVc = UIActivityViewController(activityItems: [self.filteredImage], applicationActivities: nil)
            activityVc.completionWithItemsHandler = { (activity, success, items, error) in
                self.hideSmilieLoadingView()
                self.isSmileDetected = false
                self.smileProgressView.hideAnim()
                self.smileToShareTrailingCnst.constant = 8
            }
            self.present(activityVc, animated: true, completion: nil)
        }
    }
    

    // Actions
    
    @IBAction func backClicked(_ sender: AnyObject) {
        self.camera.stop()
        self.dismissfadeOut()
    }
    


}
