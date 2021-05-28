//
//  ScanController.swift
//  BitSigApp
//
//  Created by Andrei Homentcovschi on 5/9/21.
//  Copyright © 2021 Andrei Homentcovschi. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import web3swift
import PromiseKit

// For Crypto stuff:
// https://github.com/skywinder/web3swift/blob/master/Documentation/Usage.md#account-management
// Just need to create a wallet so that I can use their private key to sign their signature message
// Easy to do :)

// something here like a label you can dismiss with an x saying to sign the first token ever created
// in case they don't go to website again or website is hard to access

class ScanController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, CreateWalletControllerDelegate {
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    private let qrIconImage: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.image = #imageLiteral(resourceName: "qr-code-scan")
        iv.alpha = 0.7
        iv.layer.zPosition = 5
        return iv
    }()
    
    private let greenBackground: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 10/255, green: 176/255, blue: 117/255, alpha: 1)
        v.layer.zPosition = 0
        return v
    }()
    
    private lazy var balanceLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.black
        label.layer.zPosition = 4
        label.numberOfLines = 0
        label.textAlignment = .center
        let attributedText = NSMutableAttributedString(string: "Balance:\n", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.init(white: 0.9, alpha: 1)])
        attributedText.append(NSMutableAttributedString(string: "$0", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 40), NSAttributedString.Key.foregroundColor: UIColor.init(white: 1, alpha: 1)]))
        label.attributedText = attributedText
        return label
    }()
    
    private lazy var scanLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.black
        label.layer.zPosition = 4
        label.numberOfLines = 0
        label.textAlignment = .center
        let attributedText = NSMutableAttributedString(string: "Scan a QR code to sign its NFT", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.init(white: 1, alpha: 0.7)])
        label.attributedText = attributedText
        return label
    }()
    
    private lazy var signFirstNFTButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.clear
        button.setTitleColor(.white, for: .normal)
        button.layer.zPosition = 6
        button.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.right
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitle("Sign the first signable NFT!", for: .normal)
        button.addTarget(self, action: #selector(goToFirstTokenSignPage), for: .touchUpInside)
        return button
    }()
    
    private lazy var closeFirstNFTButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.clear
        button.layer.zPosition = 6
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setImage(#imageLiteral(resourceName: "x"), for: .normal)
        button.tintColor = .white
        button.contentEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        button.addTarget(self, action: #selector(closeFirstNFT), for: .touchUpInside)
        return button
    }()
    
    private lazy var signFirstNFTBackground: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0/255, green: 156/255, blue: 97/255, alpha: 0.8)
        view.layer.cornerRadius = 15
        view.clipsToBounds = true
        view.layer.zPosition = 5
        return view
    }()
    
    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.backgroundColor = UIColor(red: 0/255, green: 156/255, blue: 97/255, alpha: 1)
        button.layer.cornerRadius = 5
        button.layer.zPosition = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.isHidden = true
//        button.addTarget(self, action: #selector(handleRestore), for: .touchUpInside)
        return button
    }()
    
    private let recieveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Recieve", for: .normal)
        button.backgroundColor = UIColor(red: 0/255, green: 156/255, blue: 97/255, alpha: 1)
        button.layer.cornerRadius = 5
        button.layer.zPosition = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.isHidden = true
//        button.addTarget(self, action: #selector(handleRestore), for: .touchUpInside)
        return button
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.backgroundColor = UIColor(red: 0/255, green: 156/255, blue: 97/255, alpha: 1)
        button.layer.cornerRadius = 5
        button.layer.zPosition = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.isHidden = true
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button
    }()
    
    private let signupButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.backgroundColor = UIColor(red: 0/255, green: 156/255, blue: 97/255, alpha: 1)
        button.layer.cornerRadius = 5
        button.layer.zPosition = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.isHidden = true
        button.addTarget(self, action: #selector(handleSignup), for: .touchUpInside)
        return button
    }()
    
    let web3 = Web3.InfuraMainnetWeb3()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        captureSession = AVCaptureSession()
        configureNavBar()
        
//        let textAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18), NSAttributedString.Key.foregroundColor : UIColor.black]
//        let navLabel = UILabel()
//        navLabel.attributedText = NSAttributedString(string: "Scan a QR code to sign it's NFT!", attributes: textAttributes)
//        navigationItem.titleView = navLabel
        
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
        
