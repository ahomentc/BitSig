//
//  CreateWalletController.swift
//  BitSigApp
//
//  Created by Andrei Homentcovschi on 5/10/21.
//  Copyright © 2021 Andrei Homentcovschi. All rights reserved.
//

import Foundation
import UIKit
import web3swift
import FirebaseAuth
import SAConfettiView

// need option to import account too

class CreateWalletController: UIViewController {
    
    let confettiView = SAConfettiView()
    var mnemonics = ""
    var equal_mnemonics = ""
    
    // need an "or login" button
    
    private lazy var walletExplanationLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.black
        label.layer.zPosition = 4
        label.numberOfLines = 0
        label.textAlignment = .center
        let attributedText = NSMutableAttributedString(string: "Woooo!\n\n", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 25)])
        attributedText.append(NSMutableAttributedString(string: "You're almost done!\nJust create a wallet to finish.\n\n", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 20)]))
        label.attributedText = attributedText
        return label
    }()
    
    private lazy var walletExplanationTwoLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.black
        label.layer.zPosition = 4
        label.numberOfLines = 0
        label.isUserInteractionEnabled = false
        label.textAlignment = .center
        let attributedText = NSMutableAttributedString(string: "Your wallet will get funds from\nNFTs that you've signed!", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)])
        label.attributedText = attributedText
        return label
    }()
    
    private lazy var recoveryLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.black
        label.layer.zPosition = 4
        label.numberOfLines = 0
        label.textAlignment = .center
        label.isHidden = true
        let attributedText = NSMutableAttributedString(string: "Your recovery phrase\n\n", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 25)])
        attributedText.append(NSMutableAttributedString(string: "Write down or copy these words in the\nright order and save them somewhere safe.\nNever share them with anyone!", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)]))
        label.attributedText = attributedText
        return label
    }()
    
    private lazy var mnemonicsLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.init(white: 0.95, alpha: 1)
        label.textColor = UIColor.black
        label.layer.zPosition = 4
        label.numberOfLines = 0
        label.layer.cornerRadius = 20
        label.clipsToBounds = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(copyMnemonics)))
        label.isUserInteractionEnabled  = true
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    private lazy var emailTextField: UITextField = {
        let tf = UITextField()
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        tf.keyboardType = .emailAddress
        tf.placeholder = "Email"
        tf.backgroundColor = UIColor(white: 0, alpha: 0)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.delegate = self
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    
    private lazy var passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true
        tf.backgroundColor = UIColor(white: 0, alpha: 0)
        tf.borderStyle = .roundedRect
        tf.layer.cornerRadius = 20
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.delegate = self
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    
    private lazy var passwordMatchTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Confirm Password"
        tf.isSecureTextEntry = true
        tf.backgroundColor = UIColor(white: 0, alpha: 0)
        tf.borderStyle = .roundedRect
        tf.layer.cornerRadius = 20
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.delegate = self
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()

    private let submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create Wallet", for: .normal)
        button.backgroundColor = UIColor(red: 0/255, green: 166/255, blue: 107/255, alpha: 1)
        button.layer.cornerRadius = 15
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    private lazy var finishWallet: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Done", for: .normal)
        button.backgroundColor = UIColor(red: 0/255, green: 166/255, blue: 107/255, alpha: 1)
        button.layer.cornerRadius = 15
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(closeWalletCreation), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    // this closes and then a view is presented that shows information about the token and a sign button

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
        
        confettiView.frame = self.view.bounds
        self.view.addSubview(confettiView)
        confettiView.intensity = 0.75
        self.confettiView.startConfetti()
        Timer.scheduledTimer(withTimeInterval: 1.2, repeats: false) { timer in
            self.confettiView.stopConfetti()
        }
        
        walletExplanationLabel.frame = CGRect(x: 20, y: 30, width: UIScreen.main.bounds.width - 40, height: 170)
        self.view.insertSubview(walletExplanationLabel, at: 4)
        
        walletExplanationTwoLabel.frame = CGRect(x: 20, y: UIScreen.main.bounds.height - 100, width: UIScreen.main.bounds.width - 40, height: 50)
        self.view.insertSubview(walletExplanationTwoLabel, at: 4)
        
        recoveryLabel.frame = CGRect(x: 20, y: 20, width: UIScreen.main.bounds.width - 40, height: 200)
        self.view.insertSubview(recoveryLabel, at: 4)
        
        let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, passwordMatchTextField, submitButton])
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 10
        
        view.addSubview(stackView)
        stackView.anchor(top: walletExplanationLabel.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 10, paddingLeft: 40, paddingRight: 40, height: 214)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        finishWallet.frame = CGRect(x: 40, y: UIScreen.main.bounds.height - 100, width: UIScreen.main.bounds.width - 80, height: 50)
        self.view.insertSubview(finishWallet, at: 4)
        
        mnemonicsLabel.frame = CGRect(x: 20, y: UIScreen.main.bounds.height/2 - 100, width: UIScreen.main.bounds.width - 40, height: 200)
        self.view.insertSubview(mnemonicsLabel, at: 10)
    
    }
    
    @objc private func handleTextInputChange() {
        let isFormValid = passwordTextField.text?.isEmpty == false && passwordMatchTextField.text?.isEmpty == false
        if isFormValid {
            submitButton.isEnabled = true
            submitButton.backgroundColor = UIColor(red: 0/255, green: 166/255, blue: 107/255, alpha: 1)
        } else {
            submitButton.isEnabled = false
            submitButton.backgroundColor = UIColor(red: 0/255, green: 166/255, blue: 107/255, alpha: 0.7)
        }
    }
    
    @objc private func handleSignUp() {
        guard let password = passwordTextField.text else { return }
        guard let passwordMatch = passwordMatchTextField.text else { return }
        guard let email = emailTextField.text else { return }
        
        if password != passwordMatch {
            self.passwordTextField.text = ""
            self.passwordMatchTextField.text = ""
            let alert = UIAlertController(title: "", message: "Passwords don't match", preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
            let when = DispatchTime.now() + 1
            DispatchQueue.main.asyncAfter(deadline: when){
                alert.dismiss(animated: true, completion: nil)
            }
            return
        }
        
        passwordTextField.isUserInteractionEnabled = false
        emailTextField.isUserInteractionEnabled = false
        passwordMatchTextField.isUserInteractionEnabled = false
        submitButton.isEnabled = false
        submitButton.backgroundColor = UIColor(red: 0/255, green: 166/255, blue: 107/255, alpha: 0.7)
        
        self.createWallet(password: password)
//        Auth.auth().createUser(withEmail: email, password: password) { (err) in
//            self.createWallet(password: password)
//        }
    }
    
    func createWallet(password: String) {
        // make everything disappear
        UIView.animate(withDuration: 0.5) {
            self.emailTextField.alpha = 0
            self.passwordTextField.alpha = 0
            self.passwordMatchTextField.alpha = 0
            self.submitButton.alpha = 0
            self.walletExplanationLabel.alpha = 0
            self.walletExplanationTwoLabel.alpha = 0
        }
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { timer in
            self.emailTextField.isHidden = true
            self.passwordTextField.isHidden = true
            self.passwordMatchTextField.isHidden = true
            self.submitButton.isHidden = true
            self.walletExplanationLabel.isHidden = true
            self.walletExplanationTwoLabel.isHidden = true
            
            let bitsOfEntropy: Int = 128 // Entropy is a measure of password strength. Usually used 128 or 256 bits.
            let mnemonics = try! BIP39.generateMnemonics(bitsOfEntropy: bitsOfEntropy)!
            self.mnemonics = mnemonics
            self.displayMnemonics(mnemonics: mnemonics)
    //        let keystore = try! BIP32Keystore(
    //            mnemonics: mnemonics,
    //            password: password,
    //            mnemonicsPassword: "",
    //            language: .english)!
    //        let name = "New HD Wallet"
    //        let keyData = try! JSONEncoder().encode(keystore.keystoreParams)
    //        let address = keystore.addresses!.first!.address
    //        let wallet = Wallet(address: address, data: keyData, name: name, isHD: true)
        }
    }
    
    func displayMnemonics(mnemonics: String) {
        var components = mnemonics.components(separatedBy: " ")

        components.insert("\n", at: 3)
        components.insert("\n", at: 7)
        components.insert("\n", at: 11)
        let equal_mnemonics = components.joined(separator:" ")
        self.equal_mnemonics = equal_mnemonics
        
        let attributedText = NSMutableAttributedString(string: equal_mnemonics, attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 23)])
        attributedText.append(NSMutableAttributedString(string: "\n\ncopy to clipboard", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.init(white: 0.3, alpha: 1)]))
        self.mnemonicsLabel.attributedText = attributedText
        self.mnemonicsLabel.isHidden = false
        self.recoveryLabel.isHidden = false
        self.finishWallet.isHidden = false
        self.mnemonicsLabel.alpha = 0
        self.recoveryLabel.alpha = 0
        self.finishWallet.alpha = 0
        UIView.animate(withDuration: 0.5) {
            self.mnemonicsLabel.alpha = 1
            self.recoveryLabel.alpha = 1
            self.finishWallet.alpha = 1
        }
    }
    
    @objc func copyMnemonics() {
        UIPasteboard.general.string = self.mnemonics
        let attributedText = NSMutableAttributedString(string: self.equal_mnemonics, attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 23)])
        attributedText.append(NSMutableAttributedString(string: "\n\ncopied", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.init(white: 0.3, alpha: 1)]))
        self.mnemonicsLabel.attributedText = attributedText
    }
    
    @objc func closeWalletCreation() {
        print("hi")
        self.dismiss(animated: true, completion: {})
    }
    
    @objc func dismissKeyboard() {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        passwordMatchTextField.resignFirstResponder()
    }
}

extension CreateWalletController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
