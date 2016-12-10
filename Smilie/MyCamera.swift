//
//  MyCamera.swift
//  Smilie
//
//  Created by Ufos on 05.11.2016.
//  Copyright © 2016 Ufos. All rights reserved.
//

import UIKit
import AVFoundation
import GLKit
import GoogleMobileVision


class MyCamera: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    
    fileprivate var frontCameraDevice: AVCaptureDevice!
    fileprivate var cameraSession: AVCaptureSession!
    fileprivate var previewLayer: AVCaptureVideoPreviewLayer!
    fileprivate var glContext: EAGLContext!
    fileprivate var glView: GLKView!
    fileprivate var ciContext: CIContext!
    fileprivate var videoOutput: AVCaptureVideoDataOutput!
    fileprivate var stillCameraOutput: AVCaptureStillImageOutput!
    fileprivate var sessionQueue: DispatchQueue!
    
    
    //
    
    var previewImage: ((UIImage)->())?
    
    //
    
    
    
    func makePhoto(_ photoTaken: ((UIImage)->())?, handleError: (()->())?=nil) {
        sessionQueue.async { () -> Void in
            
            let connection = self.stillCameraOutput.connection(withMediaType: AVMediaTypeVideo)
            
            // update the video orientation to the device one
            connection?.videoOrientation = AVCaptureVideoOrientation(rawValue: UIDevice.current.orientation.rawValue)!
            
            self.stillCameraOutput.captureStillImageAsynchronously(from: connection) {
                (imageDataSampleBuffer, error) -> Void in
                
                if error == nil {
                    // if the session preset .Photo is used, or if explicitly set in the device's outputSettings
                    // we get the data already compressed as JPEG
                    
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                    
                    if let image = UIImage(data: imageData!) {
                        // save the image or do something interesting with it
                        
                        photoTaken?(image.imageFlipped())
                    }
                }
                else {
                    handleError?()
                    
                    log("error while capturing still image: \(error)")
                }
            }
        }
    }
    
    
    func start(_ cameraPreviewView: UIView, shouldShowView showView: Bool=true, handleError: (()->())?) {
        self.cameraSession = AVCaptureSession()
        // default configuration
        self.cameraSession.sessionPreset = AVCaptureSessionPresetPhoto
        
        // get fron camera
        let availableCameraDevices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo)
        for device in availableCameraDevices as! [AVCaptureDevice] {
            if device.position == .front {
                frontCameraDevice = device
            }
        }
        
        // get input from camera
        do {
            let cameraInput = try AVCaptureDeviceInput(device: frontCameraDevice)
            
            if self.cameraSession.canAddInput(cameraInput) {
                self.cameraSession.addInput(cameraInput)
                
                // add preview to layer
                previewLayer = AVCaptureVideoPreviewLayer(session: cameraSession) as AVCaptureVideoPreviewLayer
                previewLayer.frame = cameraPreviewView.frame
                previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                
                if(showView) {
                    cameraPreviewView.layer.addSublayer(previewLayer)
                }
                
                // init GL
                glContext = EAGLContext(api: .openGLES2)
                glView = GLKView(frame: previewLayer.frame, context: glContext)
                ciContext = CIContext(eaglContext: glContext)
                
                // video and callback (for preview image)
                videoOutput = AVCaptureVideoDataOutput()
                videoOutput.videoSettings = NSDictionary(object: NSNumber(value: kCVPixelFormatType_32BGRA as UInt32), forKey: NSString(string: kCVPixelBufferPixelFormatTypeKey)) as! [AnyHashable: Any]
                videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sample buffer delegate", attributes: []))
                if cameraSession.canAddOutput(self.videoOutput) {
                    cameraSession.addOutput(self.videoOutput)
                }
                
                // for still image
                stillCameraOutput = AVCaptureStillImageOutput()
                if self.cameraSession.canAddOutput(self.stillCameraOutput) {
                    self.cameraSession.addOutput(self.stillCameraOutput)
                }
                
                // start camera
                sessionQueue = DispatchQueue(label: "panowie.p.camera", attributes: [])
                sessionQueue.async { () -> Void in
                    self.cameraSession.startRunning()
                }
                
            }
            
        } catch let error as NSError {
            handleError?()
            // Handle any errors
            print(error)
        } catch {
            handleError?()
            // Handle any errors
            print("Error")
        }
    }
    
    func stop() {
        self.cameraSession?.stopRunning()
    }
    
    
    
    static func checkCameraPermissions(_ authorized: (()->())?, denied: (()->())?) {
        let authorizationStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        switch authorizationStatus {
        case .notDetermined:
            // permission dialog not yet presented, request authorization
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted:Bool) -> Void in
                if granted {
                    authorized?()
                }
                else {
                    denied?()
                }
            })
        case .authorized:
            authorized?()
            break;
            
        case .denied, .restricted:
            denied?()
            break;
        }
    }

    
    
    
    // AVCaptureVideoDataOutputSampleBufferDelegate
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        let image = CIImage(cvPixelBuffer: pixelBuffer!)
        if glContext != EAGLContext.current() {
            EAGLContext.setCurrent(glContext)
        }
        
        glView.bindDrawable()
        ciContext.draw(image, in:image.extent, from: image.extent)
        glView.display()

        // we have to do it in main queue
        DispatchQueue.main.async
        {
            // imageRotatedByDegrees causes damage
            // CMSampleBufferGetImageBuffer is rotated by 90
            let image_ = UIImageHelper.image(from: sampleBuffer).imageRotatedByDegrees(90, flip: false, switchedSizes: true)
            
            self.previewImage?(image_)
        }
    }
    
    
}
