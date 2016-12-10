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

class CapturedPhotoViewController: ViewController {

    fileprivate let SHARE_COLOR_VIEW_ANIM_DURATION: TimeInterval = 0.8
    fileprivate let NUMBER_ANIM_DURATION: TimeInterval = 1.0
    
    
    //

    //
    @IBOutlet weak var keepOnSmilingLabel: UILabel!
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var filteredPhotoImageView: UIImageView!

    @IBOutlet weak var numberLabel: SACountingLabel!
    @IBOutlet weak var yellLabel: UILabel!

    @IBOutlet weak var counterView: UIView!
    //
    
    fileprivate var smileProgressView: SmileProgressView!
    // after first smile detected, wait 2 sec
    fileprivate var smileTimer: DurationTimer!
    
    fileprivate var camera: MyCamera!
    fileprivate var smileDetector: SmileDetector!

    fileprivate var isSmileDetected: Bool = false

    fileprivate var filteredImageManager: FilteredImageManager!
    
    //
    
    fileprivate var filteredImage: UIImage!
    
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
    }
    
    override func viewDidFirstAppear() {
        log("CviewDidFirstAppear size = \(self.view.frame)")
        
        self.checkSmile()
        
        self.camera = MyCamera()
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
        
        self.keepOnSmilingLabel.alpha = 0.0
        self.yellLabel.alpha = 0.0
        self.counterView.alpha = 0.0
    }
    
    //
    
    fileprivate func checkSmile() {
        self.showSmilieLoadingView()
        SmileDetector().detectSmile(self.image) { (probability, faceFeatures) in
            if(probability > 0.5) {

                // processing image
                self.filteredImageManager = FilteredImageManager(image: self.image, viewSize: self.view.frame, faceFeatures: faceFeatures)
                self.filteredImageManager.processImage({ (filteredImage) in
                    // hide loading and show water fountains
                    self.hideSmilieLoadingView(removed: {
                        self.showYell()
                        self.animateNumber()
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
        }
    }
    
    fileprivate func initCamera() {
        self.smileDetector = SmileDetector()
        self.camera.previewImage = { (image) in
            self.smileDetector.detectSmile(image, smileDetected: { (probability, faceFeatures) in
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
    
    fileprivate func initSmileDetecting() {
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
    
    
    func showYell() {
        // init yell text
        let yells = ["Nice!", "That is great!", ":)))", "Give me more", "ENDORPHINE++", "Keep on smiling"]
        let rand = Int(arc4random_uniform(UInt32(yells.count)))
        self.yellLabel.text = yells[rand]
        
        
        self.yellLabel.alpha = 1
        // show insructions
        
        UIView.animate(withDuration: 1.5, delay: 0.0, options: UIViewAnimationOptions(), animations: {
            self.yellLabel.alpha = 0.0
            self.yellLabel.transform = CGAffineTransform(scaleX: 2, y: 2)
            }, completion: { (completed) in
        })
    }

    
    func animateNumber() {
        self.counterView.alpha = 1
        let currentNumber = DataManager.currentPhotoNumber
        
        numberLabel.countFrom(fromValue: 0, to: Float(currentNumber), withDuration: NUMBER_ANIM_DURATION, andAnimationType: SACountingLabel.AnimationType.EaseInOut, andCountingType: SACountingLabel.CountingType.Int)
        
        DataManager.incrementCurrentPhotoNumber()
    }
    
    
    fileprivate func showKeppOnSmiling() {
        // show insructions
        UIView.animate(withDuration: 1.0, delay: 3.0, options: UIViewAnimationOptions(), animations: {
            self.keepOnSmilingLabel.alpha = 1.0
        }, completion: { (completed) in
            // hide
            UIView.animate(withDuration: 1.0, delay: 2.0, options: UIViewAnimationOptions(), animations: {
                self.keepOnSmilingLabel.alpha = 0.0
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
