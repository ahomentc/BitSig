//
//  SignController.swift
//  BitSigApp
//
//  Created by Andrei Homentcovschi on 5/11/21.
//  Copyright © 2021 Andrei Homentcovschi. All rights reserved.
//

import Foundation
import web3swift
import UIKit

// shows variables from the contract (in extra details). everything out and open
// advanced also gives option to sign directly to contract but need crypto to pay for gas.
// won't connect to bank or anything but will give address so they can deposit crypto. tell them how much
// to deposit based on estimate

class SignController: UIViewController {

    var QRCodeValue: String? {
        didSet {
            self.setupNFTInfo()
        }
    }
    
    // Token Name
    // Token ID
    // Signatures
    // * Some sort of image or link it's connected to *
    
    // More Info
    //    Owner Address
    //    Contract Address
    //    Link to IPFS
    //    Payment method (all or random)
    //    Last Sold Price
    //    Current Price
    //    Etc.
    
    private lazy var nftInfoLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.black
        label.layer.zPosition = 4
        label.numberOfLines = 0
        label.textAlignment = .left
        let attributedText = NSMutableAttributedString(string: "Token Info:\n\n", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 24)])
        attributedText.append(NSMutableAttributedString(string: "Name: First Signatures Token\n\n", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16)]))
        attributedText.append(NSMutableAttributedString(string: "ID: 1", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16)]))
        label.attributedText = attributedText
        return label
    }()
    
    private lazy var signButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign", for: .normal)
        button.backgroundColor = UIColor(red: 0/255, green: 166/255, blue: 107/255, alpha: 1)
        button.layer.cornerRadius = 15
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
//        button.addTarget(self, action: #selector(closeWalletCreation), for: .touchUpInside)
        return button
    }()
    // advanced sign button underneath this
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.backgroundColor = UIColor.init(white: 0.98, alpha: 1)
        self.navigationController?.navigationBar.barTintColor = UIColor.init(white: 0.98, alpha: 1)
        self.view.backgroundColor = UIColor.init(white: 0.98, alpha: 1)
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .black
        
        nftInfoLabel.frame = CGRect(x: 20, y: 30, width: UIScreen.main.bounds.width - 40, height: 170)
        self.view.insertSubview(nftInfoLabel, at: 4)
        
        signButton.frame = CGRect(x: 40, y: UIScreen.main.bounds.height - 200, width: UIScreen.main.bounds.width - 80, height: 50)
        self.view.insertSubview(signButton, at: 4)
    }
    
    func setupNFTInfo() {
        guard let QRCodeValue = QRCodeValue else { return }
        
        // normally we would parse for a contract address and for a token id
        if QRCodeValue == "https://apps.apple.com/in/app/bitsig/id1566975289" {
            
        }
    }
}
