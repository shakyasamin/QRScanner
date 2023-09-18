//
//  QRScannerViewController.swift
//  QRCodeApp
//
//  Created by Farukh IQBAL on 21/12/2020.
//

import UIKit
import AVFoundation

extension QRScannerController: AVCaptureMetadataOutputObjectsDelegate {
    
}

class QRScannerController: UIViewController {
    
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrcodeFrameView: UIView?
    
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var topBar: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Get the back-facing camera for capturing videos
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("Failed to get the camera device")
            return
        }
        
        do {
            //get an instance of the AVCaptureDeviceInput class using the previous device object
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            //Set the input device on the capture session
            captureSession.addInput(input)
            
            //Initialze a AVCaptureMetadataOutput object and set it as the output device to the capture session
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            //set delegate and use the default diapatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            
            //Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            //Start video capture
            captureSession.startRunning()
            
            //Move the message label and top bar to the front
            view.bringSubviewToFront(messageLabel)
            view.bringSubviewToFront(topBar)
            
            //Initialize QR Code Frame to highlight th QR code
            
            
            
        }catch {
            //If any error occurs, simply print it out and don't continue anymore
            print(error)
            return
        }

    }
}
