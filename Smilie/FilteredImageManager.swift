//
//  SmilieGraphic.swift
//  Smilie
//
//  Created by Ufos on 29.11.2016.
//  Copyright © 2016 Ufos. All rights reserved.
//

import Foundation
import GPUImage
import GoogleMobileVision

class FilteredImageManager: NSObject {
    
    fileprivate var image: UIImage!
    fileprivate var viewSize: CGRect!
    fileprivate var faceFeatures: [GMVFaceFeature]!
    
    fileprivate var filteredImage: UIImage!
    fileprivate(set) var isProcessing: Bool = false
    
    
    init(image: UIImage, viewSize: CGRect, faceFeatures: [GMVFaceFeature]) {
        self.image = image
        self.viewSize = viewSize
        self.faceFeatures = faceFeatures
    }
    
    
    
    func processImage(_ completed: ((UIImage)->())?) {
        self.isProcessing = true
        
        self.filteredImage = self.image
        
        // filter image
        workInBackground({
            // add filters
            //self.filteredImage = self.filteredImage.imageCropped(self.faceRect)
            // add filters
            self.filteredImage = self.filterImage(self.filteredImage)
            // set size
            //self.filteredImage = self.filteredImage.imageCircle()
            // add images and texts
            self.filteredImage = self.addEyesOnImage(self.filteredImage)
        }) {
            self.isProcessing = false
            
            completed?(self.filteredImage)
        }
    }
    
    fileprivate func filterImage(_ image: UIImage) -> UIImage {
        // dot effects
        let kuwaharaFilter = GPUImageKuwaharaFilter()
        kuwaharaFilter.radius = 8
        
        let newImage = image.imageWithFilter(kuwaharaFilter)
        
        return newImage
    }
    
    fileprivate func addEyesOnImage(_ image: UIImage) -> UIImage {
        var newImage = image
        
        for feature in self.faceFeatures {
            newImage = self.addRandomEyesOnImage(newImage, faceFeature: feature)
        }
        
        return newImage
    }
    
    
    fileprivate func addRandomEyesOnImage(_ image: UIImage, faceFeature: GMVFaceFeature) -> UIImage {
        var newImage = image
        
        let eyeSize = CGSize(width: 120, height: 120)
        
        let leftEyePos = CGPoint(x: faceFeature.leftEyePosition.x - eyeSize.width/2, y: faceFeature.leftEyePosition.y - eyeSize.height/2)
        let rightEyePos = CGPoint(x: faceFeature.rightEyePosition.x - eyeSize.width/2, y: faceFeature.rightEyePosition.y - eyeSize.height/2)
        
        let eyes = [#imageLiteral(resourceName: "eye1"), #imageLiteral(resourceName: "eye2"), #imageLiteral(resourceName: "eye3"), #imageLiteral(resourceName: "eye4"), #imageLiteral(resourceName: "eye5"), #imageLiteral(resourceName: "eye6"), #imageLiteral(resourceName: "eye7")]

        newImage = newImage.imageWithImage(eyes.randomElem as! UIImage, atLocation: leftEyePos, withSize: eyeSize)
        newImage = newImage.imageWithImage(eyes.randomElem as! UIImage, atLocation: rightEyePos, withSize: eyeSize)
        
        return newImage
    }
    
    //
    
    // face pos and size
    fileprivate func faceRect(_ faceFeature: GMVFaceFeature) -> CGRect {
        // radius = distance between nose and ear
        let radius: CGFloat = sqrt((faceFeature.noseBasePosition.x - faceFeature.leftEarPosition.x)*(faceFeature.noseBasePosition.x - faceFeature.leftEarPosition.x) + (faceFeature.noseBasePosition.y - faceFeature.leftEarPosition.y)*(faceFeature.noseBasePosition.y - faceFeature.leftEarPosition.y))
        
        let posx: CGFloat = faceFeature.noseBasePosition.x - radius * 1.5
        let posy: CGFloat = faceFeature.noseBasePosition.y - radius * 1.6
        let width: CGFloat = faceFeature.noseBasePosition.x + radius * 1.5 - posx
        let height: CGFloat = faceFeature.noseBasePosition.y + radius * 1.2 - posy
        
        return CGRect(x: posx, y: posy, width: width, height: height)
    }
    
    
}
