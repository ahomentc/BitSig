//
//  ScanController.swift
//  BitSigApp
//
//  Created by Andrei Homentcovschi on 5/9/21.
//  Copyright © 2021 Andrei Homentcovschi. All rights reserved.
//

import Foundation
import UIKit
import web3swift
import AVFoundation

// For Crypto stuff:
// https://github.com/skywinder/web3swift/blob/master/Documentation/Usage.md#account-management
// Just need to create a wallet so that I can use their private key to sign their signature message
// Easy to do :)

class ScanController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        captureSession = AVCaptureSession()
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.backgroundColor = UIColor.init(white: 0.98, alpha: 1)
        self.navigationController?.navigationBar.barTintColor = UIColor.init(white: 0.98, alpha: 1)
        self.view.backgroundColor = UIColor.init(white: 0.98, alpha: 1)
        
        let textAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18), NSAttributedString.Key.foregroundColor : UIColor.black]
        let navLabel = UILabel()
        navLabel.attributedText = NSAttributedString(string: "Scan an NFT QR code to sign it!", attributes: textAttributes)
        navigationItem.titleView = navLabel
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = CGRect(x: UIScreen.main.bounds.width/2 - 130, y: 10, width: 260, height: 260)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.cornerRadius = 10
        view.layer.addSublayer(previewLayer)

        captureSession.startRunning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            captureSession.stopRunning()

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }
    }
    
    func found(code: String) {
        print(code)
        
        // check if the user has a wallet
        if let hasWalletRetrieved = UserDefaults.standard.object(forKey: "hasWallet") as? Data {
            guard let hasWallet = try? JSONDecoder().decode(Bool.self, from: hasWalletRetrieved) else {
                return
            }
            if hasWallet {
                // panel showing that they've signed the nft and it's been added to their signatures
                // button to take to controls with options such as paying gas to get on contract now instead of wait
            }
            else {
                // present CreateWalletController
                let createWalletController = CreateWalletController()
                createWalletController.modalPresentationStyle = .fullScreen
                present(createWalletController, animated: true, completion: nil)
            }
        }
        else {
            // launch confetti
            
            let createWalletController = CreateWalletController()
            createWalletController.modalPresentationStyle = .fullScreen
            present(createWalletController, animated: true, completion: nil)
            captureSession.stopRunning()
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}
