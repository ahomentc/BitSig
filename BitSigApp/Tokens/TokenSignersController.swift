//
//  TokenSignersController.swift
//  BitSigApp
//
//  Created by Andrei Homentcovschi on 5/15/21.
//  Copyright © 2021 Andrei Homentcovschi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import NVActivityIndicatorView

enum SortType {
    case firstSigned
    case latestSigned
    case twitter
}

class TokenSignersController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, TokenSignerCellDelegate {
    
    // I put their twitter follower count in Users too so i can sort by that
    
    var collectionView: UICollectionView!
    
    var tokenSigners: [User]?
    var numSigners: [String: Double]?
    
    var tokenId = "1"
    
    var sortType = SortType.firstSigned
    
    let activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: UIScreen.main.bounds.width/2 - 35, y: UIScreen.main.bounds.height/2 - 35, width: 70, height: 70), type: NVActivityIndicatorType.circleStrokeSpin)
    
    private let firstSignersButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("First\nSigners", for: .normal)
        button.backgroundColor = UIColor(red: 0/255, green: 156/255, blue: 97/255, alpha: 1)
        button.layer.cornerRadius = 20
        button.layer.zPosition = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.titleLabel?.textAlignment = .center
        button.addTarget(self, action: #selector(fetchFirstTokenSigners), for: .touchUpInside)
        return button
    }()
    
    private let latestSignersButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Latest\nSigners", for: .normal)
        button.backgroundColor = UIColor(red: 0/255, green: 156/255, blue: 97/255, alpha: 0.5)
        button.layer.cornerRadius = 20
        button.layer.zPosition = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.titleLabel?.textAlignment = .center
        button.addTarget(self, action: #selector(fetchLatestTokenSigners), for: .touchUpInside)
        return button
    }()
    
    private let twitterSortButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("# Twitter\nFollowers", for: .normal)
        button.backgroundColor = UIColor(red: 0/255, green: 156/255, blue: 97/255, alpha: 0.5)
        button.layer.cornerRadius = 20
        button.layer.zPosition = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.titleLabel?.textAlignment = .center
        button.addTarget(self, action: #selector(fetchTokenSignersByTwitterFollowers), for: .touchUpInside)
        return button
    }()
    
    private lazy var orderByLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.black
        label.layer.zPosition = 4
        label.numberOfLines = 0
        label.textAlignment = .left
        let attributedText = NSMutableAttributedString(string: "Order By:", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.init(white: 0.3, alpha: 1)])
        label.attributedText = attributedText
        return label
    }()
    
    private let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Search name, twitter, wallet"
        sb.autocorrectionType = .no
        sb.autocapitalizationType = .none
        sb.barTintColor = .white
        sb.layer.borderWidth = 0
        sb.backgroundImage = UIImage()
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor.init(white: 0.95, alpha: 1)
        return sb
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        view.backgroundColor = .white
        
        searchBar.frame = CGRect(x: 10, y: 0, width: UIScreen.main.bounds.width - 20, height: 60)
        searchBar.delegate = self
        view.insertSubview(searchBar, at: 5)
        
        firstSignersButton.frame = CGRect(x: UIScreen.main.bounds.width/2 - 150 - 10, y: 40 + 60, width: 100, height: 55)
        view.insertSubview(firstSignersButton, at: 5)
        
        latestSignersButton.frame = CGRect(x: UIScreen.main.bounds.width/2 - 50, y: 40 + 60, width: 100, height: 55)
        view.insertSubview(latestSignersButton, at: 5)
        
        twitterSortButton.frame = CGRect(x: UIScreen.main.bounds.width/2 + 50 + 10, y: 40 + 60, width: 100, height: 55)
        view.insertSubview(twitterSortButton, at: 5)
        
        view.insertSubview(orderByLabel, at: 5)
        orderByLabel.anchor(top: view.topAnchor, left: firstSignersButton.leftAnchor, right: view.rightAnchor, paddingTop: 5 + 60, paddingLeft: 10, paddingRight: 10)
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: self.view.frame.width, height: 60)
        layout.minimumLineSpacing = CGFloat(0)

        collectionView = UICollectionView(frame: CGRect(x: 0, y: 115 + 60, width: self.view.frame.width, height: self.view.frame.height - 230), collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "CollectionViewCell")
        collectionView?.register(TokenSignerCell.self, forCellWithReuseIdentifier: TokenSignerCell.cellId)
        collectionView.backgroundColor = UIColor.clear
        collectionView.showsVerticalScrollIndicator = true
        view.addSubview(collectionView)
        
        self.fetchFirstTokenSigners()
        
        configureNavBar()
        
        view.insertSubview(activityIndicatorView, at: 20)
        activityIndicatorView.isHidden = true
        activityIndicatorView.color = .black
        activityIndicatorView.startAnimating()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func twitterPressed(username: String) {
        if username == "" {
            return
        }
        
        if let url = URL(string: "https://www.twitter.com/" + username) {
            UIApplication.shared.open(url)
        }
    }
    
    @objc func fetchFirstTokenSigners() {
        sortType = .firstSigned
        firstSignersButton.backgroundColor = UIColor(red: 0/255, green: 156/255, blue: 97/255, alpha: 1)
        latestSignersButton.backgroundColor = UIColor(red: 0/255, green: 156/255, blue: 97/255, alpha: 0.5)
        twitterSortButton.backgroundColor = UIColor(red: 0/255, green: 156/255, blue: 97/255, alpha: 0.5)
        Database.database().fetchFirstSigners(token_id: self.tokenId, completion: { (signers, num_signers) in
            self.activityIndicatorView.isHidden = true
            self.tokenSigners = signers
            self.numSigners = num_signers
            self.collectionView?.reloadData()
        }) { (_) in
        }
    }
    
    @objc func fetchLatestTokenSigners() {
        sortType = .latestSigned
        firstSignersButton.backgroundColor = UIColor(red: 0/255, green: 156/255, blue: 97/255, alpha: 0.5)
        latestSignersButton.backgroundColor = UIColor(red: 0/255, green: 156/255, blue: 97/255, alpha: 1)
        twitterSortButton.backgroundColor = UIColor(red: 0/255, green: 156/255, blue: 97/255, alpha: 0.5)
        Database.database().fetchLatestSigners(token_id: self.tokenId, completion: { (signers, num_signers) in
            self.activityIndicatorView.isHidden = true
            self.tokenSigners = signers
            self.numSigners = num_signers
            self.collectionView?.reloadData()
        }) { (_) in
        }
    }

    @objc func fetchTokenSignersByTwitterFollowers() {
        sortType = .twitter
        firstSignersButton.backgroundColor = UIColor(red: 0/255, green: 156/255, blue: 97/255, alpha: 0.5)
        latestSignersButton.backgroundColor = UIColor(red: 0/255, green: 156/255, blue: 97/255, alpha: 0.5)
        twitterSortButton.backgroundColor = UIColor(red: 0/255, green: 156/255, blue: 97/255, alpha: 1)
        Database.database().fetchMostTwitterFollowerSigners(token_id: self.tokenId, completion: { (signers, num_signers) in
            self.activityIndicatorView.isHidden = true
            self.tokenSigners = signers
            self.numSigners = num_signers
            self.collectionView?.reloadData()
        }) { (_) in
        }
    }
    
    @objc func dismissKeyboard() {
        searchBar.resignFirstResponder()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tokenSigners?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TokenSignerCell.cellId, for: indexPath) as! TokenSignerCell
        cell.user = tokenSigners?[indexPath.row]
        cell.num_signed = Int(numSigners?[cell.user?.uid ?? ""] ?? 0)
        cell.delegate = self
        return cell
    }
    
    func configureNavBar() {
        Database.database().fetchTokenNumSigned(token_id: "1", completion: { (num_signed) in
            let textAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18), NSAttributedString.Key.foregroundColor : UIColor.black]
            let navLabel = UILabel()
            if num_signed > 0 {
                navLabel.attributedText = NSAttributedString(string: String(num_signed) + " Signers", attributes: textAttributes)
            }
            self.navigationItem.titleView = navLabel
            
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController?.navigationBar.isTranslucent = false
            self.navigationController?.navigationBar.backgroundColor = UIColor.init(white: 1, alpha: 1)
            self.navigationController?.navigationBar.barTintColor = UIColor.init(white: 1, alpha: 1)
            self.view.backgroundColor = UIColor.init(white: 1, alpha: 1)
            
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            self.navigationItem.backBarButtonItem?.tintColor = .black
        })
    }
}

