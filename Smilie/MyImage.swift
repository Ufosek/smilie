//
//  MyImage.swift
//  Smilie
//
//  Created by Ufos on 05.11.2016.
//  Copyright © 2016 Ufos. All rights reserved.
//

import Foundation
import GPUImage
import QuartzCore



extension UIImage {
    
    public func imageWithoutRotation() -> UIImage {
        switch(self.imageOrientation) {
        case UIImageOrientation.leftMirrored:
            print("LeftMirrored")
            return self.imageRotatedByDegrees(-90, flip: true)
        case UIImageOrientation.left:
            print("Left")
            return self.imageRotatedByDegrees(-90, flip: false)
        case UIImageOrientation.right:
            print("Right")
            return self.imageRotatedByDegrees(90, flip: false)
        case UIImageOrientation.rightMirrored:
            print("RightMirrored")
            return self.imageRotatedByDegrees(90, flip: true)
        case UIImageOrientation.down:
            print("DOWN")
            return self.imageRotatedByDegrees(180, flip: false)
        case UIImageOrientation.downMirrored:
            print("DownMirrored")
            return self.imageRotatedByDegrees(180, flip: true)
        case UIImageOrientation.up:
            print("UP")
            return self
        case UIImageOrientation.upMirrored:
            print("UpMirrored")
            return self.imageRotatedByDegrees(180, flip: true)
        }
    }
    
    
    public func orientationDegrees() -> CGFloat {
        switch(self.imageOrientation) {
        case UIImageOrientation.leftMirrored:
            return 90
        case UIImageOrientation.left:
            return -90
        case UIImageOrientation.right:
            return 0
        case UIImageOrientation.rightMirrored:
            return 90
        case UIImageOrientation.down:
            return 180
        case UIImageOrientation.downMirrored:
            return 180
        case UIImageOrientation.up:
            return 180
        case UIImageOrientation.upMirrored:
            return 180
        }
    }
    
    public func imageFlipped() -> UIImage {
        // Create the bitmap context
        UIGraphicsBeginImageContext(size)
        let bitmap = UIGraphicsGetCurrentContext()
        
        bitmap?.translateBy(x: size.width / 2.0, y: size.height / 2.0)
        bitmap?.rotate(by: degreesToRadians(-90))
        bitmap?.scaleBy(x: -1.0, y: -1.0)
        bitmap?.draw(cgImage!, in: CGRect(x: -size.height/2, y: -size.width/2, width: size.height, height: size.width))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    public func imageRotatedByDegrees(_ degrees: CGFloat, flip: Bool) -> UIImage {
        return imageRotatedByDegrees(degrees, flip: flip, switchedSizes: false)
    }
    
    public func imageRotatedByDegrees(_ degrees: CGFloat, flip: Bool, switchedSizes: Bool) -> UIImage {
        
        //print("size before = \(size)")
        
        // calculate the size of the rotated view's containing box for our drawing space
        let rotatedViewBox = UIView(frame: CGRect(origin: CGPoint.zero, size: size))
        let t = CGAffineTransform(rotationAngle: degreesToRadians(degrees));
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
        bitmap?.translateBy(x: width / 2.0, y: height / 2.0);
        
        //   // Rotate the image context
        bitmap?.rotate(by: degreesToRadians(degrees));
        
        
        // Now, draw the rotated/scaled image into the context
        var yFlip: CGFloat
        
        if(flip){
            yFlip = CGFloat(-1.0)
        } else {
            yFlip = CGFloat(1.0)
        }
        
        bitmap?.scaleBy(x: yFlip, y: -1.0)
        if(abs(degrees) > 90) {
            bitmap?.draw(cgImage!, in: CGRect(x: -width / 2, y: -height / 2, width: width, height: height))
        } else {
            bitmap?.draw(cgImage!, in: CGRect(x: -height / 2, y: -width / 2, width: height, height: width))
        }
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }

    
    // --
    // ALL TAKS HAVE TO BE EXECUTED IN BACKGROUND THREAD!
    // --
    
    func imageWithSize(_ size: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    // width would be calculated from ratio
    func imageWithWidth(_ width: CGFloat) -> UIImage {
        
        let ratio = self.size.height / self.size.width
        let height = width * ratio

        return imageWithSize(CGSize(width: width, height: height))
    }
    
    // height would be calculated from ratio
    func imageWithHeight(_ height: CGFloat) -> UIImage {
        
        let ratio = self.size.width / self.size.height
        let width = height * ratio
        
        return imageWithSize(CGSize(width: width, height: height))
    }
    
    
    // fragment of image
    func imageCropped(_ crop: CGRect) -> UIImage {
        return UIImage(cgImage: self.cgImage!.cropping(to: crop)!)
    }
    
    
    
    // examples of filter and mask
    func imageWithFilter(_ filter: GPUImageInput) -> UIImage {
        let imagePicture = GPUImagePicture(image: self)
        imagePicture?.addTarget(filter)
        (filter as? GPUImageOutput)?.useNextFrameForImageCapture()
        imagePicture?.processImage()
        let image = (filter as? GPUImageOutput)!.imageFromCurrentFramebuffer()
        
        return image!
    }
    
    func imageWithImage(_ image: UIImage, atLocation location: CGPoint, isBelow: Bool=false, withSize size: CGSize?) -> UIImage {
        let imageSize = size != nil ? size! : image.size
        
        UIGraphicsBeginImageContext(self.size)

        if(!isBelow) {
            self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        }
        image.draw(in: CGRect(x: location.x, y: location.y, width: imageSize.width, height: imageSize.height))
        if(isBelow) {
            self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        }
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func imageCircle() -> UIImage {
        let newImage = self.copy() as! UIImage
        let cornerRadius = self.size.height/2
        UIGraphicsBeginImageContextWithOptions(self.size, false, 1.0)
        
        let bounds = CGRect(origin: CGPoint.zero, size: self.size)
        
        UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).addClip()
        newImage.draw(in: bounds)
        
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return finalImage!
    }
    
    
    func imageWithText(_ text: String, atLocation location: CGPoint, withAttributes attributes: [String : AnyObject]?=nil) -> UIImage {
        UIGraphicsBeginImageContext(self.size)
        
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        NSString(string: text).draw(at: location, withAttributes: attributes)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func imageWithRect(_ rect: CGRect, withColor color: UIColor) -> UIImage {
        UIGraphicsBeginImageContext(self.size)
        
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func imageWithCircle(center: CGPoint, radius: CGFloat, withColor color: UIColor) -> UIImage {
        UIGraphicsBeginImageContext(self.size)
        
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        let context = UIGraphicsGetCurrentContext()

        let circlePath = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: CGFloat(2*M_PI), clockwise: false)
        context?.setFillColor(color.cgColor)
        circlePath.fill()

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
}




