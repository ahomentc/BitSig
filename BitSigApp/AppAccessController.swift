//
//  AppAccessController.swift
//  BitSigApp
//
//  Created by Andrei Homentcovschi on 5/12/21.
//  Copyright © 2021 Andrei Homentcovschi. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase

// option to get placed on waitlist if they don't have a code.
// Auto add them and send notification after 2 days

class AppAccessController: UIViewController {
    
    private let logo: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.image = #imageLiteral(resourceName: "Logo")
        iv.layer.zPosition = 5
        return iv
    }()
    
    private lazy var welcomeLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.black
        label.layer.zPosition = 4
        label.numberOfLines = 0
        label.textAlignment = .left
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 3
        
        let attributedText = NSMutableAttributedString(string: "Welcome! 👋 \n\n", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 20)])
        attributedText.append(NSMutableAttributedString(string: "Anyone can join with an invite from an existing user.\n\nOtherwise, get on the waitlist and you'll get a notification when we grant you access.\n\nWe're limiting access to BitSig to make sure nothing breaks.\n\nThanks for your patience and we can't wait for you to join!", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)]))
        label.attributedText = attributedText
        return label
    }()
    
    private lazy var waitlistCodeLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.black
        label.layer.zPosition = 4
        label.numberOfLines = 0
        label.textAlignment = .center
        label.isHidden = true
        
        let attributedText = NSMutableAttributedString(string: "You're on the waitlist!\n\n", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 20)])
        attributedText.append(NSMutableAttributedString(string: "You'll get a notification with an invite\ncode when we give you access.", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)]))
        label.attributedText = attributedText
        return label
    }()
    
    private lazy var codeTextField: UITextField = {
        let tf = UITextField()
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        tf.placeholder = "Enter invite code"
        tf.backgroundColor = UIColor(white: 1, alpha: 1)
//        tf.borderStyle = .roundedRect
        tf.textAlignment = .center
//        tf.layer.cornerRadius = 20
//        tf.clipsToBounds = true
        tf.isHidden = true
        tf.layer.zPosition = 4
        tf.font = UIFont.systemFont(ofSize: 16)
        return tf
    }()
    
    private lazy var submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Get in! 🎉", for: .normal)
        button.backgroundColor = UIColor(red: 0/255, green: 166/255, blue: 107/255, alpha: 1)
        button.layer.cornerRadius = 20
        button.layer.zPosition = 4
        button.isHidden = true
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(submitCode), for: .touchUpInside)
        return button
    }()
    
    private lazy var signInButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Already have an account? Sign in", for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 20
        button.layer.zPosition = 4
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(UIColor(red: 0/255, green: 166/255, blue: 107/255, alpha: 1), for: .normal)
        button.addTarget(self, action: #selector(signIn), for: .touchUpInside)
        return button
    }()

    private lazy var inviteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Enter invite code", for: .normal)
        button.backgroundColor = UIColor(red: 0/255, green: 166/255, blue: 107/255, alpha: 1)
        button.layer.cornerRadius = 20
        button.layer.zPosition = 4
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(inviteCodeSelected), for: .touchUpInside)
        return button
    }()
    
    private lazy var waitlistButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Get on waitlist", for: .normal)
        button.backgroundColor = UIColor(red: 0/255, green: 166/255, blue: 107/255, alpha: 1)
        button.layer.cornerRadius = 20
        button.layer.zPosition = 4
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(waitlistSelected), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.backgroundColor = UIColor.init(white: 1, alpha: 1)
        self.navigationController?.navigationBar.barTintColor = UIColor.init(white: 1, alpha: 1)
        self.view.backgroundColor = UIColor.init(white: 1, alpha: 1)
        
        self.view.insertSubview(logo, at: 4)
        logo.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: UIScreen.main.bounds.width/2-100, paddingRight: UIScreen.main.bounds.width/2-100, height: 80)
        
        self.view.insertSubview(welcomeLabel, at: 4)
        welcomeLabel.anchor(top: logo.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 35, paddingLeft: 30, paddingRight: 30)
       
        let stackView = UIStackView(arrangedSubviews: [inviteButton, waitlistButton, signInButton])
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 10
        
        self.view.insertSubview(stackView, at: 4)
        stackView.anchor(left: view.safeAreaLayoutGuide.leftAnchor, bottom: view.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingLeft: 40, paddingBottom: 10, paddingRight: 30, height: 175)
        
        
        let inviteStackView = UIStackView(arrangedSubviews: [codeTextField, submitButton])
        inviteStackView.distribution = .fillEqually
        inviteStackView.axis = .vertical
        inviteStackView.spacing = 25
        
        self.view.insertSubview(inviteStackView, at: 4)
        inviteStackView.anchor(top: view.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 200, paddingLeft: 40, paddingRight: 40, height: 127)
        
        self.view.insertSubview(waitlistCodeLabel, at: 4)
        waitlistCodeLabel.anchor(top: logo.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 45, paddingLeft: 30, paddingRight: 30)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        self.inviteButton.alpha = 0
        self.waitlistButton.alpha = 0
        self.welcomeLabel.alpha = 0
        self.logo.alpha = 0
        self.signInButton.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0.5) {
            self.inviteButton.alpha = 1
            self.waitlistButton.alpha = 1
            self.welcomeLabel.alpha = 1
            self.logo.alpha = 1
            self.signInButton.alpha = 1
        }
    }
    
    @objc func inviteCodeSelected() {
        UIView.animate(withDuration: 0.5) {
            self.inviteButton.alpha = 0
            self.waitlistButton.alpha = 0
            self.welcomeLabel.alpha = 0
            self.signInButton.alpha = 0
        }
        
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { timer in
            self.inviteButton.isHidden = true
            self.waitlistButton.isHidden = true
            self.welcomeLabel.isHidden = true
            self.signInButton.isHidden = true
        }
            
        self.submitButton.alpha = 0
        self.submitButton.isHidden = false
        self.codeTextField.alpha = 0
        self.codeTextField.isHidden = false
        UIView.animate(withDuration: 0.5, delay: 0.5) {
            self.submitButton.alpha = 1
            self.codeTextField.alpha = 1
        }
    }
    
    @objc func waitlistSelected() {
        Database.database().addUserToWaitlist() { (err) in }
        
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { timer in
            let pushManager = PushNotificationManager()
            pushManager.registerForPushNotifications()
        }
        
        UIView.animate(withDuration: 0.5) {
            self.inviteButton.alpha = 0
            self.waitlistButton.alpha = 0
            self.welcomeLabel.alpha = 0
            self.signInButton.alpha = 0
        }
        
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { timer in
            self.inviteButton.isHidden = true
            self.waitlistButton.isHidden = true
            self.welcomeLabel.isHidden = true
            self.signInButton.isHidden = true
        }
            
        self.waitlistCodeLabel.alpha = 0
        self.waitlistCodeLabel.isHidden = false
        UIView.animate(withDuration: 0.5, delay: 0.5) {
            self.waitlistCodeLabel.alpha = 1
        }
    }
    
    @objc func submitCode() {
        guard let code = self.codeTextField.text else { return }
        Database.database().inviteCodeValid(code: code.lowercased(), completion: { (isValid) in
            if (isValid == true) {
                if let passedInvite = try? JSONEncoder().encode(true) {
                    UserDefaults.standard.set(passedInvite, forKey: "passedInvite")
                }
                Database.database().removeUserFromWaitlist() { (err) in }
                Database.database().subtractFromInviteCode(code: code) { (err) in }
                if let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController {
                    mainTabBarController.setupViewControllers()
                    mainTabBarController.selectedIndex = 0
                    self.dismiss(animated: true, completion: nil)
                }
            }
            else {
                let alert = UIAlertController(title: "", message: "Invite code not valid or expired", preferredStyle: .alert)
                self.present(alert, animated: true, completion: nil)
                let when = DispatchTime.now() + 1
                DispatchQueue.main.asyncAfter(deadline: when){
                    alert.dismiss(animated: true, completion: nil)
                }
            }
        })
    }
    
    @objc func signIn() {
        if let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController {
            mainTabBarController.setupViewControllers()
            mainTabBarController.selectedIndex = 0
            self.dismiss(animated: true, completion: {
                // send message saying it should log in
                NotificationCenter.default.post(name: NSNotification.Name("sendToLogin"), object: nil)
            })
        }
    }
    
    @objc func dismissKeyboard() {
        codeTextField.resignFirstResponder()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
//            self.bottomView.frame.origin.y = 0 - 100
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
//        self.bottomView.frame.origin.y = 0
    }
}
