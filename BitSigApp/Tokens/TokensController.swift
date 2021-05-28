//
//  TokensController.swift
//  BitSigApp
//
//  Created by Andrei Homentcovschi on 5/9/21.
//  Copyright © 2021 Andrei Homentcovschi. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase

class TokensController: UIViewController {
  
    private lazy var comingSoonLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.black
        label.layer.zPosition = 4
        label.numberOfLines = 0
        label.textAlignment = .left
        let attributedText = NSMutableAttributedString(string: "Create, Buy, Sell Tokens!\n\n", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 22), NSAttributedString.Key.foregroundColor: UIColor(red: 0/255, green: 166/255, blue: 107/255, alpha: 1)])
        attributedText.append(NSMutableAttributedString(string: "Create and collect signatures for your own signable NFTs.\n\nBuy and sell signed NFTs.\n\nConfigure what percentage of the sale signers get and reserve percentages for VIP signers.\n\nJoin the waitlist for a notification of when it's ready!", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 15)]))
        label.attributedText = attributedText
        return label
    }()
    
    private lazy var getOnWaitlistButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Get on the waitlist", for: .normal)
        button.backgroundColor = UIColor(red: 0/255, green: 166/255, blue: 107/255, alpha: 1)
        button.layer.cornerRadius = 15
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(getOnWaitlist), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        self.view.backgroundColor = .white
        
        configureNavBar()
        
        self.view.insertSubview(comingSoonLabel, at: 4)
        comingSoonLabel.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 30, paddingRight: 30, height: 300)
        
        self.view.insertSubview(getOnWaitlistButton, at: 4)
        getOnWaitlistButton.anchor(left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor,paddingLeft: 60, paddingBottom: 80, paddingRight: 60, height: 50)
        
        if let onTokenWaitlistRetrieved = UserDefaults.standard.object(forKey: "onTokenWaitlist") as? Data {
            guard let onTokenWaitlist = try? JSONDecoder().decode(Bool.self, from: onTokenWaitlistRetrieved) else {
                return
            }
            if onTokenWaitlist {
                // user defaults set
                self.getOnWaitlistButton.setTitle("You're on the waitlist!", for: .normal)
                self.getOnWaitlistButton.backgroundColor = .white
                self.getOnWaitlistButton.setTitleColor(UIColor(red: 0/255, green: 166/255, blue: 107/255, alpha: 1), for: .normal)
            }
        }
    }
    
    func configureNavBar() {
//        let textAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18), NSAttributedString.Key.foregroundColor : UIColor.black]
//        let navLabel = UILabel()
//        navLabel.attributedText = NSAttributedString(string: "Your NFT Tokens", attributes: textAttributes)
//        navigationItem.titleView = navLabel
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.backgroundColor = UIColor.init(white: 1, alpha: 1)
        self.navigationController?.navigationBar.barTintColor = UIColor.init(white: 1, alpha: 1)
        self.view.backgroundColor = UIColor.init(white: 1, alpha: 1)
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .black
    }
    
    @objc func getOnWaitlist() {
        let pushManager = PushNotificationManager()
        pushManager.registerForPushNotifications()
        
        if let onTokenWaitlist = try? JSONEncoder().encode(true) {
            UserDefaults.standard.set(onTokenWaitlist, forKey: "onTokenWaitlist")
        }
        
        self.getOnWaitlistButton.setTitle("You're on the waitlist!", for: .normal)
        self.getOnWaitlistButton.backgroundColor = .white
        self.getOnWaitlistButton.setTitleColor(UIColor(red: 0/255, green: 166/255, blue: 107/255, alpha: 1), for: .normal)
    }
}