//        greenBackground.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 180)
//        view.insertSubview(greenBackground, at: 5)
        
        balanceLabel.frame = CGRect(x: 20, y: 0, width: UIScreen.main.bounds.width - 40, height: 70)
        view.insertSubview(balanceLabel, at: 5)
        
        recieveButton.frame = CGRect(x: UIScreen.main.bounds.width/2 - 120 - 5, y: 85, width: 120, height: 45)
        view.insertSubview(recieveButton, at: 5)
        
        sendButton.frame = CGRect(x: UIScreen.main.bounds.width/2 + 5, y: 85, width: 120, height: 45)
        view.insertSubview(sendButton, at: 5)
        
        signupButton.frame = CGRect(x: UIScreen.main.bounds.width/2 - 120 - 5, y: 85, width: 120, height: 45)
        view.insertSubview(signupButton, at: 5)
        
        loginButton.frame = CGRect(x: UIScreen.main.bounds.width/2 + 5, y: 85, width: 120, height: 45)
        view.insertSubview(loginButton, at: 5)
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = CGRect(x: 5, y: 150, width: UIScreen.main.bounds.width - 10, height: UIScreen.main.bounds.height - 140)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.cornerRadius = 20
        view.layer.addSublayer(previewLayer)

        qrIconImage.frame = CGRect(x: UIScreen.main.bounds.width/2 - 50, y: 150 + 200/2, width: 100, height: 100)
        view.insertSubview(qrIconImage, at: 5)
        
        scanLabel.frame = CGRect(x: 20, y: 120 + 240, width: UIScreen.main.bounds.width - 40, height: 60)
        view.insertSubview(scanLabel, at: 5)
        
        signFirstNFTButton.frame = CGRect(x: UIScreen.main.bounds.width/2-160, y: 120 + 350, width: 250, height: 60)
        view.insertSubview(signFirstNFTButton, at: 7)
        
        closeFirstNFTButton.frame = CGRect(x: UIScreen.main.bounds.width/2+90, y: 120 + 350, width: 60, height: 60)
        view.insertSubview(closeFirstNFTButton, at: 7)
        
        signFirstNFTBackground.frame = CGRect(x: UIScreen.main.bounds.width/2-160, y: 120 + 350, width: 320, height: 60)
        view.insertSubview(signFirstNFTBackground, at: 6)
        
        refreshTopButtons()
        
        captureSession.startRunning()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleLogin), name: NSNotification.Name(rawValue: "sendToLogin"), object: nil)
        
        DispatchQueue.main.async {
            self.getWalletBalance()
            // use promisekit somehow
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureNavBar()
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
        
        refreshTopButtons()
        
        NotificationCenter.default.post(name: NSNotification.Name("tabBarClear"), object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("tabBarColor"), object: nil)
    }
    
    func configureNavBar() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.backgroundColor = UIColor(red: 10/255, green: 176/255, blue: 117/255, alpha: 1)
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 10/255, green: 176/255, blue: 117/255, alpha: 1)
        self.view.backgroundColor = UIColor(red: 10/255, green: 176/255, blue: 117/255, alpha: 1)
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .black
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
        // verify that the QR code belongs to the bitsig app or has the link to it as the first one
        
        if code == "https://apps.apple.com/in/app/bitsig/id1566975289" {
            // check if the user has a wallet
            if let hasWalletRetrieved = UserDefaults.standard.object(forKey: "hasWallet") as? Data {
                guard let hasWallet = try? JSONDecoder().decode(Bool.self, from: hasWalletRetrieved) else {
                    return
                }
                if hasWallet {
                    let signController = SignController()
                    signController.QRCodeValue = code
                    navigationController?.pushViewController(signController, animated: true)
                }
                else {
                    // present CreateWalletController
                    let createWalletController = CreateWalletController()
                    createWalletController.modalPresentationStyle = .fullScreen
                    createWalletController.delegate = self
                    createWalletController.QRCodeValue = code
                    present(createWalletController, animated: true, completion: nil)
                }
            }
            else {
                let createWalletController = CreateWalletController()
                createWalletController.modalPresentationStyle = .fullScreen
                createWalletController.delegate = self
                createWalletController.QRCodeValue = code
                present(createWalletController, animated: true, completion: nil)
            }
        }
        else {
            // for all other tokens that aren't the first one
            
            // for now just restart camera
            captureSession.startRunning()
        }
    }
    
    @objc func handleLogin() {
        let createWalletController = CreateWalletController()
        createWalletController.modalPresentationStyle = .fullScreen
        createWalletController.isLogin = true
        present(createWalletController, animated: true, completion: nil)
    }
    
    @objc func handleSignup() {
        let createWalletController = CreateWalletController()
        createWalletController.modalPresentationStyle = .fullScreen
        createWalletController.isLogin = false
        present(createWalletController, animated: true, completion: nil)
    }
    
    func getWalletBalance() {
        self.getWalletAddress(completion: { (wallet) in
            let walletAddress = EthereumAddress(wallet.address)! // Address which balance we want to know
            do {
                let balanceResult = try! self.web3.eth.getBalance(address: walletAddress)
                let balanceString = Web3.Utils.formatToEthereumUnits(balanceResult, toUnits: .eth, decimals: 3)!
                print(balanceString)
                
                // Make the GET request for our API URL to get the value NSNumber
                self.makeValueGETRequest(url: URL(string: "https://min-api.cryptocompare.com/data/price?fsym=ETH&tsyms=USD")!) { (value) in

                    // Must update the UI on the main thread since makeValueGetRequest is a background operation
                    DispatchQueue.main.async {
                        let balanceEthInt = Double(balanceString)!
                        let valueInt = value?.doubleValue
                        let balance_dollars = balanceEthInt * valueInt!
                        let balance_string = self.formatAsCurrencyString(value: balance_dollars as NSNumber)
                        
                        let attributedText = NSMutableAttributedString(string: "Balance:\n", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.init(white: 0.9, alpha: 1)])
                        attributedText.append(NSMutableAttributedString(string: balance_string!, attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 40), NSAttributedString.Key.foregroundColor: UIColor.init(white: 1, alpha: 1)]))
                        self.balanceLabel.attributedText = attributedText
                    }
                }
            }
            catch {
                print("getting balance failed")
            }
        })
    }
    
    func refreshTopButtons() {
        if let hasWalletRetrieved = UserDefaults.standard.object(forKey: "hasWallet") as? Data {
            guard let hasWallet = try? JSONDecoder().decode(Bool.self, from: hasWalletRetrieved) else {
                return
            }
            if hasWallet {
                recieveButton.isHidden = false
                sendButton.isHidden = false
                signupButton.isHidden = true
                loginButton.isHidden = true
            }
            else {
                recieveButton.isHidden = true
                sendButton.isHidden = true
                signupButton.isHidden = false
                loginButton.isHidden = false
            }
        }
        else {
            recieveButton.isHidden = true
            sendButton.isHidden = true
            signupButton.isHidden = false
            loginButton.isHidden = false
        }
    }
    
    func goToTokenSignPage(QRValue: String) {
        let signController = SignController()
        signController.QRCodeValue = QRValue
        navigationController?.pushViewController(signController, animated: true)
    }
    
    @objc func goToFirstTokenSignPage() {
        found(code: "https://apps.apple.com/in/app/bitsig/id1566975289")
    }
    
    @objc func closeFirstNFT() {
        self.signFirstNFTButton.isHidden = true
        self.closeFirstNFTButton.isHidden = true
        self.signFirstNFTBackground.isHidden = true
    }

    func getWalletAddress(completion: @escaping (Wallet) -> ()) {
        let password_service = "passService"
        let mnemonics_service = "mnemonicsService"
        let account = "myAccount"
        if let password = KeychainService.loadPassword(service: password_service, account: account) {
            if let mnemonics = KeychainService.loadPassword(service: mnemonics_service, account: account) {
                // get wallet
                let keystore = try! BIP32Keystore(
                    mnemonics: mnemonics,
                    password: password,
                    mnemonicsPassword: "",
                    language: .english)!
                let name = "New HD Wallet"
                let keyData = try! JSONEncoder().encode(keystore.keystoreParams)
                let address = keystore.addresses!.first!.address
                let wallet = Wallet(address: address, data: keyData, name: name, isHD: true)
                
                // should really do this somewhere else
                let keystoreManager = KeystoreManager([keystore])
                self.web3.addKeystoreManager(keystoreManager)
                
                completion(wallet)
            }
        }
    }
    
