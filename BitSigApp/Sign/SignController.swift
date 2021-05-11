//
//  SignController.swift
//  BitSigApp
//
//  Created by Andrei Homentcovschi on 5/9/21.
//  Copyright © 2021 Andrei Homentcovschi. All rights reserved.
//

import Foundation
import UIKit
import web3swift

// For Crypto stuff:
// https://github.com/skywinder/web3swift/blob/master/Documentation/Usage.md#account-management
// Just need to create a wallet so that I can use their private key to sign their signature message
// Easy to do :)

class SignController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
//        self.view.backgroundColor = UIColor.green
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.backgroundColor = UIColor.init(white: 0.98, alpha: 1)
        self.navigationController?.navigationBar.barTintColor = UIColor.init(white: 0.98, alpha: 1)
        self.view.backgroundColor = UIColor.init(white: 0.98, alpha: 1)
        
        let textAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18), NSAttributedString.Key.foregroundColor : UIColor.black]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        let navLabel = UILabel()
        navLabel.attributedText = NSAttributedString(string: "hi")
        navigationItem.titleView = navLabel
        
        
    }
}
