//
//  SuccessfulSignController.swift
//  BitSigApp
//
//  Created by Andrei Homentcovschi on 5/12/21.
//  Copyright © 2021 Andrei Homentcovschi. All rights reserved.
//

import Foundation
import UIKit
import Lottie
import Firebase
import FirebaseAuth
import FirebaseDatabase

// need option to import account too

class SuccessfulSignController: UIViewController {
    
    private var animationView: AnimationView?
    
    // something like a picture that you can save like a claim
    // like a ticket or reservation type of thing
    
    private lazy var successLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.black
        label.layer.zPosition = 4
        label.numberOfLines = 0
        label.isHidden = true
        label.textAlignment = .center
        let attributedText = NSMutableAttributedString(string: "Congratulations!\n\n", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 20)])
        attributedText.append(NSMutableAttributedString(string: "You've signed the first \"Collection of Signatures\" token! 80% of the money will go to signers every time it's sold! Invite your friends with your personal invite code:", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16)]))
        label.attributedText = attributedText
        return label
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Close", for: .normal)
        button.backgroundColor = UIColor(red: 0/255, green: 166/255, blue: 107/255, alpha: 1)
        button.layer.cornerRadius = 15
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
//        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        setInviteCode()
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.backgroundColor = UIColor.init(white: 1, alpha: 1)
        self.navigationController?.navigationBar.barTintColor = UIColor.init(white: 1, alpha: 1)
        self.view.backgroundColor = UIColor.init(white: 1, alpha: 1)
        
        successLabel.frame = CGRect(x: 20, y: 30, width: UIScreen.main.bounds.width - 40, height: 170)
        self.view.insertSubview(successLabel, at: 4)
        
        animationView = .init(name: "success")
        animationView!.frame = CGRect(x: UIScreen.main.bounds.width/4, y: UIScreen.main.bounds.height/4, width: UIScreen.main.bounds.width/2, height: UIScreen.main.bounds.height/2)
        animationView!.contentMode = .scaleAspectFit
        animationView!.animationSpeed = 1
        view.addSubview(animationView!)
        animationView!.play()
        
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { timer in
            self.successLabel.alpha = 0
            self.successLabel.isHidden = false
            UIView.animate(withDuration: 0.5) {
                self.animationView?.alpha = 0
            }
            UIView.animate(withDuration: 0.5, delay: 0.5) {
                self.successLabel.alpha = 1
            }
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { timer in
                self.animationView?.isHidden = true
            }
        }
    }
    
    func setInviteCode() {
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        Database.database().createInviteCode(uid: currentLoggedInUserId) { (err) in }
    }
}
