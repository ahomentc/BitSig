//
//  MainTabBarController.swift
//  BitSigApp
//
//  Created by Andrei Homentcovschi on 5/9/21.
//  Copyright © 2021 Andrei Homentcovschi. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.tintColor = UIColor(red: 0/255, green: 166/255, blue: 107/255, alpha: 1)
        tabBar.isTranslucent = false
        
        setKeystoreIfWalletSet()
        
        setupViewControllers()
        
//        if let passedInviteRetrieved = UserDefaults.standard.object(forKey: "passedInvite") as? Data {
//            guard let passedInvite = try? JSONDecoder().decode(Bool.self, from: passedInviteRetrieved) else {
//                return
//            }
//            if passedInvite {
//                setupViewControllers()
//            }
//            else {
//                if Auth.auth().currentUser == nil {
//                    presentAccessController()
//                } else {
//                    setupViewControllers()
//                }
//            }
//        }
//        else {
//            if Auth.auth().currentUser == nil {
//                presentAccessController()
//            } else {
//                setupViewControllers()
//            }
//        }
        
        tabBar.tintColor = UIColor(red: 0/255, green: 166/255, blue: 107/255, alpha: 1)
        tabBar.isTranslucent = true
        tabBar.barTintColor = UIColor.clear
        tabBar.backgroundImage = UIImage()
        tabBar.shadowImage = UIImage()
        tabBar.unselectedItemTintColor = UIColor.white
        tabBar.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0)
        
        NotificationCenter.default.addObserver(self, selector: #selector(makeTabBarClear), name: NSNotification.Name(rawValue: "tabBarClear"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(makeTabBarColor), name: NSNotification.Name(rawValue: "tabBarColor"), object: nil)
    }
    
    func setupViewControllers() {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
        let signNavController = self.templateNavController(unselectedImage: #imageLiteral(resourceName: "scan"), selectedImage: #imageLiteral(resourceName: "scan"), text: "Scan", rootViewController: ScanController())
        let signaturesNavController = self.templateNavController(unselectedImage: #imageLiteral(resourceName: "signature"), selectedImage: #imageLiteral(resourceName: "signature"), text: "Signatures", rootViewController: SignaturesController())
        let tokensNavController = self.templateNavController(unselectedImage: #imageLiteral(resourceName: "wallet"), selectedImage: #imageLiteral(resourceName: "wallet"), text: "Tokens", rootViewController: TokensController())
        let settingsNavController = self.templateNavController(unselectedImage: #imageLiteral(resourceName: "settings"), selectedImage: #imageLiteral(resourceName: "settings"), text: "Identity", rootViewController: SettingsController())
        
        self.selectedIndex = 0
        
//        Database.database().fetchUser(withUID: uid) { (user) in
//            userProfileController.user = user
//        }
        
        viewControllers = [signNavController, signaturesNavController, tokensNavController, settingsNavController]
    }
    
    private func presentAccessController() {
        DispatchQueue.main.async { // wait until MainTabBarController is inside UI
            let appAccessController = AppAccessController()
            let navController = UINavigationController(rootViewController: appAccessController)
            navController.modalPresentationStyle = .fullScreen
            self.present(navController, animated: false, completion: nil)
        }
    }
    
    @objc private func makeTabBarClear(){
        tabBar.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.2)
        tabBar.tintColor = UIColor(red: 0/255, green: 166/255, blue: 107/255, alpha: 1)
        tabBar.unselectedItemTintColor = UIColor.white
    }
    
    @objc private func makeTabBarColor(){
        tabBar.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        tabBar.tintColor = UIColor(red: 0/255, green: 166/255, blue: 107/255, alpha: 1)
        tabBar.unselectedItemTintColor = UIColor.darkGray
    }
    
    private func templateNavController(unselectedImage: UIImage, selectedImage: UIImage, text: String, rootViewController: UIViewController = UIViewController()) -> UINavigationController {
        let viewController = rootViewController
        let navController = UINavigationController(rootViewController: viewController)
        navController.navigationBar.isTranslucent = false
        navController.navigationBar.backgroundColor = .blue
        navController.tabBarItem.image = unselectedImage
        navController.tabBarItem.selectedImage = selectedImage
        navController.tabBarItem.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 2, right: 0)
        navController.tabBarItem.title = text
        navController.tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -5)
        return navController
    }
}
