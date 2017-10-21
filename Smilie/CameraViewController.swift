//
//  CameraViewController.swift
//  Smilie
//
//  Created by Ufos on 31.10.2016.
//  Copyright © 2016 Ufos. All rights reserved.
//

import UIKit

// NOT USED


class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate {

    //
    
    
    fileprivate var imagePicker: UIImagePickerController!
    
    
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    //
    
    //
    
    
    func showCamera() {
        if (UIImagePickerController.availableCaptureModes(for: .front) != nil) {
            self.imagePicker = UIImagePickerController()
            self.imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            self.imagePicker.cameraDevice = .front
            self.imagePicker.cameraCaptureMode = .photo
            self.imagePicker.modalPresentationStyle = .fullScreen
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
            
            
            self.present(self.imagePicker, animated: false) {
                
            }
            
        } else {
            print("NO CAMERA")
        }
    }
    
    
    // adjust size to device
    
    fileprivate func scaleForFullScreen() -> CGAffineTransform {
        
        let screenSize = UIScreen.main.bounds.size
        let cameraAspectRatio = CGFloat(4.0 / 3.0)
        let imageWidth = screenSize.width * cameraAspectRatio;
        // 20 I guess for status bar
        let scale = (screenSize.height + 10) / imageWidth
        let imageHeight = screenSize.height * scale
        
        print("screenSize = \(screenSize)")
        print("scale = \(scale)")
        print("imageWidth = \(imageWidth)")
        print("imageHeight = \(imageHeight)")
        
        var transform = CGAffineTransform(scaleX: scale, y: scale)
        transform = transform.translatedBy(x: 0, y: 60)
        
        return transform
    }
    
    
    // UIImagePickerControllerDelegate
    // image selected
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [AnyHashable: Any]!) {
        picker.dismiss(animated: true, completion: nil)

        // do smth
    }
    
    // otherwise status bar changes color
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if((navigationController as! UIImagePickerController).sourceType == UIImagePickerControllerSourceType.photoLibrary) {
            UIApplication.shared.setStatusBarHidden(false, with: UIStatusBarAnimation.none)
            UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: false)
        }
    }

}
