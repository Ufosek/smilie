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
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var filteredPhotoImageView: UIImageView!
    @IBOutlet weak var probabilityLabel: UILabel!
    
    @IBOutlet weak var imageProcessingLoadingView: UIView!
    @IBOutlet weak var shareAnimView: UIView!
    
    @IBOutlet weak var numberLabel: SACountingLabel!
    @IBOutlet weak var yellLabel: UILabel!
    //
    
    private var isProcessingImage: Bool = false
    
    var image: UIImage! {
        didSet {
            self.filteredImage = self.image
        }
    }
    
    private var filteredImage: UIImage!
    
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set current image without filters in background
        self.photoImageView.image = image
        self.photoImageView.alpha = 0.0

        // not visible filtered
        self.filteredPhotoImageView.alpha = 0
        
        SmileDetector().detectSmile(image) { (probability) in
            self.probabilityLabel.text = "Prawdopodobieństwo uśmiechu = \(NSString(format: "%.2f", probability))"
        }
        
        // processing image
        self.processImage()
        
        // init yell text
        let yells = ["Nice!", "That is great!", ":)))", "Give me more", "ENDORPHINE++", "Keep on smiling"]
        let rand = Int(arc4random_uniform(UInt32(yells.count)))
        self.yellLabel.text = yells[rand]
    }
    
    override func viewDidFirstAppear() {
        self.shareAnimView.hidden = true
        self.shareAnimView.transform = CGAffineTransformMakeScale(1, 1)
        
        self.animateNumber()
        self.showYell()
        
        // show current photo with anim
        UIView.animateWithDuration(0.5, animations: {
            self.photoImageView.alpha = 1.0
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.shareAnimView.hidden = false
        
        UIView.animateWithDuration(SHARE_COLOR_VIEW_ANIM_DURATION, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.shareAnimView.transform = CGAffineTransformMakeScale(1, 1)
        }) { (finished) in
            self.shareAnimView.hidden = true
        }
    }
    
    //
    
    
    func showYell() {
        self.yellLabel.alpha = 1
        // show insructions
        
        UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.yellLabel.alpha = 0.0
            self.yellLabel.transform = CGAffineTransformMakeScale(3, 3)
            }, completion: { (completed) in
        })
    }
    
    var num = 0
    
    func animateNumber() {
        let currentNumber = DataManager.currentPhotoNumber
        
        numberLabel.countFrom(0, to: Float(currentNumber), withDuration: NUMBER_ANIM_DURATION, andAnimationType: SACountingLabel.AnimationType.EaseInOut, andCountingType: SACountingLabel.CountingType.Int)
        
        DataManager.incrementCurrentPhotoNumber()
    }
    
    
    // Image processing
    
    func processImage() {
        self.isProcessingImage = true
        
        self.filteredImage = self.image
        
        // filter image
        workInBackground({
            // set size
            self.filteredImage = self.sizeImage(self.filteredImage)
            // add filters
            self.filteredImage = self.filterImage(self.filteredImage)
            // add images and texts
            // self.filteredImage = self.addMaskOnImage(self.filteredImage)
        }) {
            self.isProcessingImage = false
            self.imageProcessingLoadingView.hidden = true
            
            // show filterd photo
            self.filteredPhotoImageView.image = self.filteredImage
            UIView.animateWithDuration(0.5, animations: { 
                self.filteredPhotoImageView.alpha = 1.0
            })
        }
    }

    func sizeImage(image: UIImage) -> UIImage {
        log("self.view.bounds = \(self.view.bounds)")
        log("image size = \(image.size)")
        
        // crop to size of phone
        let ratio = self.view.frame.width / self.view.frame.height
        let height = image.size.height
        let width = height * ratio
        
        let sideInset = (self.filteredImage.size.width - width)/2
        
        let sizedImage  = self.filteredImage.imageCropped(CGRectMake(sideInset, 0, width, height))
        
        return sizedImage
    }
    
    
    func filterImage(image: UIImage) -> UIImage {
        // dot effects
        let dotFilter = GPUImagePolkaDotFilter()
        dotFilter.fractionalWidthOfAPixel = 0.012
        
        let colorFilter = GPUImageMissEtikateFilter()

        var newImage = image.imageWithFilter(dotFilter)
        newImage = newImage.imageWithFilter(colorFilter)
        
        return newImage
    }
    
    

    
    
    // Actions
    
    @IBAction func backClicked(sender: AnyObject) {
        self.dismissfadeOut()
    }
    

    @IBAction func shareClicked(sender: AnyObject) {
        if(self.isProcessingImage == false) {
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
}
