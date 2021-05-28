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
import Photos

// need option to import account too

class SuccessfulSignController: UIViewController {
    
    private var animationView: AnimationView?
    
    var isReceipt = false
    
    // something like a picture that you can save like a claim
    // like a ticket or reservation type of thing
    
    private let successImage: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.image = #imageLiteral(resourceName: "ticket_emtpy")
        iv.layer.zPosition = 10
        iv.isHidden = true
        return iv
    }()
    
    private lazy var homeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Close", for: .normal)
        button.backgroundColor = UIColor(red: 0/255, green: 166/255, blue: 107/255, alpha: 1)
        button.layer.cornerRadius = 15
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.isHidden = true
        button.addTarget(self, action: #selector(goHome), for: .touchUpInside)
        return button
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save Image", for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 15
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(UIColor(red: 0/255, green: 166/255, blue: 107/255, alpha: 1), for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(red: 0/255, green: 166/255, blue: 107/255, alpha: 1).cgColor
        button.isHidden = true
        button.addTarget(self, action: #selector(saveImage), for: .touchUpInside)
        return button
    }()
    
    private lazy var notifiedButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Turn on sale notification", for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 15
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(UIColor(red: 0/255, green: 166/255, blue: 107/255, alpha: 1), for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(red: 0/255, green: 166/255, blue: 107/255, alpha: 1).cgColor
        button.isHidden = true
        button.addTarget(self, action: #selector(enableNotification), for: .touchUpInside)
        return button
    }()
    
    private lazy var successLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.black
        label.layer.zPosition = 4
        label.numberOfLines = 0
        label.isHidden = true
        label.textAlignment = .center
        let attributedText = NSMutableAttributedString(string: "Congratulations!\n\n", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 20)])
        attributedText.append(NSMutableAttributedString(string: "You've signed the first signable NFT! 80% of the money will go to signers every time it's sold! Invite your friends with your personal invite code:", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16)]))
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
        
//        homeButton.frame = CGRect(x: 40, y: UIScreen.main.bounds.height - 90, width: UIScreen.main.bounds.width - 80, height: 50)
//        self.view.insertSubview(homeButton, at: 4)
        
