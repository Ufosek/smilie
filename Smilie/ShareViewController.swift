//
//  ShareViewController.swift
//  Smilie
//
//  Created by Ufos on 05.11.2016.
//  Copyright © 2016 Ufos. All rights reserved.
//

import UIKit

class ShareViewController: UIViewController {

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


    // Actions
    @IBAction func shareClicked(sender: AnyObject) {
        if(shareCheckbox.selected) {
            let activityVc = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            self.presentViewController(activityVc, animated: true, completion: nil)
        }
    }
    
    @IBAction func exitClicked(sender: AnyObject) {
        self.dismissViewControllerAnimated(false, completion: nil)
    }

}
