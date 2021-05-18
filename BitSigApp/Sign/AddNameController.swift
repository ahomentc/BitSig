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
import SwiftyJSON

// need option to import account too

protocol AddNameControllerDelegate{
    func goToSuccessfulSignController()
}


class AddNameController: UIViewController, UINavigationControllerDelegate {
    
    var token_id = "1"
    var delegate: AddNameControllerDelegate?
    
    var twitter_username = ""
    var followers_count = 0
    
    private var profileImage: UIImage?
    
    private let plusPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "plus_photo"), for: .normal)
        button.layer.masksToBounds = true
        button.tintColor = UIColor(red: 0/255, green: 166/255, blue: 107/255, alpha: 1)
        button.imageView?.contentMode = .scaleAspectFill
        button.addTarget(self, action: #selector(handlePlusPhoto), for: .touchUpInside)
        return button
    }()
    
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
    
    private lazy var connectTwitterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Connect Twitter", for: .normal)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 15
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(red: 0/255, green: 166/255, blue: 107/255, alpha: 1).cgColor
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(UIColor(red: 0/255, green: 166/255, blue: 107/255, alpha: 1), for: .normal)
        button.addTarget(self, action: #selector(connectTwitter), for: .touchUpInside)
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
        
        view.addSubview(plusPhotoButton)
        plusPhotoButton.anchor(top: addNameExplanationLabel.bottomAnchor, paddingTop: 5, width: 140, height: 140)
        plusPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        plusPhotoButton.layer.cornerRadius = 140 / 2
       
        let stackView = UIStackView(arrangedSubviews: [nameTextField, connectTwitterButton, submitButton, skipButton])
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 15
        
        self.view.insertSubview(stackView, at: 4)
        stackView.anchor(top: plusPhotoButton.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 30, paddingLeft: 40, paddingRight: 40, height: 234)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    var provider = OAuthProvider(providerID: "twitter.com")
    @objc func connectTwitter() {
        guard let user = Auth.auth().currentUser else { return }
//        Auth.auth().currentUser?.unlink(fromProvider: "twitter.com") { (user, error) in
//          // ...
//        }
            
        print("connecting twitter")
        provider.getCredentialWith(nil) { credential, error in
            if error != nil {
            }
            if credential != nil {
                user.link(with: credential!) { (authResult, error) in
                    if error != nil {
                    // Handle error.
                    }
                    // Twitter credential is linked to the current user.
                    // IdP data available in authResult.additionalUserInfo.profile.
                    // Twitter OAuth access token can also be retrieved by:
                    // authResult.credential.accessToken
                    // Twitter OAuth ID token can be retrieved by calling:
                    // authResult.credential.idToken
                    // Twitter OAuth secret can be retrieved by calling:
                    // authResult.credential.secret
                    
                    let twitter_info = authResult?.additionalUserInfo?.profile as! Dictionary<String, NSObject>
                    let username = twitter_info["screen_name"] as! String
                    let profile_image_url = twitter_info["profile_image_url"] as! String
                    let verified = twitter_info["verified"] as! Int
                    let followers_count = twitter_info["followers_count"] as! NSNumber
                    let id_str = twitter_info["id_str"] as! String
                    
                    self.twitter_username = username
                    self.followers_count = followers_count.intValue
                    
                    self.connectTwitterButton.setTitle("Connected to: " + self.twitter_username, for: .normal)
                    self.connectTwitterButton.layer.borderWidth = 0
                    self.connectTwitterButton.isEnabled = true
                    
                    Database.database().createTwitterUser(withUID: user.uid, username: username, profile_image_url: profile_image_url, followers_count: followers_count.intValue, verified: verified, id: id_str) {}
                }
            }
        }
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
                print(password)
                let keystore = try! BIP32Keystore(
                    mnemonics: mnemonics,
                    password: password,
                    mnemonicsPassword: "",
                    language: .english)!
                let name = "New HD Wallet"
                let keyData = try! JSONEncoder().encode(keystore.keystoreParams)
                let address = keystore.addresses!.first!.address
                let wallet = Wallet(address: address, data: keyData, name: name, isHD: true)

                Database.database().uploadUser(withUID: currentLoggedInUserId, eth_address: wallet.address, name: nameTextField.text ?? "", twitter_username: twitter_username, followers_count: followers_count, token_id: token_id, profileImage: profileImage) {
                    self.dismiss(animated: true, completion: {
                        self.delegate?.goToSuccessfulSignController()
                    })
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
    
    @objc private func handlePlusPhoto() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @objc func dismissKeyboard() {
        nameTextField.resignFirstResponder()
    }
}

extension AddNameController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {


        if let editedImage = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            plusPhotoButton.setImage(editedImage.withRenderingMode(.alwaysOriginal), for: .normal)
            profileImage = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerOriginalImage")] as? UIImage {
            plusPhotoButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
            profileImage = originalImage
        }
        plusPhotoButton.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
        plusPhotoButton.layer.borderWidth = 0.5
        dismiss(animated: true, completion: nil)
    }
}
