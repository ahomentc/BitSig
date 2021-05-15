//
//  FirebaseUtilities.swift
//  BitSigApp
//
//  Created by Andrei Homentcovschi on 5/10/21.
//  Copyright © 2021 Andrei Homentcovschi. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseMessaging

extension Auth {
    func createUserInDatabase(withEmail email: String, password: String, completion: @escaping (Error?) -> ()) {
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, err) in
            if let err = err {
                print("Failed to create user:", err)
                completion(err)
                return
            }
            completion(nil)
        })
    }
}

extension Database {
    func uploadUser(withUID uid: String, eth_address: String, name: String? = nil, twitter_username: String? = nil, token_id: String? = nil, profileImageUrl: String? = nil, completion: @escaping (() -> ())) {
        var dictionaryValues = ["eth_address": eth_address]
        if name != nil {
            dictionaryValues["name"] = name
        }
        if twitter_username != nil {
            dictionaryValues["twitter_username"] = twitter_username
        }
        if profileImageUrl != nil {
            dictionaryValues["profileImageUrl"] = profileImageUrl
        }
        if let fcm = Messaging.messaging().fcmToken {
            dictionaryValues["fcm_token"] = fcm
        }
        
        let values = [uid: dictionaryValues]
        Database.database().reference().child("users").updateChildValues(values, withCompletionBlock: { (err, ref) in
            if let err = err {
                print("Failed to upload user to database:", err)
                return
            }
            Database.database().reference().child("eth_addresses").child(eth_address).setValue(uid, withCompletionBlock: { (err, ref) in
                if let err = err {
                    print("Failed to upload eth address to database:", err)
                    return
                }
                
                if token_id != nil {
                    self.signToken(eth_address: eth_address, token_id: token_id!) {
                        completion()
                    }
                }
                else {
                    completion()
                }
            })
        })
    }
    
    func createTwitterUser(withUID uid: String, username: String? = nil, profile_image_url: String? = nil, followers_count: Int? = nil, verified: Int? = nil, id: String? = nil, completion: @escaping (() -> ())) {
        var dictionaryValues = ["bitsig_uid": uid]
        if profile_image_url != nil {
            dictionaryValues["profile_image_url"] = profile_image_url
        }
        if followers_count != nil {
            dictionaryValues["followers_count"] = String(followers_count!)
        }
        if verified != nil {
            dictionaryValues["verified"] = String(verified!)
        }
        if id != nil {
            dictionaryValues["twitter_id"] = id
        }
        
        let values = [username: dictionaryValues]
        Database.database().reference().child("twitter_users").updateChildValues(values, withCompletionBlock: { (err, ref) in
            if let err = err {
                print("Failed to upload user to database:", err)
                return
            }
            completion()
        })
    }

    // take into account contract address?
    func signToken(eth_address: String, token_id: String, completion: @escaping (() -> ())) {
        // get their place in line and set that as the value, cloud function for that
        
        Database.database().reference().child("eth_addresses").child(eth_address).child("tokens_signed").child(token_id).setValue(1, withCompletionBlock: { (err, ref) in
            if let err = err {
                print("Failed to sign token in database:", err)
                return
            }
            Database.database().reference().child("tokens").child(token_id).child("signer_addresses").child(eth_address).setValue(1, withCompletionBlock: { (err, ref) in
                if let err = err {
                    print("Failed to sign token in database:", err)
                    return
                }
                completion()
            })
        })
    }
    
    func hasSignedToken(eth_address: String, token_id: String, completion: @escaping (Bool) -> ()) {
        Database.database().reference().child("tokens").child(token_id).child("signer_addresses").child(eth_address).observeSingleEvent(of: .value, with: { (snapshot) in
            guard (snapshot.value as? Int) != nil else {
                completion(false)
                return
            }
            completion(true)
        }) { (err) in
            print("Failed to fetch user from database:", err)
        }
    }
    
    func userExists(withUID uid: String, completion: @escaping (Bool) -> ()) {
        Database.database().reference().child("users").child(uid).child("eth_address").observeSingleEvent(of: .value, with: { (snapshot) in
            guard (snapshot.value as? String) != nil else {
                completion(false)
                return
            }
            completion(true)
        }) { (err) in
            print("Failed to fetch user from database:", err)
        }
    }
    
    func fetchUser(withUID uid: String, completion: @escaping (User) -> ()) {
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let userDictionary = snapshot.value as? [String: Any] else {
                print("user not found")
                return
            }
            let user = User(uid: uid, dictionary: userDictionary)
            completion(user)
        }) { (err) in
            print("Failed to fetch user from database:", err)
        }
    }
    
    func setUserfcmToken(token: String, completion: @escaping (Error?) -> ()) {
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference().child("users").child(currentLoggedInUserId)
        let values = ["fcm_token": token] as [String : Any]
        ref.updateChildValues(values) { (err, ref) in
            if let err = err {
                print("Failed to save post to database", err)
                completion(err)
                return
            }
            completion(nil)
        }
    }
    
    func fetchToken(tokenID: String, completion: @escaping (Token) -> ()) {
        Database.database().reference().child("tokens").child(tokenID).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let tokenDictionary = snapshot.value as? [String: Any] else {
                print("user not found")
                return
            }
            let token = Token(tokenID: tokenID, dictionary: tokenDictionary)
            completion(token)
        }) { (err) in
            print("Failed to fetch user from database:", err)
        }
    }
    
    func inviteCodeValid(code: String, completion: @escaping (Bool) -> ()) {
        // other one is called groupFollowers
        Database.database().reference().child("waitlist_codes").child(code).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.value != nil {
                if snapshot.value! is NSNull {
                    completion(false)
                }
                else {
                    completion(true)
                }
            } else {
                completion(false)
            }
        }) { (err) in
            print("Failed to check if following:", err)
        }
    }
    
    func createInviteCode(uid: String, completion: @escaping (Error?) -> ()) {
        let code = uid.prefix(5).lowercased()
        Database.database().inviteCodeValid(code: code.lowercased(), completion: { (isValid) in
            if (isValid == false) {
                Database.database().reference().child("waitlist_codes").child(String(code)).setValue(100) { (err, ref) in
                    if let err = err {
                        completion(err)
                        return
                    }
                    completion(nil)
                }
            }
        })
    }
    
    func subtractFromInviteCode(code: String, completion: @escaping (Error?) -> ()) {
        Database.database().reference().child("waitlist_codes").child(code).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.value != nil {
                guard let value = snapshot.value as? Int else {
                    completion(nil)
                    return
                }
                Database.database().reference().child("waitlist_codes").child(code).setValue(value - 1) { (err, ref) in
                    if let err = err {
                        completion(err)
                        return
                    }
                    completion(nil)
                }
            }
            else {
                completion(nil)
            }
        }) { (err) in
            print("Failed to fetch user from database:", err)
        }
    }
    
    func addUserToWaitlist(completion: @escaping (Error?) -> ()) {
        // get the user's messaging token after they accept notifications
        guard let fcm = Messaging.messaging().fcmToken else { return }
        Database.database().reference().child("waitlist").child(fcm).setValue(1) { (err, ref) in
            if let err = err {
                completion(err)
                return
            }
            completion(nil)
        }
    }
    
    func removeUserFromWaitlist(completion: @escaping (Error?) -> ()) {
        guard let fcm = Messaging.messaging().fcmToken else { return }
        Database.database().reference().child("waitlist").child(fcm).removeValue { (err, ref) in
            if let err = err {
                completion(err)
                return
            }
            completion(nil)
        }
    }
}
