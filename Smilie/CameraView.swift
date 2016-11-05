//
//  CameraView.swift
//  Smilie
//
//  Created by Ufos on 31.10.2016.
//  Copyright © 2016 Ufos. All rights reserved.
//

import UIKit

class CameraView: NibView {

    @IBOutlet weak var previewImageView: UIImageView!
    
    
    //
    
    var takePhotoAction: (()->())?
    
    
    //
    
    override func nibName() -> String {
        return "CameraView"
    }
    
    //
    
    @IBAction func takePhotoClicked(sender: AnyObject) {
        self.takePhotoAction?()
    }

}
