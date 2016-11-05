//
//  CameraViewController.swift
//  Smilie
//
//  Created by Ufos on 31.10.2016.
//  Copyright © 2016 Ufos. All rights reserved.
//

import UIKit

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate {

    //
    
    
    private var imagePicker: UIImagePickerController!
    
    
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    //
    
    //
    
    
    func showCamera() {
        if (UIImagePickerController.availableCaptureModesForCameraDevice(.Front) != nil) {
            self.imagePicker = UIImagePickerController()
            self.imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
            self.imagePicker.cameraDevice = .Front
            self.imagePicker.cameraCaptureMode = .Photo
            self.imagePicker.modalPresentationStyle = .FullScreen
            self.imagePicker.showsCameraControls = false
            self.imagePicker.delegate = self
            
            self.imagePicker.cameraViewTransform = self.scaleForFullScreen()
            
            // add overlay view
            let cameraView = CameraView(frame: self.imagePicker.view.frame)
            // take photo
            cameraView.takePhotoAction = {
                self.imagePicker.takePicture()
            }
            self.imagePicker.cameraOverlayView = cameraView
            
            
            self.presentViewController(self.imagePicker, animated: false) {
                
            }
            
        } else {
            print("NO CAMERA")
        }
    }
    
    
    // adjust size to device
    
    private func scaleForFullScreen() -> CGAffineTransform {
        
        let screenSize = UIScreen.mainScreen().bounds.size
        let cameraAspectRatio = CGFloat(4.0 / 3.0)
        let imageWidth = screenSize.width * cameraAspectRatio;
        // 20 I guess for status bar
        let scale = (screenSize.height + 10) / imageWidth
        let imageHeight = screenSize.height * scale
        
        print("screenSize = \(screenSize)")
        print("scale = \(scale)")
        print("imageWidth = \(imageWidth)")
        print("imageHeight = \(imageHeight)")
        
        var transform = CGAffineTransformMakeScale(scale, scale)
        transform = CGAffineTransformTranslate(transform, 0, 60)
        
        return transform
    }
    
    
    // UIImagePickerControllerDelegate
    // image selected
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        picker.dismissViewControllerAnimated(true, completion: nil)

        // do smth
    }
    
    // otherwise status bar changes color
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        if((navigationController as! UIImagePickerController).sourceType == UIImagePickerControllerSourceType.PhotoLibrary) {
            UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.None)
            UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
        }
    }

}