extension Dictionary {
    mutating func merge(dict: [Key: Value]){
        for (k, v) in dict {
            updateValue(v, forKey: k)
        }
    }
}

extension TokenSignersController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row < tokenSigners?.count ?? 0 {
            let user = tokenSigners?[indexPath.row]
            var size = 120
            
            if user?.name != "" {
                size += 40
            }
            if user?.twitter != "" {
                size += 70
            }
            return CGSize(width: view.frame.width, height: CGFloat(size))
        }
        return CGSize(width: view.frame.width, height: 120)
    }
}

extension TokenSignersController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            self.firstSignersButton.isHidden = false
            self.latestSignersButton.isHidden = false
            self.twitterSortButton.isHidden = false
            self.orderByLabel.isHidden = false
            self.collectionView.frame = CGRect(x: 0, y: 115 + 60, width: self.view.frame.width, height: self.view.frame.height - 230)
            
            if self.sortType == .firstSigned {
                self.fetchFirstTokenSigners()
            }
            else if self.sortType == .latestSigned {
                self.fetchLatestTokenSigners()
            }
            else if self.sortType == .twitter {
                self.fetchTokenSignersByTwitterFollowers()
            }
        }
        else {
            self.tokenSigners = [User]()
            self.numSigners = [String: Double]()
            
            self.firstSignersButton.isHidden = true
            self.latestSignersButton.isHidden = true
            self.twitterSortButton.isHidden = true
            self.orderByLabel.isHidden = true
            self.collectionView.frame = CGRect(x: 0, y: 70, width: self.view.frame.width, height: self.view.frame.height - 105)
            
            // do the other ones too so make this pparent
            Database.database().searchForAddress(address: searchText, token_id: tokenId, completion: { (signers, num_signers) in
                self.activityIndicatorView.isHidden = true
                if self.tokenSigners == nil {
                    self.tokenSigners = signers
                }
                else {
                    self.tokenSigners! += signers
                }
                if self.numSigners == nil {
                    self.numSigners = num_signers
                }
                else {
                    self.numSigners!.merge(dict: num_signers)
                }
                self.collectionView?.reloadData()
            }) { (_) in
            }
            
            Database.database().searchForName(name: searchText, token_id: tokenId, completion: { (signers, num_signers) in
                self.activityIndicatorView.isHidden = true
                if self.tokenSigners == nil {
                    self.tokenSigners = signers
                }
                else {
                    self.tokenSigners! += signers
                }
                if self.numSigners == nil {
                    self.numSigners = num_signers
                }
                else {
                    self.numSigners!.merge(dict: num_signers)
                }
                self.collectionView?.reloadData()
            }) { (_) in
            }
            
            Database.database().searchForTwitter(twitter: searchText, token_id: tokenId, completion: { (signers, num_signers) in
                self.activityIndicatorView.isHidden = true
                if self.tokenSigners == nil {
                    self.tokenSigners = signers
                }
                else {
                    self.tokenSigners! += signers
                }
                if self.numSigners == nil {
                    self.numSigners = num_signers
                }
                else {
                    self.numSigners!.merge(dict: num_signers)
                }
                self.collectionView?.reloadData()
            }) { (_) in
            }
        }
//        if searchText.isEmpty {
//            self.filteredUsers = []
//            self.filteredGroups = []
//            self.collectionView?.reloadData()
//        } else {
//            if isUsersView {
//                searchForUser(username: searchText)
//            }
//            else {
//                searchForGroup(search_word: searchText.replacingOccurrences(of: " ", with: "_-a-_").replacingOccurrences(of: "‘", with: "_-b-_").replacingOccurrences(of: "'", with: "_-b-_").replacingOccurrences(of: "’", with: "_-b-_"))
//            }
//        }
//        self.collectionView?.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
