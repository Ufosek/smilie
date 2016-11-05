//
//  ImageViewController.swift
//  Smilie
//
//  Created by Ufos on 31.10.2016.
//  Copyright © 2016 Ufos. All rights reserved.
//

import UIKit

class CapturedPhotoViewController: UIViewController {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var probabilityLabel: UILabel!
    
    @IBOutlet weak var shareAnimView: UIView!
    //
    
    var image: UIImage?
    
    
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.photoImageView.image = image
        
        self.shareAnimView.hidden = true
        
        SmileDetector().detectSmile(image!) { (probability) in
            self.probabilityLabel.text = "Prawdopodobieństwo uśmiechu = \(NSString(format: "%.2f", probability))"
        }
    }


    // Actions
    @IBAction func backClicked(sender: AnyObject) {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    

    @IBAction func shareClicked(sender: AnyObject) {
        //UIView
    }
}
