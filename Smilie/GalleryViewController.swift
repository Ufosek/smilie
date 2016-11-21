//
//  GalleryViewController.swift
//  Smilie
//
//  Created by Ufos on 21.11.2016.
//  Copyright © 2016 Ufos. All rights reserved.
//

import UIKit
import SDWebImage


class GalleryViewController: ViewController {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var photoView: CircleView!

    @IBOutlet weak var firstPhotoView: CircleView!
    @IBOutlet weak var secondPhotoView: CircleView!
    @IBOutlet weak var thirdPhotoView: CircleView!
    
    
    
    @IBOutlet weak var firstPhotoImageView: UIImageView!
    @IBOutlet weak var secondPhotoImageView: UIImageView!
    @IBOutlet weak var thirdPhotoImageView: UIImageView!
    
    //
    
    var image: UIImage!
    var shouldShareWithFriends: Bool = false
    
    
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.photoImageView.image = self.image
        
        self.firstPhotoImageView.sd_setImageWithURL(NSURL(string: "https://scontent-waw1-1.xx.fbcdn.net/v/t1.0-9/11205978_878508218880745_86255981664347946_n.jpg?oh=1ca3679ffb89a955ccb9b7683ff179ae&oe=58B812D4"))
        self.secondPhotoImageView.sd_setImageWithURL(NSURL(string: "https://scontent-waw1-1.xx.fbcdn.net/v/t1.0-9/14591738_10211270332863418_104164574000390510_n.jpg?oh=1619449a64fc983e060b33d5aac508f6&oe=58B51004"))
        self.thirdPhotoImageView.sd_setImageWithURL(NSURL(string: "https://scontent-waw1-1.xx.fbcdn.net/t31.0-8/1961695_807364982624266_815569610_o.jpg"))
        //
        
        self.photoView.transform = CGAffineTransformMakeScale(0.1, 0.1)
        self.photoView.alpha = 0
        
        firstPhotoView.transform = CGAffineTransformMakeScale(0.1, 0.1)
        secondPhotoView.transform = CGAffineTransformMakeScale(0.1, 0.1)
        thirdPhotoView.transform = CGAffineTransformMakeScale(0.1, 0.1)
        
        firstPhotoView.alpha = 0
        secondPhotoView.alpha = 0
        thirdPhotoView.alpha = 0
    }
    
    override func viewDidFirstAppear() {
        UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.photoView.transform = CGAffineTransformMakeScale(1, 1)
            self.photoView.alpha = 1
            self.photoView.setNeedsLayout()
        }) { (finished) in }
        
        UIView.animateWithDuration(0.2, delay: 0.1, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.firstPhotoView.transform = CGAffineTransformMakeScale(1, 1)
            self.firstPhotoView.alpha = 1
            self.firstPhotoView.setNeedsLayout()
        }) { (finished) in }
        
        UIView.animateWithDuration(0.2, delay: 0.2, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.secondPhotoView.transform = CGAffineTransformMakeScale(1, 1)
            self.secondPhotoView.alpha = 1
            self.secondPhotoView.setNeedsLayout()
        }) { (finished) in }
        
        UIView.animateWithDuration(0.2, delay: 0.3, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.thirdPhotoView.transform = CGAffineTransformMakeScale(1, 1)
            self.thirdPhotoView.alpha = 1
            self.thirdPhotoView.setNeedsLayout()
        }) { (finished) in }
        
        
        // if should then share
        if(self.shouldShareWithFriends) {
            delay(3.0, withCompletion: { 
                self.shareWithFriends()
            })
        }
    }


    private func shareWithFriends() {
        if(self.shouldShareWithFriends) {
            let activityVc = UIActivityViewController(activityItems: [self.image], applicationActivities: nil)
            activityVc.completionWithItemsHandler = { (activity, success, items, error) in
                //
            }
            self.presentViewController(activityVc, animated: true, completion: nil)
        }
    }

    
    // Actions
    
    @IBAction func exitClicked(sender: AnyObject) {
        self.dismissfadeOut()
    }

}