//        successLabel.frame = CGRect(x: 20, y: 30, width: UIScreen.main.bounds.width - 40, height: 170)
//        self.view.insertSubview(successLabel, at: 4)
        
        self.view.insertSubview(successImage, at: 4)
        successImage.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingRight: 20, height: UIScreen.main.bounds.height * 0.7)
        
        let isRegisteredForRemoteNotifications = UIApplication.shared.isRegisteredForRemoteNotifications
        if isRegisteredForRemoteNotifications {
            self.view.insertSubview(homeButton, at: 4)
            homeButton.anchor(left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingLeft: 30, paddingBottom: 20, paddingRight: 30, height: 50)
            
            self.view.insertSubview(saveButton, at: 4)
            saveButton.anchor(left: view.leftAnchor, bottom: homeButton.topAnchor, right: view.rightAnchor, paddingLeft: 30, paddingBottom: 10, paddingRight: 30, height: 50)
        } else {
            self.view.insertSubview(saveButton, at: 4)
            saveButton.anchor(top: successImage.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: -10, paddingLeft: 30, paddingRight: 30, height: 50)
            
            self.view.insertSubview(notifiedButton, at: 4)
            notifiedButton.anchor(top: saveButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 10, paddingLeft: 30, paddingRight: 30, height: 50)
            
            self.view.insertSubview(homeButton, at: 4)
            homeButton.anchor(top: notifiedButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 10, paddingLeft: 30, paddingRight: 30, height: 50)
        }

        if isReceipt {
            animationView?.isHidden = true
            self.successLabel.alpha = 0
            self.successImage.alpha = 0
            self.homeButton.alpha = 0
            self.saveButton.alpha = 0
            self.notifiedButton.alpha = 0
            self.successLabel.isHidden = false
            self.successImage.isHidden = false
            self.homeButton.isHidden = false
            self.saveButton.isHidden = false
            self.notifiedButton.isHidden = false
            Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { timer in
                UIView.animate(withDuration: 1) {
                    self.successLabel.alpha = 1
                    self.successImage.alpha = 1
                    self.homeButton.alpha = 1
                    self.saveButton.alpha = 1
                    self.notifiedButton.alpha = 1
                }
            }
        }
        else {
            animationView = .init(name: "success")
            animationView!.frame = CGRect(x: UIScreen.main.bounds.width/4, y: UIScreen.main.bounds.height/4, width: UIScreen.main.bounds.width/2, height: UIScreen.main.bounds.height/2)
            animationView!.contentMode = .scaleAspectFit
            animationView!.animationSpeed = 1
            view.addSubview(animationView!)
            animationView!.play()
            
            Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { timer in
                self.successLabel.alpha = 0
                self.successImage.alpha = 0
                self.homeButton.alpha = 0
                self.saveButton.alpha = 0
                self.notifiedButton.alpha = 0
                self.successLabel.isHidden = false
                self.successImage.isHidden = false
                self.homeButton.isHidden = false
                self.saveButton.isHidden = false
                self.notifiedButton.isHidden = false
                UIView.animate(withDuration: 0.5) {
                    self.animationView?.alpha = 0
                }
                UIView.animate(withDuration: 0.5, delay: 0.5) {
                    self.successLabel.alpha = 1
                    self.successImage.alpha = 1
                    self.homeButton.alpha = 1
                    self.saveButton.alpha = 1
                    self.notifiedButton.alpha = 1
                }
                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { timer in
                    self.animationView?.isHidden = true
                }
            }
        }
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { timer in
            self.createImage()
        }
    }
    
    func createImage() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        Database.database().fetchUser(withUID: userId, completion: { (user) in
            Database.database().fetchUserTokenNumSigned(withUID: userId, token_id: "1", completion: { (num_signed) in
                var num_string = ""
                if num_signed % 10 == 1 {
                    num_string = String(num_signed) + "st"
                }
                else if num_signed % 10 == 2 {
                    num_string = String(num_signed) + "nd"
                }
                else if num_signed % 10 == 3 {
                    num_string = String(num_signed) + "rd"
                }
                else {
                    num_string = String(num_signed) + "th"
                }
                
                let img_1 = self.textToImage(drawText: "🎉 Congrats!" as NSString, inImage: #imageLiteral(resourceName: "ticket_emtpy"), atPoint: CGPoint(x: 0, y: 100), fontSize: 60, fontColor: .black, shouldCenter: true)
                let img_2 = self.textToImage(drawText: "You're the " + num_string + " signer of:" as NSString, inImage: img_1, atPoint: CGPoint(x: 0, y: 210), fontSize: 40, fontColor: .black, shouldCenter: true)
                let img_3 = self.textToImage(drawText: "The first signable NFT" as NSString, inImage: img_2, atPoint: CGPoint(x: 0, y: 265), fontSize: 40, fontColor: UIColor(red: 0/255, green: 166/255, blue: 107/255, alpha: 1), shouldCenter: true)
                let img_4 = self.textToImage(drawText: "Give your friends access to\nsign it with your code: " + userId.prefix(5).lowercased() as NSString, inImage: img_3, atPoint: CGPoint(x: 0, y: 720), fontSize: 40, fontColor: .black, shouldCenter: true)
                let img_5 = self.textToImage(drawText: "Signers get 80% of the $ when it's sold!" as NSString, inImage: img_4, atPoint: CGPoint(x: 0, y: 860), fontSize: 40, fontColor: .black, shouldCenter: true)
                let img_6 = self.textToImage(drawText: "BitSig.org" as NSString, inImage: img_5, atPoint: CGPoint(x: 0, y: 950), fontSize: 40, fontColor: UIColor(red: 0/255, green: 166/255, blue: 107/255, alpha: 1), shouldCenter: true)
                self.successImage.image = img_6
            })
        })
    }

    @objc private func saveImage(){
        UIImageWriteToSavedPhotosAlbum(self.successImage.image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc private func enableNotification() {
        let pushManager = PushNotificationManager()
        pushManager.registerForPushNotifications()
        
        homeButton.anchor(left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingLeft: 30, paddingBottom: 20, paddingRight: 30, height: 50)
        saveButton.anchor(left: view.leftAnchor, bottom: homeButton.topAnchor, right: view.rightAnchor, paddingLeft: 30, paddingBottom: 10, paddingRight: 30, height: 50)
        self.notifiedButton.isHidden = true
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            self.saveButton.layer.borderWidth = 0
            self.saveButton.isEnabled = false
            self.saveButton.setTitle("Saved!", for: .normal)
        }
    }
    
    func setInviteCode() {
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        Database.database().createInviteCode(uid: currentLoggedInUserId) { (err) in }
    }
    
    @objc func goHome() {
        UIView.animate(withDuration: 0.25) {
            self.successLabel.alpha = 0
            self.successImage.alpha = 0
            self.homeButton.alpha = 0
            self.saveButton.alpha = 0
            self.notifiedButton.alpha = 0
        }
        Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false) { timer in
            self.dismiss(animated: false, completion: {})
        }
    }
    
    func getLines(text: String, maxCharsInLine: Int) -> [String] {
        let words = text.components(separatedBy: " ")
        var lines = [String]()
        
        var currentLine = ""
        
        for word in words {
            let numChars = (currentLine + word).count
            if numChars < maxCharsInLine {
                currentLine += " " + word
            }
            else {
                lines.append(currentLine)
                currentLine = word
            }
        }
        lines.append(currentLine)
        return lines
    }
    
    func convertLinesToString(lines: [String]) -> String {
        var text = ""
        for line in lines {
            text += line + "\n"
        }
        return text
    }
    
    func textToImage(drawText: NSString, inImage: UIImage, atPoint: CGPoint, fontSize: Int, fontColor: UIColor, shouldCenter: Bool) -> UIImage{

        // Setup the font specific variables
        let textFont = UIFont(name: "Avenir-Heavy", size: CGFloat(fontSize))!

        // Setup the image context using the passed image
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(inImage.size, false, scale)

        // Setup the font attributes that will be later used to dictate how the text should be drawn
        let style = NSMutableParagraphStyle()
        
        if shouldCenter {
            style.alignment = .center
        }
        else {
            style.alignment = .left
        }

        let textFontAttributes = [
            NSAttributedString.Key.font: textFont,
            NSAttributedString.Key.foregroundColor: fontColor,
            NSAttributedString.Key.paragraphStyle: style
        ]

        // Put the image into a rectangle as large as the original image
        inImage.draw(in: CGRect(x: 0, y: 0, width: inImage.size.width, height: inImage.size.height))

        // Create a point within the space that is as bit as the image
        let rect = CGRect(x: atPoint.x, y: atPoint.y, width: inImage.size.width, height: inImage.size.height)

        // Draw the text into an image
        drawText.draw(in: rect, withAttributes: textFontAttributes)

        // Create a new image out of the images we have created
        let newImage = UIGraphicsGetImageFromCurrentImageContext()

        // End the context now that we have the image we need
        UIGraphicsEndImageContext()

        //Pass the image back up to the caller
        return newImage ?? inImage

    }
}