/// Takes an API URL and performs a GET request on it to try to get back an NSNumber
    ///
    /// - Parameters:
    ///   - url: The API URL to perform the GET request with
    ///   - completion: Returns the value as an NSNumber, or nil in the case of failure
    private func makeValueGETRequest(url: URL, completion: @escaping (_ value: NSNumber?) -> Void) {
        let request = URLSession.shared.dataTask(with: url) { (data, response, error) in
            // Unwrap the data and make sure that an error wasn't returned
            guard let data = data, error == nil else {
                // If an error was returned set the value in the completion as nil and print the error
                completion(nil)
                print(error?.localizedDescription ?? "")
                return
            }
            
            do {
                // Unwrap the JSON dictionary and read the USD key which has the value of Ethereum
                guard let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
                    let value = json["USD"] as? NSNumber else {
                        completion(nil)
                        return
                }
                completion(value)
            } catch  {
                // If we couldn't serialize the JSON set the value in the completion as nil and print the error
                completion(nil)
                print(error.localizedDescription)
            }
        }
        
        request.resume()
    }
    
    /// Takes an optional NSNumber and converts it to USD String
    ///
    /// - Parameter value: The NSNumber to convert to a USD String
    /// - Returns: The USD String or nil in the case of failure
    private func formatAsCurrencyString(value: NSNumber?) -> String? {
        /// Construct a NumberFormatter that uses the US Locale and the currency style
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .currency

        // Ensure the value is non-nil and we can format it using the numberFormatter, if not return nil
        guard let value = value,
            let formattedCurrencyAmount = formatter.string(from: value) else {
                return nil
        }
        return formattedCurrencyAmount
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}
