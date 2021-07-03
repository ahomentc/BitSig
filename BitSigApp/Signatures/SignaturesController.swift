//
//  SignaturesController.swift
//  BitSigApp
//
//  Created by Andrei Homentcovschi on 5/9/21.
//  Copyright © 2021 Andrei Homentcovschi. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase
import NVActivityIndicatorView

class SignaturesController: UIViewController {
  
    private lazy var openFirstTokenButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("First Signable NFT", for: .normal)
        button.backgroundColor = UIColor.init(white: 0.9, alpha: 1)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.black, for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 5,left: 20,bottom: 5,right: 5)
        button.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        button.addTarget(self, action: #selector(openFirstToken), for: .touchUpInside)
        return button
    }()
    
    let activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: UIScreen.main.bounds.width/2 - 35, y: UIScreen.main.bounds.height/2 - 135, width: 70, height: 70), type: NVActivityIndicatorType.circleStrokeSpin)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        self.view.backgroundColor = .white
        
        configureNavBar()
        
        view.insertSubview(activityIndicatorView, at: 20)
        activityIndicatorView.isHidden = true
        activityIndicatorView.color = .black
        activityIndicatorView.startAnimating()
        
        // check to see if user has signed token
        Database.database().hasUserSignedToken(token_id: "1", completion: { (is_signed) in
            self.activityIndicatorView.isHidden = true
            if is_signed {
                self.view.insertSubview(self.openFirstTokenButton, at: 4)
                self.openFirstTokenButton.anchor(top: self.view.topAnchor, left: self.view.leftAnchor, right: self.view.rightAnchor, paddingTop: 30, paddingLeft: 15, paddingRight: 15, height: 60)
            }
            else {
                
            }
        })
    }
    
    func configureNavBar() {
        let textAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18), NSAttributedString.Key.foregroundColor : UIColor.black]
        let navLabel = UILabel()
        navLabel.attributedText = NSAttributedString(string: "Your NFT Signatures", attributes: textAttributes)
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
    
    @objc func openFirstToken() {
        let signController = SignController()
        signController.QRCodeValue = "https://bitsig.org/token?id=1"
        navigationController?.pushViewController(signController, animated: true)
    }
}
