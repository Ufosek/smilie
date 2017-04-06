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
    
    //
    
    private let EYE_SIZE_FACTOR: CGFloat = 0.6
    
    //
    
    fileprivate var image: UIImage
    fileprivate var viewSize: CGRect
    fileprivate var faceFeatures: [GMVFaceFeature]
    fileprivate var currentNumber: Int
    
    fileprivate var filteredImage: UIImage!
    fileprivate(set) var isProcessing: Bool = false
    
    
    init(image: UIImage, currentNumber: Int, viewSize: CGRect, faceFeatures: [GMVFaceFeature]) {
        self.image = image
        self.viewSize = viewSize
        self.faceFeatures = faceFeatures
        self.currentNumber = currentNumber
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
            //
            self.filteredImage = self.addCounterOnImage(self.filteredImage, number: self.currentNumber)
            
            self.filteredImage = self.addLogo(self.filteredImage)
        }) {
            self.isProcessing = false
            self.image = self.filteredImage
            
            completed?(self.filteredImage)
        }
    }
    
    func addRandomEeyes(_ completed: ((UIImage)->())?) {
        self.isProcessing = true
        
        self.filteredImage = self.image
        
        // filter image
        workInBackground({
            self.filteredImage = self.addEyesOnImage(self.filteredImage)
        }) {
            self.isProcessing = false
            
            completed?(self.filteredImage)
        }
    }
    
    fileprivate func filterImage(_ image: UIImage) -> UIImage {
        // dot effects
        let kuwaharaFilter = GPUImageKuwaharaFilter()
        kuwaharaFilter.radius = 2
        
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
        
        // eye's size is based on distance between eyes
        let eyeSize = sqrt((faceFeature.leftEyePosition.x - faceFeature.rightEyePosition.x) * (faceFeature.leftEyePosition.x - faceFeature.rightEyePosition.x) + (faceFeature.leftEyePosition.y - faceFeature.rightEyePosition.y) * (faceFeature.leftEyePosition.y - faceFeature.rightEyePosition.y)) * EYE_SIZE_FACTOR

        let leftEyePos = CGPoint(x: faceFeature.leftEyePosition.x - eyeSize/2, y: faceFeature.leftEyePosition.y - eyeSize/2)
        let rightEyePos = CGPoint(x: faceFeature.rightEyePosition.x - eyeSize/2, y: faceFeature.rightEyePosition.y - eyeSize/2)
        
        let eyes = [#imageLiteral(resourceName: "eye1"), #imageLiteral(resourceName: "eye2"), #imageLiteral(resourceName: "eye3"), #imageLiteral(resourceName: "eye4"), #imageLiteral(resourceName: "eye5"), #imageLiteral(resourceName: "eye6"), #imageLiteral(resourceName: "eye7"), #imageLiteral(resourceName: "eye8"), #imageLiteral(resourceName: "eye9"), #imageLiteral(resourceName: "eye10"), #imageLiteral(resourceName: "eye11"), #imageLiteral(resourceName: "eye12"), #imageLiteral(resourceName: "eye13"), #imageLiteral(resourceName: "eye14"), #imageLiteral(resourceName: "eye15"), #imageLiteral(resourceName: "eye16"), #imageLiteral(resourceName: "eye17"), #imageLiteral(resourceName: "eye18"), #imageLiteral(resourceName: "eye19"), #imageLiteral(resourceName: "eye20"), #imageLiteral(resourceName: "eye21")]

        var leftEye = eyes.randomElem as! UIImage
        var rightEye = eyes.randomElem as! UIImage
        
        // rotate to fit face
        if(faceFeature.hasHeadEulerAngleZ) {
            leftEye = leftEye.imageRotatedByDegrees(-faceFeature.headEulerAngleZ, flip: false)
            rightEye = rightEye.imageRotatedByDegrees(-faceFeature.headEulerAngleZ, flip: false)
        }

        newImage = newImage.imageWithImage(leftEye, atLocation: leftEyePos, withSize: CGSize(width: eyeSize, height: eyeSize))
        newImage = newImage.imageWithImage(rightEye, atLocation: rightEyePos, withSize: CGSize(width: eyeSize, height: eyeSize))
        
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
    
    
    fileprivate func addCounterOnImage(_ image: UIImage, number: Int) -> UIImage {

        let textFont = UIFont(name: "Helvetica Bold", size: 52)!
        
        // Setup the font attributes that will be later used to dictate how the text should be drawn
        let textFontAttributes = [
            NSFontAttributeName: textFont,
            NSForegroundColorAttributeName: UIColor.white,
            ]
        
        let counterText = "#\(number)"
        let counterTextWidth = CGFloat(counterText.characters.count * 38)
        let counterTextX: CGFloat = 450
        let rectHeight: CGFloat = 70
        
        var newImage = image
        
        newImage = newImage.imageWithCircle(center: CGPoint(x: counterTextX+counterTextWidth, y: 102+50/2), radius: rectHeight/2, withColor: UIColor.orange)
        newImage = newImage.imageWithRect(CGRect(x: counterTextX, y: 92, width: counterTextWidth, height: rectHeight), withColor: UIColor.orange)
        newImage = newImage.imageWithImage(#imageLiteral(resourceName: "smile_orange"), atLocation: CGPoint(x: 350 , y: 50), withSize: CGSize(width: 150, height: 150))
        newImage = newImage.imageWithText(counterText, atLocation: CGPoint(x: counterTextX+50, y: 95), withAttributes: textFontAttributes)
        
        return newImage
    }
    
    fileprivate func addLogo(_ image: UIImage) -> UIImage {
        return image.imageWithImage(#imageLiteral(resourceName: "smilie"), atLocation: CGPoint(x: (image.size.width-211)/2, y: image.size.height-150), withSize: CGSize(width: 211, height: 55))
    }
    
}
