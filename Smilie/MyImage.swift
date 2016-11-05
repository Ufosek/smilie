//
//  MyImage.swift
//  Smilie
//
//  Created by Ufos on 05.11.2016.
//  Copyright © 2016 Ufos. All rights reserved.
//

import Foundation


extension UIImage {
    
    public func imageWithoutRotation() -> UIImage {
        switch(self.imageOrientation) {
        case UIImageOrientation.LeftMirrored:
            print("LeftMirrored")
            return self.imageRotatedByDegrees(-90, flip: true)
        case UIImageOrientation.Left:
            print("Left")
            return self.imageRotatedByDegrees(-90, flip: false)
        case UIImageOrientation.Right:
            print("Right")
            return self.imageRotatedByDegrees(90, flip: false)
        case UIImageOrientation.RightMirrored:
            print("RightMirrored")
            return self.imageRotatedByDegrees(90, flip: true)
        case UIImageOrientation.Down:
            print("DOWN")
            return self.imageRotatedByDegrees(180, flip: false)
        case UIImageOrientation.DownMirrored:
            print("DownMirrored")
            return self.imageRotatedByDegrees(180, flip: true)
        case UIImageOrientation.Up:
            print("UP")
            return self
        case UIImageOrientation.UpMirrored:
            print("UpMirrored")
            return self.imageRotatedByDegrees(180, flip: true)
        }
    }
    
    
    public func orientationDegrees() -> CGFloat {
        switch(self.imageOrientation) {
        case UIImageOrientation.LeftMirrored:
            return 90
        case UIImageOrientation.Left:
            return -90
        case UIImageOrientation.Right:
            return 0
        case UIImageOrientation.RightMirrored:
            return 90
        case UIImageOrientation.Down:
            return 180
        case UIImageOrientation.DownMirrored:
            return 180
        case UIImageOrientation.Up:
            return 180
        case UIImageOrientation.UpMirrored:
            return 180
        }
    }
    
    public func imageFlipped() -> UIImage {
        // Create the bitmap context
        UIGraphicsBeginImageContext(size)
        let bitmap = UIGraphicsGetCurrentContext()
        
        CGContextTranslateCTM(bitmap, size.width / 2.0, size.height / 2.0)
        CGContextRotateCTM(bitmap, degreesToRadians(-90))
        CGContextScaleCTM(bitmap, -1.0, -1.0)
        CGContextDrawImage(bitmap, CGRectMake(-size.height/2, -size.width/2, size.height, size.width), CGImage)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    public func imageRotatedByDegrees(degrees: CGFloat, flip: Bool) -> UIImage {
        return imageRotatedByDegrees(degrees, flip: flip, switchedSizes: false)
    }
    
    public func imageRotatedByDegrees(degrees: CGFloat, flip: Bool, switchedSizes: Bool) -> UIImage {
        
        //print("size before = \(size)")
        
        // calculate the size of the rotated view's containing box for our drawing space
        let rotatedViewBox = UIView(frame: CGRect(origin: CGPointZero, size: size))
        let t = CGAffineTransformMakeRotation(degreesToRadians(degrees));
        rotatedViewBox.transform = t
        let rotatedSize = size
        
        
        // CHANGED FOR AVCaptureVideoDataOutputSampleBufferDelegate
        let width = switchedSizes == false ? size.width : size.height
        let height = switchedSizes == false ? size.height : size.width
        
        // Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap = UIGraphicsGetCurrentContext()
        
        // Move the origin to the middle of the image so we will rotate and scale around the center.
        //CGContextTranslateCTM(bitmap, rotatedSize.width / 2.0, rotatedSize.height / 2.0);
        CGContextTranslateCTM(bitmap, width / 2.0, height / 2.0);
        
        //   // Rotate the image context
        CGContextRotateCTM(bitmap, degreesToRadians(degrees));
        
        
        // Now, draw the rotated/scaled image into the context
        var yFlip: CGFloat
        
        if(flip){
            yFlip = CGFloat(-1.0)
        } else {
            yFlip = CGFloat(1.0)
        }
        
        CGContextScaleCTM(bitmap, yFlip, -1.0)
        if(abs(degrees) > 90) {
            CGContextDrawImage(bitmap, CGRectMake(-width / 2, -height / 2, width, height), CGImage)
        } else {
            CGContextDrawImage(bitmap, CGRectMake(-height / 2, -width / 2, height, width), CGImage)
        }
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}




