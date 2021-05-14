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
import FirebaseDatabase
import FirebaseAuth
import Kingfisher

// https://swiftpack.co/package/LanfordCai/Secp256k1Swift

// shows variables from the contract (in extra details). everything out and open
// advanced also gives option to sign directly to contract but need crypto to pay for gas.
// won't connect to bank or anything but will give address so they can deposit crypto. tell them how much
// to deposit based on estimate

class SignController: UIViewController {

    let scrollView = UIScrollView()
    let toScrollView = UIView()
    let stackView = UIStackView()
    
    var QRCodeValue: String? {
        didSet {
            self.setupNFTInfo()
        }
    }
    
    private let tokenImg: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.zPosition = 5
        iv.layer.cornerRadius = 15
        iv.backgroundColor = .clear
//        iv.isHidden = true
        return iv
    }()
    
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
        return label
    }()
    
    private lazy var signButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign", for: .normal)
        button.backgroundColor = UIColor(red: 0/255, green: 166/255, blue: 107/255, alpha: 1)
        button.layer.cornerRadius = 15
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(signToken), for: .touchUpInside)
        return button
    }()
    // advanced sign button underneath this
    
    private lazy var viewSignersButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("View Signers", for: .normal)
        button.backgroundColor = .clear
        button.layer.borderColor = UIColor(red: 0/255, green: 166/255, blue: 107/255, alpha: 1).cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 15
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(UIColor(red: 0/255, green: 166/255, blue: 107/255, alpha: 1), for: .normal)
//        button.addTarget(self, action: #selector(signToken), for: .touchUpInside)
        return button
    }()
    
    let stackViewPadding: UIView = {
        let v = UIView()
        return v
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureNavBar()
        NotificationCenter.default.post(name: NSNotification.Name("tabBarColor"), object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        configureNavBar()
        
        signButton.frame = CGRect(x: 40, y: UIScreen.main.bounds.height - 180, width: UIScreen.main.bounds.width - 80, height: 50)
        self.view.insertSubview(signButton, at: 4)
        
        //Add and setup scroll view
        self.view.addSubview(self.scrollView)

        scrollView.anchor(top: view.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: signButton.topAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 10, paddingRight: 0)
        
        self.scrollView.addSubview(self.stackView)

        stackView.anchor(top: scrollView.topAnchor, left: scrollView.leftAnchor, bottom: scrollView.bottomAnchor, right: scrollView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingRight: 0)
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.axis = .vertical
        self.stackView.spacing = 10;
        self.stackView.distribution = .fillProportionally
        self.stackView.alignment = .center
        
        //constrain width of stack view to height of self.view, NOT scroll view
        self.stackView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height ).isActive = true;
        self.stackView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true;
        
//        tokenImg.frame = CGRect(x: 75, y: 10, width: UIScreen.main.bounds.width - 150, height: UIScreen.main.bounds.width - 150)
//        self.stackView.insertSubview(tokenImg, at: 4)
//
//        self.stackView.insertSubview(nftInfoLabel, at: 4)
//        nftInfoLabel.anchor(top: tokenImg.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: signButton.topAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 15, paddingLeft: 40, paddingRight: 40)
        
        
        let tokenImgWidthConstraint = tokenImg.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 2/3)
        let tokenImgHeightConstraint = tokenImg.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 2/3)
        tokenImg.addConstraints([tokenImgWidthConstraint, tokenImgHeightConstraint])
        self.stackView.addArrangedSubview(tokenImg)
        
        self.stackView.addArrangedSubview(nftInfoLabel)
        
        let signersHeightConstraint = viewSignersButton.heightAnchor.constraint(equalToConstant: 50)
        let signersWidthConstraint = viewSignersButton.widthAnchor.constraint(equalToConstant: 200)
        viewSignersButton.addConstraints([signersHeightConstraint, signersWidthConstraint])
        self.stackView.addArrangedSubview(viewSignersButton)
        
        let paddingHeightConstraint = stackViewPadding.heightAnchor.constraint(equalToConstant: 100)
        let paddingWidthConstraint = stackViewPadding.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.height * 0.7)
        stackViewPadding.addConstraints([paddingHeightConstraint, paddingWidthConstraint])
        self.stackView.addArrangedSubview(stackViewPadding)
    }
    
    func configureNavBar() {
        let textAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18), NSAttributedString.Key.foregroundColor : UIColor.black]
        let navLabel = UILabel()
        navLabel.attributedText = NSAttributedString(string: "Token Info", attributes: textAttributes)
        navigationItem.titleView = navLabel
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.backgroundColor = UIColor.init(white: 1, alpha: 1)
        self.navigationController?.navigationBar.barTintColor = UIColor.init(white: 1, alpha: 1)
        self.view.backgroundColor = UIColor.init(white: 1, alpha: 1)
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .black
    }
    
    func setupNFTInfo() {
        guard let QRCodeValue = QRCodeValue else { return }
        
        // normally we would parse for a contract address and for a token id
        if QRCodeValue == "https://apps.apple.com/in/app/bitsig/id1566975289" {
            Database.database().fetchToken(tokenID: "1", completion: { (token) in
                print(token.imgURL)
                let url = URL(string: token.imgURL)
                self.tokenImg.kf.setImage(with: url)
                self.tokenImg.isHidden = false
                
                let attributedText = NSMutableAttributedString(string: "Name:\n", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 20)])
                attributedText.append(NSMutableAttributedString(string: token.name + "\n\n", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)]))
                attributedText.append(NSMutableAttributedString(string: "Description:\n", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 20)]))
                attributedText.append(NSMutableAttributedString(string: token.description + "\n\n", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)]))
                attributedText.append(NSMutableAttributedString(string: "Token ID:\n", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 20)]))
                attributedText.append(NSMutableAttributedString(string: token.tokenID, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)]))
                self.nftInfoLabel.attributedText = attributedText
            })
        }
    }
    
    @objc func goToSuccessfulSignController() {
        UIView.animate(withDuration: 0.5) {
            self.viewSignersButton.alpha = 0
            self.tokenImg.alpha = 0
            self.nftInfoLabel.alpha = 0
            self.signButton.alpha = 0
            self.scrollView.alpha = 0
        }
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { timer in
            let successfulSignController = SuccessfulSignController()
            successfulSignController.modalPresentationStyle = .fullScreen
            self.present(successfulSignController, animated: false, completion: nil)
        }
         
        let successfulSignController = SuccessfulSignController()
        successfulSignController.modalPresentationStyle = .fullScreen
        self.present(successfulSignController, animated: false, completion: nil)
    }
    
    @objc func signToken() {
        // signing token if no User in database with uid brings up a page
        // for them to optionally enter their name and connect their twitter
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        Database.database().userExists(withUID: currentLoggedInUserId, completion: { (exists) in
            if exists{
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

                        Database.database().signToken(eth_address: wallet.address, token_id: "1") {
                            self.goToSuccessfulSignController()
                        }
                    }
                    else {
                        let alert = UIAlertController(title: "An Error Occured.", message: "Log out and log back in to resolve.", preferredStyle: .alert)
                        self.present(alert, animated: true, completion: nil)
                        let when = DispatchTime.now() + 1
                        DispatchQueue.main.asyncAfter(deadline: when){
                            alert.dismiss(animated: true, completion: nil)
                        }
                    }
                }
                else {
                    let alert = UIAlertController(title: "An Error Occured.", message: "Log out and log back in to resolve.", preferredStyle: .alert)
                    self.present(alert, animated: true, completion: nil)
                    let when = DispatchTime.now() + 1
                    DispatchQueue.main.asyncAfter(deadline: when){
                        alert.dismiss(animated: true, completion: nil)
                    }
                }
            }
            else {
                guard let QRCodeValue = self.QRCodeValue else { return }
                if QRCodeValue == "https://apps.apple.com/in/app/bitsig/id1566975289" {
                    let contract_address = ""
                    let token_id = "1"
                    let addNameController = AddNameController()
                    addNameController.modalPresentationStyle = .fullScreen
                    addNameController.token_id = token_id
                    self.present(addNameController, animated: true, completion: nil)
                }
            }
        })
        
        guard let QRCodeValue = QRCodeValue else { return }
        if QRCodeValue == "https://apps.apple.com/in/app/bitsig/id1566975289" {
            let contract_address = ""
            let token_id = "1"
            
            
            // Don't need all of this yet. In the future will send over the address, public key,
            // and a private key encrypted message holding the token id
//            let password_service = "passService"
//            let mnemonics_service = "mnemonicsService"
//            let account = "myAccount"
//            if let password = KeychainService.loadPassword(service: password_service, account: account) {
//                if let mnemonics = KeychainService.loadPassword(service: mnemonics_service, account: account) {
//                    // get wallet
//                    let keystore = try! BIP32Keystore(
//                        mnemonics: mnemonics,
//                        password: password,
//                        mnemonicsPassword: "",
//                        language: .english)!
//                    let name = "New HD Wallet"
//                    let keyData = try! JSONEncoder().encode(keystore.keystoreParams)
//                    let address = keystore.addresses!.first!.address
//                    let wallet = Wallet(address: address, data: keyData, name: name, isHD: true)
//
//                    // get KeyStore Manager
//                    let data = wallet.data
//                    let keystoreManager: KeystoreManager
//                    if wallet.isHD {
//                        let keystore = BIP32Keystore(data)!
//                        keystoreManager = KeystoreManager([keystore])
//                    } else {
//                        let keystore = EthereumKeystoreV3(data)!
//                        keystoreManager = KeystoreManager([keystore])
//                    }
//
//                    // get private key
//                    let ethereumAddress = EthereumAddress(wallet.address)!
//                    let privateKey = try! keystoreManager.UNSAFE_getPrivateKeyData(password: password, account: ethereumAddress).toHexString()
//                    do {
//                        guard let signature = try Web3Signer.signPersonalMessage("personalMessage".data(using: .utf8)!, keystore: keystoreManager, account: ethereumAddress, password: password) else {return}
//                        print(signature.toHexString())
//
//                    }
//                    catch{
//                        print(error)
//                        return
//                    }
//                }
//                else {
//                    let alert = UIAlertController(title: "An Error Occured.", message: "Log out and log back in to resolve.", preferredStyle: .alert)
//                    self.present(alert, animated: true, completion: nil)
//                    let when = DispatchTime.now() + 1
//                    DispatchQueue.main.asyncAfter(deadline: when){
//                        alert.dismiss(animated: true, completion: nil)
//                    }
//                }
//            }
//            else {
//                let alert = UIAlertController(title: "An Error Occured.", message: "Log out and log back in to resolve.", preferredStyle: .alert)
//                self.present(alert, animated: true, completion: nil)
//                let when = DispatchTime.now() + 1
//                DispatchQueue.main.asyncAfter(deadline: when){
//                    alert.dismiss(animated: true, completion: nil)
//                }
//            }
        }
    }
}
