//
//  MainTabBarController.swift
//  BitSigApp
//
//  Created by Andrei Homentcovschi on 5/9/21.
//  Copyright © 2021 Andrei Homentcovschi. All rights reserved.
//

import Foundation
import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.tintColor = .black
        tabBar.isTranslucent = false
        
        setupViewControllers()
        
//        if Auth.auth().currentUser == nil {
//            presentLoginController()
//        } else {
//            setupViewControllers()
//        }
    }
    
    func setupViewControllers() {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
        let signNavController = self.templateNavController(unselectedImage: #imageLiteral(resourceName: "scan"), selectedImage: #imageLiteral(resourceName: "scan"), rootViewController: SignController())
        let signaturesNavController = self.templateNavController(unselectedImage: #imageLiteral(resourceName: "signature"), selectedImage: #imageLiteral(resourceName: "signature"), rootViewController: SignaturesController())
        let tokensNavController = self.templateNavController(unselectedImage: #imageLiteral(resourceName: "wallet"), selectedImage: #imageLiteral(resourceName: "wallet"), rootViewController: TokensController())
        let settingsNavController = self.templateNavController(unselectedImage: #imageLiteral(resourceName: "settings"), selectedImage: #imageLiteral(resourceName: "settings"), rootViewController: SettingsController())
        
        self.selectedIndex = 0
        
//        Database.database().fetchUser(withUID: uid) { (user) in
//            userProfileController.user = user
//        }
        
        viewControllers = [signNavController, signaturesNavController, tokensNavController, settingsNavController]
    }
    
    private func presentLoginController() {
        DispatchQueue.main.async { // wait until MainTabBarController is inside UI
//            let loginController = LoginController()
//            let navController = UINavigationController(rootViewController: loginController)
//            self.present(navController, animated: true, completion: nil)
        }
    }
    
    private func templateNavController(unselectedImage: UIImage, selectedImage: UIImage, rootViewController: UIViewController = UIViewController()) -> UINavigationController {
        let viewController = rootViewController
        let navController = UINavigationController(rootViewController: viewController)
        navController.navigationBar.isTranslucent = false
        navController.tabBarItem.image = unselectedImage
        navController.tabBarItem.selectedImage = selectedImage
        navController.tabBarItem.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
        return navController
    }
}
