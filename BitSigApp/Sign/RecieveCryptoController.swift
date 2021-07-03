//
//  RecieveCryptoController.swift
//  BitSigApp
//
//  Created by Andrei Homentcovschi on 7/2/21.
//  Copyright © 2021 Andrei Homentcovschi. All rights reserved.
//

import UIKit
import web3swift

class RecieveCryptoController: UIViewController {
    
    private let qrIconImage: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.alpha = 1
        iv.layer.zPosition = 5
        return iv
    }()
    
    private lazy var addressLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.black
        label.layer.zPosition = 4
        label.numberOfLines = 0
        label.textAlignment = .center
        let attributedText = NSMutableAttributedString(string: "", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.init(white: 1, alpha: 1)])
        label.attributedText = attributedText
        return label
    }()
    
    private let copyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Copy to clipboard", for: .normal)
        button.backgroundColor = UIColor(red: 0/255, green: 156/255, blue: 97/255, alpha: 1)
        button.layer.cornerRadius = 15
        button.layer.zPosition = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(copyClipboard), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        self.view.backgroundColor = .white
        
        let btnDone = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissView))
        self.navigationItem.rightBarButtonItem = btnDone
        
        self.navigationItem.title = "Recieve Eth"
        
        qrIconImage.frame = CGRect(x: UIScreen.main.bounds.width/2 - 100, y: 120, width: 200, height: 200)
        view.insertSubview(qrIconImage, at: 5)
        
        addressLabel.frame = CGRect(x: 40, y: 330, width: UIScreen.main.bounds.width - 80, height: 50)
        view.insertSubview(addressLabel, at: 5)
        
        copyButton.frame = CGRect(x: UIScreen.main.bounds.width/2 - 100, y: 390, width: 200, height: 55)
        view.insertSubview(copyButton, at: 5)
        
        let address_service = "addressService"
        let account = "myAccount"
        if let address = KeychainService.loadPassword(service: address_service, account: account) {
            addressLabel.text = address
            let image = generateQRCode(from: address)
            qrIconImage.image = image
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        copyButton.backgroundColor = .white
        copyButton.setTitleColor(UIColor(red: 0/255, green: 156/255, blue: 97/255, alpha: 1), for: .normal)
        copyButton.setTitle("Copy to clipboard", for: .normal)
        copyButton.isEnabled = true
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }

        return nil
    }
    
    @objc func copyClipboard() {
        UIPasteboard.general.string = self.addressLabel.text
        copyButton.setTitle("Copied!", for: .normal)
        copyButton.isEnabled = false
    }
    
    @objc func dismissView() {
        self.dismiss(animated: true, completion: {})
    }
}
