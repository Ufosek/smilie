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
    fileprivate var faceRect: CGRect!
    fileprivate var faceFeature: GMVFaceFeature!
    
    fileprivate var filteredImage: UIImage!
    fileprivate(set) var isProcessing: Bool = false
    
    
    init(image: UIImage, faceRect: CGRect, viewSize: CGRect, faceFeature: GMVFaceFeature) {
        self.image = image
        self.faceRect = faceRect
        self.viewSize = viewSize
        self.faceFeature = faceFeature
    }
    
    
    
    func processImage(_ completed: ((UIImage)->())?) {
        self.isProcessing = true
        
        self.filteredImage = self.image
        
        // filter image
        workInBackground({
            // add filters
            self.filteredImage = self.filteredImage.imageCropped(self.faceRect)
            // add filters
            self.filteredImage = self.filterImage(self.filteredImage)
            // set size
            self.filteredImage = self.filteredImage.imageCircle()
            // add images and texts
            self.filteredImage = self.addMaskOnImage(self.filteredImage)
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
    
    fileprivate func addMaskOnImage(_ image: UIImage) -> UIImage {
        let backgroundImage = UIImage(named: "background_\(1)")!
        
        let faceLocation = CGPoint(x: 185, y: 149)
        let eyeSize = CGSize(width: 150, height: 150)
        let faceSize = CGSize(width: 400, height: 400)
        
        var newImage = backgroundImage.imageWithImage(image, atLocation: faceLocation, isBelow: true, withSize: faceSize)
        
        let sizeRatio = faceSize.width / faceRect.width
        
        
        log("faceRect = \(self.faceRect)")
        
        let leftEyePos = CGPoint(x: (self.faceFeature.leftEyePosition.x - self.faceRect.origin.x) * sizeRatio + faceLocation.x - eyeSize.width/2, y: (self.faceFeature.leftEyePosition.y - self.faceRect.origin.y) * sizeRatio + faceLocation.y - eyeSize.height/2)
        let rightEyePos = CGPoint(x: (self.faceFeature.rightEyePosition.x - self.faceRect.origin.x) * sizeRatio + faceLocation.x - eyeSize.width/2, y: (self.faceFeature.rightEyePosition.y - self.faceRect.origin.y) * sizeRatio + faceLocation.y - eyeSize.height/2)
        
        newImage = newImage.imageWithImage(#imageLiteral(resourceName: "eye1"), atLocation: leftEyePos, withSize: eyeSize)
        newImage = newImage.imageWithImage(#imageLiteral(resourceName: "eye2"), atLocation: rightEyePos, withSize: eyeSize)

        return newImage
    }
    
    
}
