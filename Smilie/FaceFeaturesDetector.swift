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


class FaceFeaturesDetector: NSObject {
    
    fileprivate let GMVDetectorFaceLandmarkType_ALL = 1 << 1
    fileprivate let GMVDetectorFaceClassificationType_ALL = 1 << 1

    
    fileprivate var faceDetector: GMVDetector!
    fileprivate var detectQueue: DispatchQueue!
    fileprivate var isCalculatingSmilingProbability: Bool!
    
    
    //
    
    override init() {
        let options: [AnyHashable: Any] = [
            GMVDetectorFaceLandmarkType: GMVDetectorFaceLandmarkType_ALL,
            GMVDetectorFaceClassificationType: GMVDetectorFaceClassificationType_ALL,
            GMVDetectorFaceTrackingEnabled: false
        ]
        
        self.faceDetector = GMVDetector(ofType: GMVDetectorTypeFace, options: options)
        
        self.detectQueue = DispatchQueue(label: "panowie.p.detect", attributes: [])
        self.isCalculatingSmilingProbability = false
    }
    
    
    func detectSmile(_ image: UIImage, smileDetected: ((CGFloat, [GMVFaceFeature])->())?) {
        // calculate 1 at once
        if(self.isCalculatingSmilingProbability == false) {
            self.isCalculatingSmilingProbability = true
            
            // callback in main queue (main thread)
            self.detectQueue.async {
                // get face features
                let faceFeatures: [GMVFaceFeature] = self.faceDetector.features(in: image, options: nil) as! [GMVFaceFeature]
                
                // find biggest smile probability
                var probability: CGFloat = 0
                for feature in faceFeatures {
                    
                    if feature.hasSmilingProbability && feature.smilingProbability > probability {
                        probability = feature.smilingProbability
                    }
                }

                DispatchQueue.main.async(execute: {
                    self.isCalculatingSmilingProbability = false
                    smileDetected?(probability, faceFeatures)
                })
            }
        }
    }

    
}



