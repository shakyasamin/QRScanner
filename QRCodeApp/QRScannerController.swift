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
    
    let imageView = UIImageView()
    
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var topBar: UIView!
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        //check if the metadata Objects array is not nil  and it contains at least one object
        
        if metadataObjects.count == 0 {
            qrcodeFrameView?.frame = CGRect.zero
            messageLabel.text = "No QR code is detected"
            return
        }
        
        //Get the metadata object
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            //if the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barCodeObject  = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrcodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                messageLabel.text = metadataObj.stringValue
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Initialize the image view and set its properties
        let imageSize = CGSize(width: 50, height: 50)
        imageView.frame = CGRect(x: (view.frame.width - imageSize.width)/2, y: topBar.frame.maxY + 10, width: imageSize.width, height: imageSize.height)
              imageView.contentMode = .scaleAspectFit
              imageView.isUserInteractionEnabled = true // Enable user interaction
              imageView.image = UIImage(systemName: "photo") // Set your image here
              // Add a tap gesture recognizer to the image view
              let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
              imageView.addGestureRecognizer(tapGestureRecognizer)
              // Add the image view as a subview
              view.addSubview(imageView)
        
        //Get the back-facing camera for capturing videos
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("Failed to get the camera device")
            return
        }
        
        do {
            //Get an instance of the AVCaptureDeviceInput class using the previous device object
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            //Set the input device on the capture session
            captureSession.addInput(input)
            
            //Initialze a AVCaptureMetadataOutput object and set it as the output device to the capture session
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            //Set delegate and use the default diapatch queue to execute the call back
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
            
            //Initialize QR Code Frame to highlight the QR code
            qrcodeFrameView = UIView()
            
            if let qrcodeFrameView = qrcodeFrameView {
                qrcodeFrameView.layer.borderColor = UIColor.yellow.cgColor
                qrcodeFrameView.layer.borderWidth = 2
                view.addSubview(qrcodeFrameView)
                view.bringSubviewToFront(qrcodeFrameView)
            }
            
        }catch {
            //If any error occurs, simply print it out and don't continue anymore
            print(error)
            return
        }
        

    }
    
    @objc func imageTapped() {
            openGallery()
        }
    
    func openGallery() {
          let imagePicker = UIImagePickerController()
          imagePicker.sourceType = .photoLibrary
          imagePicker.allowsEditing = false
          imagePicker.delegate = self // Make sure your class conforms to UIImagePickerControllerDelegate and UINavigationControllerDelegate
          present(imagePicker, animated: true, completion: nil)
      }
  }

  // Implement UIImagePickerControllerDelegate methods if not already implemented
  extension QRScannerController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
      
      func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
          if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
              // Do something with the selected image
              // For example, you can display it, process it, or save it
//              imageView.image = selectedImage
              
              let detector:CIDetector = CIDetector(ofType: CIDetectorTypeQRCode, context:    nil, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh] )!
              let ciImage:CIImage = CIImage(image: selectedImage)!
              var qrCodeLink = ""
              
              let features = detector.features(in: ciImage)
              
              for feature in features as! [CIQRCodeFeature] {
                  qrCodeLink += feature.messageString!
              }
              
              if qrCodeLink == "" {
                  print("nothing")
              }else{
                  print("message: \(qrCodeLink)")
              }
          }
          else{
              print("something went wrong")
          }
          picker.dismiss(animated: true, completion: nil)
      }
      
      func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
          picker.dismiss(animated: true, completion: nil)
      }
    
}
