//
//  SmilieGraphic.swift
//  Smilie
//
//  Created by Ufos on 29.11.2016.
//  Copyright © 2016 Ufos. All rights reserved.
//

import Foundation
import GPUImage


class FilteredImageManager: NSObject {
    
    private var image: UIImage!
    private var viewSize: CGRect!
    private var faceRect: CGRect!
    
    private var filteredImage: UIImage!
    private(set) var isProcessing: Bool = false
    
    
    init(image: UIImage, faceRect: CGRect, viewSize: CGRect) {
        self.image = image
        self.faceRect = faceRect
        self.viewSize = viewSize
    }
    
    
    
    func processImage(completed: ((UIImage)->())?) {
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
    
    private func filterImage(image: UIImage) -> UIImage {
        // dot effects
        let kuwaharaFilter = GPUImageKuwaharaFilter()
        kuwaharaFilter.radius = 8
        
        let newImage = image.imageWithFilter(kuwaharaFilter)
        
        return newImage
    }
    
    private func addMaskOnImage(image: UIImage) -> UIImage {
        let backgroundImage = UIImage(named: "background_\(1)")!
        
        return backgroundImage.imageWithMask(image, atLocation: CGPointMake(200, 164), withSize: CGSizeMake(370, 370))
    }
    
    
}