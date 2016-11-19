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
    
    
    private var frontCameraDevice: AVCaptureDevice!
    private var cameraSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var glContext: EAGLContext!
    private var glView: GLKView!
    private var ciContext: CIContext!
    private var videoOutput: AVCaptureVideoDataOutput!
    private var stillCameraOutput: AVCaptureStillImageOutput!
    private var sessionQueue: dispatch_queue_t!
    
    
    //
    
    var previewImage: ((UIImage)->())?
    
    //
    
    
    
    func makePhoto(photoTaken: ((UIImage)->())?, handleError: (()->())?=nil) {
        dispatch_async(sessionQueue) { () -> Void in
            
            let connection = self.stillCameraOutput.connectionWithMediaType(AVMediaTypeVideo)
            
            // update the video orientation to the device one
            connection.videoOrientation = AVCaptureVideoOrientation(rawValue: UIDevice.currentDevice().orientation.rawValue)!
            
            self.stillCameraOutput.captureStillImageAsynchronouslyFromConnection(connection) {
                (imageDataSampleBuffer, error) -> Void in
                
                if error == nil {
                    // if the session preset .Photo is used, or if explicitly set in the device's outputSettings
                    // we get the data already compressed as JPEG
                    
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                    
                    if let image = UIImage(data: imageData) {
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
    
    
    func start(cameraPreviewView: UIView, shouldShowView showView: Bool=true, handleError: (()->())?) {
        self.cameraSession = AVCaptureSession()
        // default configuration
        self.cameraSession.sessionPreset = AVCaptureSessionPresetPhoto
        
        // get fron camera
        let availableCameraDevices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        for device in availableCameraDevices as! [AVCaptureDevice] {
            if device.position == .Front {
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
                glContext = EAGLContext(API: .OpenGLES2)
                glView = GLKView(frame: previewLayer.frame, context: glContext)
                ciContext = CIContext(EAGLContext: glContext)
                
                // video and callback (for preview image)
                videoOutput = AVCaptureVideoDataOutput()
                videoOutput.videoSettings = NSDictionary(object: NSNumber(unsignedInt: kCVPixelFormatType_32BGRA), forKey: NSString(string: kCVPixelBufferPixelFormatTypeKey)) as [NSObject : AnyObject]
                videoOutput.setSampleBufferDelegate(self, queue: dispatch_queue_create("sample buffer delegate", DISPATCH_QUEUE_SERIAL))
                if cameraSession.canAddOutput(self.videoOutput) {
                    cameraSession.addOutput(self.videoOutput)
                }
                
                // for still image
                stillCameraOutput = AVCaptureStillImageOutput()
                if self.cameraSession.canAddOutput(self.stillCameraOutput) {
                    self.cameraSession.addOutput(self.stillCameraOutput)
                }
                
                // start camera
                sessionQueue = dispatch_queue_create("panowie.p.camera", DISPATCH_QUEUE_SERIAL)
                dispatch_async(sessionQueue) { () -> Void in
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
        self.cameraSession.stopRunning()
    }
    
    
    
    static func checkCameraPermissions(authorized: (()->())?, denied: (()->())?) {
        let authorizationStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        switch authorizationStatus {
        case .NotDetermined:
            // permission dialog not yet presented, request authorization
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: { (granted:Bool) -> Void in
                if granted {
                    authorized?()
                }
                else {
                    denied?()
                }
            })
        case .Authorized:
            authorized?()
            break;
            
        case .Denied, .Restricted:
            denied?()
            break;
        }
    }

    
    
    
    // AVCaptureVideoDataOutputSampleBufferDelegate
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        let image = CIImage(CVPixelBuffer: pixelBuffer!)
        if glContext != EAGLContext.currentContext() {
            EAGLContext.setCurrentContext(glContext)
        }
        
        glView.bindDrawable()
        ciContext.drawImage(image, inRect:image.extent, fromRect: image.extent)
        glView.display()

        // we have to do it in main queue
        dispatch_async(dispatch_get_main_queue())
        {
            // imageRotatedByDegrees causes damage
            // CMSampleBufferGetImageBuffer is rotated by 90
            let image_ = UIImageHelper.imageFromSampleBuffer(sampleBuffer).imageRotatedByDegrees(90, flip: false, switchedSizes: true)
            
            self.previewImage?(image_)
        }
    }
    
    
}