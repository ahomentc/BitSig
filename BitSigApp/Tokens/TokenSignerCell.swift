//
//  TokenSignerCell.swift
//  BitSigApp
//
//  Created by Andrei Homentcovschi on 5/15/21.
//  Copyright © 2021 Andrei Homentcovschi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import Kingfisher

protocol TokenSignerCellDelegate {
    func twitterPressed(username: String)
}

class TokenSignerCell: UICollectionViewCell {
    
    var user: User? {
        didSet {
            configureCell()
        }
    }
    
    var num_signed: Int? {
        didSet {
            configureCell()
        }
    }
    
    var delegate: TokenSignerCellDelegate?
    
    static var cellId = "tokenSignerCell"
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.image = #imageLiteral(resourceName: "user")
        iv.layer.zPosition = 4
        iv.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
        iv.layer.borderWidth = 0.5
        return iv
    }()
    
    private lazy var twitterIcon: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.image = #imageLiteral(resourceName: "twitter")
        iv.isHidden = true
        iv.layer.zPosition = 4
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pressedTwitter)))
        iv.isUserInteractionEnabled  = true
        return iv
    }()
    
    private lazy var backgroundLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.init(white: 0.95, alpha: 1)
        label.textColor = UIColor.black
        label.layer.zPosition = 0
        label.numberOfLines = 0
        label.layer.cornerRadius = 20
        label.clipsToBounds = true
        return label
    }()
    
    private let signerNumLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.layer.zPosition = 4
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.layer.zPosition = 4
        label.isHidden = true
        label.numberOfLines = 0
        return label
    }()
    
    private let ethAddressLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.layer.zPosition = 4
        label.lineBreakMode = .byCharWrapping
        return label
    }()
    
    private lazy var twitterUsernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.isHidden = true
        label.layer.zPosition = 4
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pressedTwitter)))
        label.isUserInteractionEnabled  = true
        return label
    }()
    
    private lazy var numTwitterFollowersLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.isHidden = true
        label.layer.zPosition = 4
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pressedTwitter)))
        label.isUserInteractionEnabled  = true
        return label
    }()
    
    private lazy var sortByEarliestSignerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Earliest\nSigners", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitleColor(UIColor(red: 0/255, green: 166/255, blue: 107/255, alpha: 1), for: .normal)
        button.backgroundColor = UIColor.white
        button.layer.borderColor = UIColor(red: 0/255, green: 166/255, blue: 107/255, alpha: 1).cgColor
        button.layer.cornerRadius = 5
        button.layer.zPosition = 4
        button.layer.borderWidth = 1.2
        button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 12, bottom: 5, right: 12)
        button.isUserInteractionEnabled = true
        return button
    }()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    private func sharedInit() {
        insertSubview(backgroundLabel, at: 0)
        backgroundLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 10, paddingRight: 10)
        
        insertSubview(profileImageView, at: 4)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, paddingTop: 15, paddingLeft: 20, width: 50, height: 50)
        profileImageView.layer.cornerRadius = 50 / 2
        
        insertSubview(signerNumLabel, at: 4)
        signerNumLabel.anchor(top: topAnchor, left: profileImageView.rightAnchor, right: rightAnchor, paddingTop: 15, paddingLeft: 20, paddingRight: 20)
        
        insertSubview(ethAddressLabel, at: 4)
        ethAddressLabel.anchor(top: signerNumLabel.bottomAnchor, left: profileImageView.rightAnchor, right: rightAnchor, paddingTop: 10, paddingLeft: 20, paddingRight: 20)
        
        insertSubview(nameLabel, at: 4)
        nameLabel.anchor(top: ethAddressLabel.bottomAnchor, left: profileImageView.rightAnchor, right: rightAnchor, paddingTop: 10, paddingLeft: 20, paddingRight: 20)
        
        insertSubview(twitterIcon, at: 4)
        twitterIcon.anchor(top: nameLabel.bottomAnchor, left: profileImageView.rightAnchor, paddingTop: 15, paddingLeft: 20, width: 50, height: 50)

        insertSubview(twitterUsernameLabel, at: 4)
        twitterUsernameLabel.anchor(top: nameLabel.bottomAnchor, left: twitterIcon.rightAnchor, paddingTop: 20, paddingLeft: 10)
        
        insertSubview(numTwitterFollowersLabel, at: 4)
        numTwitterFollowersLabel.anchor(top: twitterUsernameLabel.bottomAnchor, left: twitterIcon.rightAnchor, paddingTop: 5, paddingLeft: 10)
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.nameLabel.attributedText = NSMutableAttributedString(string: "", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.init(white: 0, alpha: 1)])
        self.ethAddressLabel.attributedText = NSMutableAttributedString(string: "", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.init(white: 0, alpha: 1)])
        self.nameLabel.isHidden = true
        self.profileImageView.image = #imageLiteral(resourceName: "user")
        self.twitterIcon.isHidden = true
        self.twitterUsernameLabel.isHidden = true
        self.numTwitterFollowersLabel.isHidden = true
        self.twitterUsernameLabel.attributedText = NSMutableAttributedString(string: "", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.init(white: 0, alpha: 1)])
        self.numTwitterFollowersLabel.attributedText = NSMutableAttributedString(string: "", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.init(white: 0, alpha: 1)])
    }
    
    private func configureCell() {
        guard let user = self.user else { return }
        guard let num_signed = self.num_signed else { return }
        
        self.signerNumLabel.text = "Signer #" + String(num_signed)
        
        let ethAttributedText = NSMutableAttributedString(string: "Wallet Address:\n", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.init(white: 0, alpha: 1)])
        ethAttributedText.append(NSMutableAttributedString(string: user.ethereum_address, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.init(white: 0, alpha: 1)]))
        self.ethAddressLabel.attributedText = ethAttributedText
        
        if user.profileImageURL != "" {
            let url = URL(string: user.profileImageURL)
            self.profileImageView.kf.setImage(with: url)
        } else {
            profileImageView.image = #imageLiteral(resourceName: "user")
        }
        
        if user.name != "" {
            self.nameLabel.isHidden = false
            let nameAttributedText = NSMutableAttributedString(string: "Name:\n", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.init(white: 0, alpha: 1)])
            nameAttributedText.append(NSMutableAttributedString(string: user.name, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.init(white: 0, alpha: 1)]))
            self.nameLabel.attributedText = nameAttributedText
        }
        
        if user.twitter != "" {
            self.twitterIcon.isHidden = false
            self.twitterUsernameLabel.isHidden = false
            self.numTwitterFollowersLabel.isHidden = false
            
            let usernamenameAttributedText = NSMutableAttributedString(string: "@", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.init(white: 0, alpha: 1)])
            usernamenameAttributedText.append(NSMutableAttributedString(string: user.twitter, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.init(white: 0, alpha: 1), NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]))
            self.twitterUsernameLabel.attributedText = usernamenameAttributedText
            
            let largeNumber = user.twitter_followers_count
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            let formattedNumber = numberFormatter.string(from: NSNumber(value:largeNumber)) ?? String(user.twitter_followers_count)
            
            let numFollowersAttributedText = NSMutableAttributedString(string: formattedNumber, attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.init(white: 0, alpha: 1)])
            numFollowersAttributedText.append(NSMutableAttributedString(string: " Followers", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.init(white: 0, alpha: 1)]))
            self.numTwitterFollowersLabel.attributedText = numFollowersAttributedText
        }
    }
    
    @objc func pressedTwitter() {
        guard let twitter = user?.twitter else { return }
        delegate?.twitterPressed(username: twitter)
    }
}
