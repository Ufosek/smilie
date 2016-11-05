//
//  SmileDetector.swift
//  Smilie
//
//  Created by Ufos on 05.11.2016.
//  Copyright © 2016 Ufos. All rights reserved.
//

import UIKit
import AVFoundation
import GLKit
import GoogleMobileVision


class SmileDetector: NSObject {
    
    private let GMVDetectorFaceLandmarkType_ALL = 1 << 1
    private let GMVDetectorFaceClassificationType_ALL = 1 << 1

    
    private var faceDetector: GMVDetector!
    private var detectQueue: dispatch_queue_t!
    private var isCalculatingSmilingProbability: Bool!
    
    
    //
    
    override init() {
        let options: [NSObject : AnyObject] = [
            GMVDetectorFaceLandmarkType: GMVDetectorFaceLandmarkType_ALL,
            GMVDetectorFaceClassificationType: GMVDetectorFaceClassificationType_ALL,
            GMVDetectorFaceTrackingEnabled: false
        ]
        
        self.faceDetector = GMVDetector(ofType: GMVDetectorTypeFace, options: options)
        
        self.detectQueue = dispatch_queue_create("panowie.p.detect", DISPATCH_QUEUE_SERIAL)
        self.isCalculatingSmilingProbability = false
    }
    
    
    func detectSmile(image: UIImage, smileDetected: ((CGFloat)->())?) {
        // calculate 1 at once
        if(self.isCalculatingSmilingProbability == false) {
            self.isCalculatingSmilingProbability = true
            
            // callback in main queue (main thread)
            dispatch_async(self.detectQueue) {
                // get face features
                let faceFeatures: [GMVFaceFeature] = self.faceDetector.featuresInImage(image, options: nil) as! [GMVFaceFeature]
                
                // find biggest smile probability
                var probability: CGFloat = 0
                for feature in faceFeatures {
                    if feature.hasSmilingProbability && feature.smilingProbability > probability {
                        probability = feature.smilingProbability
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.isCalculatingSmilingProbability = false
                    smileDetected?(probability)
                })
            }
        }
    }
    
}



