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
    
    
    func detectSmile(_ image: UIImage, smileDetected: ((CGFloat, CGRect, GMVFaceFeature)->())?) {
        // calculate 1 at once
        if(self.isCalculatingSmilingProbability == false) {
            self.isCalculatingSmilingProbability = true
            
            // callback in main queue (main thread)
            self.detectQueue.async {
                // get face features
                let faceFeatures: [GMVFaceFeature] = self.faceDetector.features(in: image, options: nil) as! [GMVFaceFeature]
                
                var faceRect = CGRect(x: 0, y: 0, width: 10, height: 10)
                var feature_ = GMVFaceFeature()
                
                // find biggest smile probability
                var probability: CGFloat = 0
                for feature in faceFeatures {
                    if feature.hasSmilingProbability && feature.smilingProbability > probability {
                        probability = feature.smilingProbability
                        faceRect = self.faceRect(feature)
                        feature_ = feature
                    }
                }

                DispatchQueue.main.async(execute: {
                    self.isCalculatingSmilingProbability = false
                    smileDetected?(probability, faceRect, feature_)
                })
            }
        }
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



