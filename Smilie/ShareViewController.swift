//
//  ShareViewController.swift
//  Smilie
//
//  Created by Ufos on 05.11.2016.
//  Copyright © 2016 Ufos. All rights reserved.
//

import UIKit
import NVActivityIndicatorView


class ShareViewController: UIViewController, NVActivityIndicatorViewable {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var galleryCheckbox: Checkbox!
    @IBOutlet weak var shareCheckbox: Checkbox!
    
    
    //
    
    var image: UIImage!
    
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.photoImageView.image = self.image
    }
    
    
    // image processing
    func addMaskOnImage(image: UIImage) -> UIImage {
        let mask = UIImage(named: "smile_test")!
        
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
    


    // Actions
    @IBAction func shareClicked(sender: AnyObject) {
        //self.startActivityAnimating("")
        if(shareCheckbox.selected) {
            workInBackground({
                self.image = self.addMaskOnImage(self.image)
            }) {
                let activityVc = UIActivityViewController(activityItems: [self.image], applicationActivities: nil)
                self.presentViewController(activityVc, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func exitClicked(sender: AnyObject) {
        self.dismissViewControllerAnimated(false, completion: nil)
    }

}
