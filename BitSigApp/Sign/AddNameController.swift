//
//  AddNameController.swift
//  BitSigApp
//
//  Created by Andrei Homentcovschi on 5/12/21.
//  Copyright © 2021 Andrei Homentcovschi. All rights reserved.
//

import Foundation
import UIKit
import web3swift
import Firebase
import FirebaseAuth
import FirebaseDatabase

// need option to import account too

class AddNameController: UIViewController {
    
    var token_id = "1"
    
    private lazy var addNameExplanationLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.black
        label.layer.zPosition = 4
        label.numberOfLines = 0
        label.textAlignment = .center
        let attributedText = NSMutableAttributedString(string: "Sign with more info\n\n", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 20)])
//        attributedText.append(NSMutableAttributedString(string: "Optionally add your name or twitter for\nothers to see you're one of the signers!", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)]))
        attributedText.append(NSMutableAttributedString(string: "Optionally add your name or twitter to have\nthem on them appear on the \"signers\" page!", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)]))
        label.attributedText = attributedText
        return label
    }()
    
    private lazy var nameTextField: UITextField = {
        let tf = UITextField()
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        tf.placeholder = "Name"
        tf.backgroundColor = UIColor(white: 0, alpha: 0)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 16)
        return tf
    }()
    
    private let connectTwitterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Connect Twitter", for: .normal)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 15
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(red: 0/255, green: 166/255, blue: 107/255, alpha: 1).cgColor
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(UIColor(red: 0/255, green: 166/255, blue: 107/255, alpha: 1), for: .normal)
//        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        return button
    }()
    
    private lazy var submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Continue", for: .normal)
        button.backgroundColor = UIColor(red: 0/255, green: 166/255, blue: 107/255, alpha: 1)
        button.layer.cornerRadius = 15
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(finish), for: .touchUpInside)
        return button
    }()
    
    private lazy var skipButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Skip", for: .normal)
        button.backgroundColor = UIColor.clear
        button.layer.cornerRadius = 15
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(UIColor(red: 0/255, green: 166/255, blue: 107/255, alpha: 1), for: .normal)
        button.addTarget(self, action: #selector(finish), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.backgroundColor = UIColor.init(white: 1, alpha: 1)
        self.navigationController?.navigationBar.barTintColor = UIColor.init(white: 1, alpha: 1)
        self.view.backgroundColor = UIColor.init(white: 1, alpha: 1)
        
        addNameExplanationLabel.frame = CGRect(x: 20, y: 30, width: UIScreen.main.bounds.width - 40, height: 170)
        self.view.insertSubview(addNameExplanationLabel, at: 4)
        
       
        let stackView = UIStackView(arrangedSubviews: [nameTextField, connectTwitterButton, submitButton, skipButton])
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 15
        
        self.view.insertSubview(stackView, at: 4)
        stackView.anchor(top: addNameExplanationLabel.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 20, paddingLeft: 40, paddingRight: 40, height: 234)
        
//        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
//        view.addGestureRecognizer(tap)
    }
    
    @objc func finish() {
        // create user account, regardless of having name or not
        // options of it:
        // eth address
        // name
        // verified twitter
        // profile image
        
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
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

                Database.database().uploadUser(withUID: currentLoggedInUserId, eth_address: wallet.address, name: nameTextField.text ?? "", token_id: token_id) {
                    let successfulSignController = SuccessfulSignController()
                    self.navigationController?.pushViewController(successfulSignController, animated: true)
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
    
    @objc func dismissKeyboard() {
        nameTextField.resignFirstResponder()
    }
}
