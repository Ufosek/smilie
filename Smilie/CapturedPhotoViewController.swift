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

    private let SHARE_COLOR_VIEW_ANIM_DURATION: NSTimeInterval = 0.4
    private let NUMBER_ANIM_DURATION: NSTimeInterval = 1.0
    
    
    //

    //
    @IBOutlet weak var keepOnSmilingLabel: UILabel!
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var filteredPhotoImageView: UIImageView!

    @IBOutlet weak var numberLabel: SACountingLabel!
    @IBOutlet weak var yellLabel: UILabel!
    
    @IBOutlet weak var imageProcessingView: UIView!
    
    //
    
    private var shareAnimView: UIView!
    
    private var smileProgressView: SmileProgressView!
    // after first smile detected, wait 2 sec
    private var smileTimer: DurationTimer!
    
    private var camera: MyCamera!
    private var smileDetector: SmileDetector!

    private var isSmileDetected: Bool = false

    private var filteredImageManager: FilteredImageManager!
    
    //
    
    private var filteredImage: UIImage!
    
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
        
        self.initShareView()

        
        self.checkSmile()
        
        self.camera = MyCamera()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        log("CAPTURED DID APPEAR")
        
        self.isSmileDetected = false
        
        // hide share view
        UIView.animateWithDuration(SHARE_COLOR_VIEW_ANIM_DURATION, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.shareAnimView.transform = CGAffineTransformMakeScale(1, 1)
        }) { (finished) in
            self.shareAnimView.hidden = true
        }
        
        /*
        // start camera
        self.camera.start(self.view, shouldShowView: false, handleError: {
            self.showErrorView("Camera error")
        })*/
    }
    
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)

        self.smileProgressView?.onProgress(0)
        self.camera.stop()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.keepOnSmilingLabel.alpha = 0.0
    }
    
    //
    
    private func checkSmile() {
        SmileDetector().detectSmile(self.image) { (probability, faceRect) in
            if(probability > 0.5) {

                // processing image
                self.filteredImageManager = FilteredImageManager(image: self.image, faceRect: faceRect, viewSize: self.view.frame)
                self.filteredImageManager.processImage({ (filteredImage) in
                    self.filteredImage = filteredImage
                    self.imageProcessingView.hidden = true
                    
                    // show filterd photo
                    self.filteredPhotoImageView.image = self.filteredImage
                    UIView.animateWithDuration(0.5, animations: {
                        self.filteredPhotoImageView.alpha = 1.0
                    })
                })

                // init camera
                self.initCamera()
                self.initSmileDetecting()
                
                // show current photo with anim
                UIView.animateWithDuration(0.5, animations: {
                    self.photoImageView.alpha = 1.0
                })
                
                self.animateNumber()
                self.showYell()
                self.showKeppOnSmiling()
            } else {
                self.camera.stop()
                self.showErrorView("No smile :(")
                self.dismissfadeOut()
            }
        }
    }
    
    private func initShareView() {
        let shareViewInitSize: CGFloat = 50
        self.shareAnimView = UIView(frame: CGRectMake((self.view.frame.width - shareViewInitSize)/2, (self.view.frame.height - shareViewInitSize)/2, shareViewInitSize, shareViewInitSize))
        self.shareAnimView.cornerRadius = shareViewInitSize/2
        self.shareAnimView.backgroundColor = UIColor.orange
        self.shareAnimView.transform = CGAffineTransformMakeScale(1, 1)
        self.shareAnimView.alpha = 0.9
        self.view.addSubview(self.shareAnimView)
        
        self.shareAnimView.hidden = true
    }

    
    private func initCamera() {
        self.smileDetector = SmileDetector()
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
    
    private func initSmileDetecting() {
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
    
    
    func showYell() {
        // init yell text
        let yells = ["Nice!", "That is great!", ":)))", "Give me more", "ENDORPHINE++", "Keep on smiling"]
        let rand = Int(arc4random_uniform(UInt32(yells.count)))
        self.yellLabel.text = yells[rand]
        
        
        self.yellLabel.alpha = 1
        // show insructions
        
        UIView.animateWithDuration(1.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.yellLabel.alpha = 0.0
            self.yellLabel.transform = CGAffineTransformMakeScale(2, 2)
            }, completion: { (completed) in
        })
    }

    
    func animateNumber() {
        let currentNumber = DataManager.currentPhotoNumber
        
        numberLabel.countFrom(0, to: Float(currentNumber), withDuration: NUMBER_ANIM_DURATION, andAnimationType: SACountingLabel.AnimationType.EaseInOut, andCountingType: SACountingLabel.CountingType.Int)
        
        DataManager.incrementCurrentPhotoNumber()
    }

    //
    
    
    private func share() {
        if(self.filteredImageManager.isProcessing == false) {
            self.shareAnimView.hidden = false
            UIView.animateWithDuration(SHARE_COLOR_VIEW_ANIM_DURATION, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                let scale = 3 * (self.view.frame.height / self.shareAnimView.frame.height)
                self.shareAnimView.transform = CGAffineTransformMakeScale(scale, scale)
            }) { (finished) in
                self.performSegueWithIdentifier("Share", withCompletion: { (destVc) in
                    (destVc as! ShareViewController).image = self.filteredImage
                })
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
    
    @IBAction func backClicked(sender: AnyObject) {
        self.camera.stop()
        self.dismissfadeOut()
    }
    


}
