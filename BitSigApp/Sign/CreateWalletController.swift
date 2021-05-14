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

protocol CreateWalletControllerDelegate{
    func goToTokenSignPage(QRValue: String)
}

class CreateWalletController: UIViewController {
    
    let confettiView = SAConfettiView()
    var mnemonics = ""
    var equal_mnemonics = ""
    var QRCodeValue = ""
    var isLogin = false
    
    var delegate: CreateWalletControllerDelegate?
    
    // need an "or login" button
    
    private lazy var walletExplanationLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.black
        label.layer.zPosition = 4
        label.numberOfLines = 0
        label.textAlignment = .center
        let attributedText = NSMutableAttributedString(string: "Woooo!\n\n", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 25)])
        attributedText.append(NSMutableAttributedString(string: "You're almost in!\nJust create a wallet to finish.\n\n", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 20)]))
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
    
    private lazy var restoreWalletButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login to Wallet", for: .normal)
        button.backgroundColor = UIColor.clear
        button.setTitleColor(UIColor(red: 0/255, green: 166/255, blue: 107/255, alpha: 1), for: .normal)
        button.layer.cornerRadius = 15
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(hasRestore), for: .touchUpInside)
        return button
    }()
    
    private lazy var restoreEmailTextField: UITextField = {
        let tf = UITextField()
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        tf.keyboardType = .emailAddress
        tf.placeholder = "Email"
        tf.backgroundColor = UIColor(white: 0, alpha: 0)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.delegate = self
        tf.isHidden = true
        tf.addTarget(self, action: #selector(handleRestoreTextInputChange), for: .editingChanged)
        return tf
    }()
    
    private lazy var restorePasswordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true
        tf.backgroundColor = UIColor(white: 0, alpha: 0)
        tf.borderStyle = .roundedRect
        tf.layer.cornerRadius = 20
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.delegate = self
        tf.isHidden = true
        tf.addTarget(self, action: #selector(handleRestoreTextInputChange), for: .editingChanged)
        return tf
    }()
    
    private lazy var recoveryPhraseTextField: UITextField = {
        let tf = UITextField()
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        tf.placeholder = "Recovery Phrase"
        tf.backgroundColor = UIColor(white: 0, alpha: 0)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.delegate = self
        tf.isHidden = true
        tf.addTarget(self, action: #selector(handleRestoreTextInputChange), for: .editingChanged)
        return tf
    }()
    
    private let submitRestoreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.backgroundColor = UIColor(red: 0/255, green: 166/255, blue: 107/255, alpha: 1)
        button.layer.cornerRadius = 15
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleRestore), for: .touchUpInside)
//        button.isEnabled = false
        button.isHidden = true
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
        
        confettiView.frame = self.view.bounds
        self.view.addSubview(confettiView)
        confettiView.intensity = 0.75
        self.confettiView.startConfetti()
        Timer.scheduledTimer(withTimeInterval: 1.2, repeats: false) { timer in
            self.confettiView.stopConfetti()
        }
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.backgroundColor = UIColor.init(white: 1, alpha: 1)
        self.navigationController?.navigationBar.barTintColor = UIColor.init(white: 1, alpha: 1)
        self.view.backgroundColor = UIColor.init(white: 1, alpha: 1)
        
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
        
        self.view.insertSubview(stackView, at: 4)
        stackView.anchor(top: walletExplanationLabel.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 10, paddingLeft: 40, paddingRight: 40, height: 214)
        
        self.view.insertSubview(restoreWalletButton, at: 4)
        restoreWalletButton.anchor(top: stackView.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 15, paddingLeft: 40, paddingRight: 40, height: 30)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        finishWallet.frame = CGRect(x: 40, y: UIScreen.main.bounds.height - 100, width: UIScreen.main.bounds.width - 80, height: 50)
        self.view.insertSubview(finishWallet, at: 4)
        
        mnemonicsLabel.frame = CGRect(x: 20, y: UIScreen.main.bounds.height/2 - 100, width: UIScreen.main.bounds.width - 40, height: 200)
        self.view.insertSubview(mnemonicsLabel, at: 10)
        
        if isLogin {
            self.hasRestore()
        }
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
    
    @objc private func handleRestoreTextInputChange() {
            let isFormValid = restoreEmailTextField.text?.isEmpty == false && restorePasswordTextField.text?.isEmpty == false
            if isFormValid {
                submitRestoreButton.isEnabled = true
                submitRestoreButton.backgroundColor = UIColor(red: 0/255, green: 166/255, blue: 107/255, alpha: 1)
            } else {
                submitRestoreButton.isEnabled = false
                submitRestoreButton.backgroundColor = UIColor(red: 0/255, green: 166/255, blue: 107/255, alpha: 0.7)
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
        
        let password_service = "passService"
        let mnemonics_service = "mnemonicsService"
        let account = "myAccount"
        
        Auth.auth().createUser(withEmail: email, password: password) { (err) in
            self.createWallet(password: password)
            KeychainService.savePassword(service: password_service, account: account, data: password)
            KeychainService.savePassword(service: mnemonics_service, account: account, data: self.mnemonics)
        }
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
            self.restoreWalletButton.alpha = 0
        }
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { timer in
            self.emailTextField.isHidden = true
            self.passwordTextField.isHidden = true
            self.passwordMatchTextField.isHidden = true
            self.submitButton.isHidden = true
            self.walletExplanationLabel.isHidden = true
            self.walletExplanationTwoLabel.isHidden = true
            self.restoreWalletButton.isHidden = true
            
            let bitsOfEntropy: Int = 128 // Entropy is a measure of password strength. Usually used 128 or 256 bits.
            let mnemonics = try! BIP39.generateMnemonics(bitsOfEntropy: bitsOfEntropy)!
            self.mnemonics = mnemonics
            self.displayMnemonics(mnemonics: mnemonics)
            let keystore = try! BIP32Keystore(
                mnemonics: mnemonics,
                password: password,
                mnemonicsPassword: "",
                language: .english)!
            let name = "New HD Wallet"
            let keyData = try! JSONEncoder().encode(keystore.keystoreParams)
            let address = keystore.addresses!.first!.address
            let wallet = Wallet(address: address, data: keyData, name: name, isHD: true)
            
            if let hasWallet = try? JSONEncoder().encode(true) {
                UserDefaults.standard.set(hasWallet, forKey: "hasWallet")
            }
        }
    }
    
    func restoreWallet() {
        guard let password = self.restorePasswordTextField.text else { return }
        guard let mnemonics = self.recoveryPhraseTextField.text else { return }
        
        // add verification to make sure mnemonics are formatted right
        let keystore = try! BIP32Keystore(
            mnemonics: mnemonics,
            password: password,
            mnemonicsPassword: "",
            language: .english)!
        let name = "New HD Wallet"
        let keyData = try! JSONEncoder().encode(keystore.keystoreParams)
        let address = keystore.addresses!.first!.address
        let wallet = Wallet(address: address, data: keyData, name: name, isHD: true)
        
        if let hasWallet = try? JSONEncoder().encode(true) {
            UserDefaults.standard.set(hasWallet, forKey: "hasWallet")
        }
        
        self.closeWalletCreation()
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
    
    @objc func hasRestore() {
        let attributedText = NSMutableAttributedString(string: "Woooo!\n\n", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 25)])
        attributedText.append(NSMutableAttributedString(string: "You're almost in!\nJust login to your wallet to finish.\n\n", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 20)]))
        walletExplanationLabel.attributedText = attributedText
        
        let restoreStackView = UIStackView(arrangedSubviews: [restoreEmailTextField, restorePasswordTextField, recoveryPhraseTextField, submitRestoreButton])
        restoreStackView.distribution = .fillEqually
        restoreStackView.axis = .vertical
        restoreStackView.spacing = 10
        
        view.addSubview(restoreStackView)
        restoreStackView.anchor(top: walletExplanationLabel.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 10, paddingLeft: 40, paddingRight: 40, height: 214)
        
        self.restoreEmailTextField.isHidden = false
        self.restorePasswordTextField.isHidden = false
        self.recoveryPhraseTextField.isHidden = false
        self.submitRestoreButton.isHidden = false
        
        self.restoreEmailTextField.alpha = 0
        self.restorePasswordTextField.alpha = 0
        self.recoveryPhraseTextField.alpha = 0
        self.submitRestoreButton.alpha = 0
        
        UIView.animate(withDuration: 0.5) {
            self.emailTextField.alpha = 0
            self.passwordTextField.alpha = 0
            self.passwordMatchTextField.alpha = 0
            self.submitButton.alpha = 0
//            self.walletExplanationLabel.alpha = 0
//            self.walletExplanationTwoLabel.alpha = 0
            self.restoreWalletButton.alpha = 0
        }
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { timer in
            self.emailTextField.isHidden = true
            self.passwordTextField.isHidden = true
            self.passwordMatchTextField.isHidden = true
            self.submitButton.isHidden = true
//            self.walletExplanationLabel.isHidden = true
//            self.walletExplanationTwoLabel.isHidden = true
            self.restoreWalletButton.isHidden = true
            
            UIView.animate(withDuration: 0.5) {
                self.restoreEmailTextField.alpha = 1
                self.restorePasswordTextField.alpha = 1
                self.recoveryPhraseTextField.alpha = 1
                self.submitRestoreButton.alpha = 1
            }
        }
    }
    
    @objc func handleRestore() {
        guard let email = self.restoreEmailTextField.text else { return }
        guard let password = self.restorePasswordTextField.text else { return }
        guard let mnemonics = self.recoveryPhraseTextField.text else { return }
        
        let password_service = "passService"
        let mnemonics_service = "mnemonicsService"
        let account = "myAccount"
        
        submitRestoreButton.isEnabled = false
        submitRestoreButton.backgroundColor = UIColor(red: 0/255, green: 166/255, blue: 107/255, alpha: 0.7)
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, err) in
            if let err = err {
                print("Failed to sign in with email:", err)
                self.resetRestoreInputFields()
                return
            }
            if let passedInvite = try? JSONEncoder().encode(true) {
                UserDefaults.standard.set(passedInvite, forKey: "passedInvite")
            }
            KeychainService.savePassword(service: password_service, account: account, data: password)
            KeychainService.savePassword(service: mnemonics_service, account: account, data: mnemonics)
            self.restoreWallet()
        })
        
    }
    
    private func resetRestoreInputFields() {
        restorePasswordTextField.text = ""
        restoreEmailTextField.isUserInteractionEnabled = true
        restorePasswordTextField.isUserInteractionEnabled = true
        
        submitRestoreButton.isEnabled = false
        submitRestoreButton.backgroundColor = UIColor(red: 0/255, green: 166/255, blue: 107/255, alpha: 0.7)
    }
    
    @objc func closeWalletCreation() {
        self.dismiss(animated: true, completion: {
            if self.QRCodeValue != "" {
                self.delegate?.goToTokenSignPage(QRValue: self.QRCodeValue)
            }
        })
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
