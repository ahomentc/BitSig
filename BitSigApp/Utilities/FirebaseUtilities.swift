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
import FirebaseStorage

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

extension Storage {
    
    fileprivate func uploadUserProfileImage(image: UIImage, completion: @escaping (String) -> ()) {
        guard let uploadData = image.jpegData(compressionQuality: 0.5) else { return } //changed from 0.3
        
        let storageRef = Storage.storage().reference().child("profile_images").child(NSUUID().uuidString)
        
        storageRef.putData(uploadData, metadata: nil, completion: { (_, err) in
            if let err = err {
                print("Failed to upload profile image:", err)
                return
            }
            
            storageRef.downloadURL(completion: { (downloadURL, err) in
                if let err = err {
                    print("Failed to obtain download url for profile image:", err)
                    return
                }
                guard let profileImageUrl = downloadURL?.absoluteString else { return }
                completion(profileImageUrl)
            })
        })
    }
}

extension Database {
    func uploadUser(withUID uid: String, eth_address: String, name: String? = nil, twitter_username: String? = nil, followers_count: Int? = nil, token_id: String? = nil, profileImage: UIImage? = nil, completion: @escaping (() -> ())) {
        
        let sync = DispatchGroup()
        sync.enter()
        var profileImageUrl = ""
        if profileImage == nil {
            sync.leave()
        }
        else {
            Storage.storage().uploadUserProfileImage(image: profileImage!, completion: { (userProfileImageUrl) in
                profileImageUrl = userProfileImageUrl
                sync.leave()
            })
        }
        
        sync.notify(queue: .main) {
            var dictionaryValues = ["eth_address": eth_address] as [String: Any]
            if name != nil {
                dictionaryValues["name"] = name
            }
            if twitter_username != nil {
                dictionaryValues["twitter_username"] = twitter_username
            }
            if followers_count != nil {
                if followers_count! > 0 {
                    dictionaryValues["twitter_followers_count"] = followers_count ?? 0
                }
            }
            if profileImageUrl != "" {
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
                        self.signToken(withUID: uid, eth_address: eth_address, token_id: token_id!) {
                            completion()
                        }
                    }
                    else {
                        completion()
                    }
                })
            })
        }
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
    func signToken(withUID uid: String, eth_address: String, token_id: String, completion: @escaping (() -> ())) {
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
                
                // fetch user here
                self.userExists(withUID: uid, completion: { (exists) in
                    if exists {
                        Database.database().fetchUser(withUID: uid, completion: { (user) in
                            // make sure to include a spot the the num signed here to be set by cloud function
                            
                            let sync = DispatchGroup()
                            
                            print(user)
                            
                            if user.name != "" {
                                sync.enter()
                                Database.database().reference().child("tokens").child(token_id).child("signer_users").child(uid).child("name").setValue(user.name, withCompletionBlock: { (err, ref) in
                                    if let err = err {
                                        print("Failed to sign token in database:", err)
                                        return
                                    }
                                    sync.leave()
                                })
                            }
                            
                            sync.enter()
                            Database.database().reference().child("tokens").child(token_id).child("signer_users").child(uid).child("num_signer").setValue(1, withCompletionBlock: { (err, ref) in
                                if let err = err {
                                    print("Failed to sign token in database:", err)
                                    return
                                }
                                sync.leave()
                            })
                            
                            if user.twitter != "" {
                                sync.enter()
                                Database.database().reference().child("tokens").child(token_id).child("signer_users").child(uid).child("twitter").setValue(user.twitter, withCompletionBlock: { (err, ref) in
                                    if let err = err {
                                        print("Failed to sign token in database:", err)
                                        return
                                    }
                                    sync.leave()
                                })
                            }
                            
                            if user.twitter_followers_count != 0 {
                                sync.enter()
                                Database.database().reference().child("tokens").child(token_id).child("signer_users").child(uid).child("twitter_followers_count").setValue(user.twitter_followers_count, withCompletionBlock: { (err, ref) in
                                    if let err = err {
                                        print("Failed to sign token in database:", err)
                                        return
                                    }
                                    sync.leave()
                                })
                            }
                            
                            if user.ethereum_address != "" {
                                sync.enter()
                                Database.database().reference().child("tokens").child(token_id).child("signer_users").child(uid).child("ethereum_address").setValue(user.ethereum_address, withCompletionBlock: { (err, ref) in
                                    if let err = err {
                                        print("Failed to sign token in database:", err)
                                        return
                                    }
                                    sync.leave()
                                })
                            }
                            
                            sync.notify(queue: .main){
                                completion()
                            }
                        })
                    }
                    else {
                        print("User doesn't exist")
                        return
                    }
                })
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
    
    func hasUserSignedToken(token_id: String, completion: @escaping (Bool) -> ()) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("tokens").child(token_id).child("signer_users").child(uid).child("ethereum_address").observeSingleEvent(of: .value, with: { (snapshot) in
            guard (snapshot.value as? String) != nil else {
                completion(false)
                return
            }
            completion(true)
        }) { (err) in
            print("Failed to fetch user from database:", err)
        }
    }
    
    // tokens/<token_id>/signer_addresses/<address>/<number_singed> isn't enough
    // because its missing information such as the name, twitter username, twitter followers count
    // which we need for ordering by child when retrieving and sorting
    // so create another child under the token called signer_users which contains all that information,
    // so that we can sort properly
    // ^^^^^^^ done now
    // use tokens/<token_id>/signer_users/<uid>
//    func fetchMoreSignersOrderedByNumSigner(token_id: String, endAt: Double, completion: @escaping ([User],Double,[String: Double]) -> (), withCancel cancel: ((Error) -> ())?) {
//        print("endAt is: ", endAt)
//        let ref = Database.database().reference().child("tokens").child(token_id).child("signer_users")
//        // endAt gets included in the next one but it shouldn't
////        ref.queryOrderedByValue().queryEnding(atValue: endAt).queryLimited(toLast: 30).observeSingleEvent(of: .value, with: { (snapshot) in
//        ref.queryOrdered(byChild: "num_signer").observeSingleEvent(of: .value, with: { (snapshot) in
//            var users = [User]()
//            var numSigners = [String: Double]()
//
//            let sync = DispatchGroup()
//            for child in snapshot.children.allObjects as! [DataSnapshot] {
//                let userId = child.key
//                sync.enter()
//                self.userExists(withUID: userId, completion: { (exists) in
//                    if exists {
//                        Database.database().fetchUser(withUID: userId, completion: { (user) in
//                            users.append(user)
//                            Database.database().fetchUserTokenNumSigned(withUID: userId, token_id: token_id, completion: { (num_signed) in
//                                numSigners[userId] = Double(num_signed)
//                                sync.leave()
//                            })
//                        })
//                    }
//                    else {
//                        sync.leave()
//                    }
//                })
//            }
//            sync.notify(queue: .main) {
////                users.sort(by: { (p1, p2) -> Bool in
////                    return numSigners[p1.uid] ?? 0 < numSigners[p2.uid] ?? 0
////                })
//
////                // queryEnding keeps the oldest entree of the last batch so remove it here if not the first batch
////                if endAt != 10000000000000 && users.count > 0 {
////                    users.remove(at: 0)
////                }
//                completion(users,numSigners[users.last?.uid ?? ""] ?? 10000000000000, numSigners)
//                return
//            }
//        }) { (err) in
//            print("Failed to fetch posts:", err)
//            cancel?(err)
//        }
//    }
    
    func fetchFirstSigners(token_id: String, completion: @escaping ([User], [String: Double]) -> (), withCancel cancel: ((Error) -> ())?) {
        let ref = Database.database().reference().child("tokens").child(token_id).child("signer_users")
        ref.queryOrdered(byChild: "num_signer").queryLimited(toFirst: 100).observeSingleEvent(of: .value, with: { (snapshot) in
            var users = [User]()
            var numSigners = [String: Double]()

            let sync = DispatchGroup()
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let userId = child.key
                sync.enter()
                self.userExists(withUID: userId, completion: { (exists) in
                    if exists {
                        Database.database().fetchUser(withUID: userId, completion: { (user) in
                            users.append(user)
                            Database.database().fetchUserTokenNumSigned(withUID: userId, token_id: token_id, completion: { (num_signed) in
                                numSigners[userId] = Double(num_signed)
                                sync.leave()
                            })
                        })
                    }
                    else {
                        sync.leave()
                    }
                })
            }
            sync.notify(queue: .main) {
//                users.sort(by: { (p1, p2) -> Bool in
//                    return numSigners[p1.uid] ?? 0 < numSigners[p2.uid] ?? 0
//                })
                completion(users, numSigners)
                return
            }
        }) { (err) in
            print("Failed to fetch:", err)
            cancel?(err)
        }
    }
    
    func fetchLatestSigners(token_id: String, completion: @escaping ([User], [String: Double]) -> (), withCancel cancel: ((Error) -> ())?) {
        let ref = Database.database().reference().child("tokens").child(token_id).child("signer_users")
        ref.queryOrdered(byChild: "num_signer").queryLimited(toLast: 100).observeSingleEvent(of: .value, with: { (snapshot) in
            var users = [User]()
            var numSigners = [String: Double]()

            let sync = DispatchGroup()
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let userId = child.key
                sync.enter()
                self.userExists(withUID: userId, completion: { (exists) in
                    if exists {
                        Database.database().fetchUser(withUID: userId, completion: { (user) in
                            users.append(user)
                            Database.database().fetchUserTokenNumSigned(withUID: userId, token_id: token_id, completion: { (num_signed) in
                                numSigners[userId] = Double(num_signed)
                                sync.leave()
                            })
                        })
                    }
                    else {
                        sync.leave()
                    }
                })
            }
            sync.notify(queue: .main) {
                users.sort(by: { (p1, p2) -> Bool in
                    return numSigners[p1.uid] ?? 0 > numSigners[p2.uid] ?? 0
                })
                completion(users, numSigners)
                return
            }
        }) { (err) in
            print("Failed to fetch:", err)
            cancel?(err)
        }
    }
    
    func fetchMostTwitterFollowerSigners(token_id: String, completion: @escaping ([User], [String: Double]) -> (), withCancel cancel: ((Error) -> ())?) {
        let ref = Database.database().reference().child("tokens").child(token_id).child("signer_users")
        ref.queryOrdered(byChild: "twitter_followers_count").queryLimited(toLast: 100).observeSingleEvent(of: .value, with: { (snapshot) in
            var users = [User]()
            var numSigners = [String: Double]()

            let sync = DispatchGroup()
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let userId = child.key
                sync.enter()
                self.userExists(withUID: userId, completion: { (exists) in
                    if exists {
                        Database.database().fetchUser(withUID: userId, completion: { (user) in
                            users.append(user)
                            Database.database().fetchUserTokenNumSigned(withUID: userId, token_id: token_id, completion: { (num_signed) in
                                numSigners[userId] = Double(num_signed)
                                sync.leave()
                            })
                        })
                    }
                    else {
                        sync.leave()
                    }
                })
            }
            sync.notify(queue: .main) {
                users.sort(by: { (p1, p2) -> Bool in
                    return p1.twitter_followers_count > p2.twitter_followers_count
                })
                completion(users, numSigners)
                return
            }
        }) { (err) in
            print("Failed to fetch:", err)
            cancel?(err)
        }
    }
    
    func searchForAddress(address: String, token_id: String, completion: @escaping ([User], [String: Double]) -> (), withCancel cancel: ((Error) -> ())?) {
        let ref = Database.database().reference().child("tokens").child(token_id).child("signer_users")
        ref.queryOrdered(byChild: "ethereum_address").queryStarting(atValue: address).queryEnding(atValue: address+"\u{f8ff}").queryLimited(toLast: 30).observeSingleEvent(of: .value, with: { (snapshot) in
            var users = [User]()
            var numSigners = [String: Double]()

            let sync = DispatchGroup()
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let userId = child.key
                sync.enter()
                self.userExists(withUID: userId, completion: { (exists) in
                    if exists {
                        Database.database().fetchUser(withUID: userId, completion: { (user) in
                            users.append(user)
                            Database.database().fetchUserTokenNumSigned(withUID: userId, token_id: token_id, completion: { (num_signed) in
                                numSigners[userId] = Double(num_signed)
                                sync.leave()
                            })
                        })
                    }
                    else {
                        sync.leave()
                    }
                })
            }
            sync.notify(queue: .main) {
                users.sort(by: { (p1, p2) -> Bool in
                    return numSigners[p1.uid] ?? 0 < numSigners[p2.uid] ?? 0
                })
                completion(users, numSigners)
                return
            }
        }) { (err) in
            print("Failed to fetch:", err)
            cancel?(err)
        }
    }
    
    func searchForName(name: String, token_id: String, completion: @escaping ([User], [String: Double]) -> (), withCancel cancel: ((Error) -> ())?) {
        let ref = Database.database().reference().child("tokens").child(token_id).child("signer_users")
        ref.queryOrdered(byChild: "name").queryStarting(atValue: name).queryEnding(atValue: name+"\u{f8ff}").queryLimited(toLast: 30).observeSingleEvent(of: .value, with: { (snapshot) in
            var users = [User]()
            var numSigners = [String: Double]()

            let sync = DispatchGroup()
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let userId = child.key
                sync.enter()
                self.userExists(withUID: userId, completion: { (exists) in
                    if exists {
                        Database.database().fetchUser(withUID: userId, completion: { (user) in
                            users.append(user)
                            Database.database().fetchUserTokenNumSigned(withUID: userId, token_id: token_id, completion: { (num_signed) in
                                numSigners[userId] = Double(num_signed)
                                sync.leave()
                            })
                        })
                    }
                    else {
                        sync.leave()
                    }
                })
            }
            sync.notify(queue: .main) {
                users.sort(by: { (p1, p2) -> Bool in
                    return numSigners[p1.uid] ?? 0 < numSigners[p2.uid] ?? 0
                })
                completion(users, numSigners)
                return
            }
        }) { (err) in
            print("Failed to fetch:", err)
            cancel?(err)
        }
    }
    
    func searchForTwitter(twitter: String, token_id: String, completion: @escaping ([User], [String: Double]) -> (), withCancel cancel: ((Error) -> ())?) {
        let ref = Database.database().reference().child("tokens").child(token_id).child("signer_users")
        ref.queryOrdered(byChild: "twitter").queryStarting(atValue: twitter).queryEnding(atValue: twitter+"\u{f8ff}").queryLimited(toLast: 30).observeSingleEvent(of: .value, with: { (snapshot) in
            var users = [User]()
            var numSigners = [String: Double]()

            let sync = DispatchGroup()
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let userId = child.key
                sync.enter()
                self.userExists(withUID: userId, completion: { (exists) in
                    if exists {
                        Database.database().fetchUser(withUID: userId, completion: { (user) in
                            users.append(user)
                            Database.database().fetchUserTokenNumSigned(withUID: userId, token_id: token_id, completion: { (num_signed) in
                                numSigners[userId] = Double(num_signed)
                                sync.leave()
                            })
                        })
                    }
                    else {
                        sync.leave()
                    }
                })
            }
            sync.notify(queue: .main) {
                users.sort(by: { (p1, p2) -> Bool in
                    return numSigners[p1.uid] ?? 0 < numSigners[p2.uid] ?? 0
                })
                completion(users, numSigners)
                return
            }
        }) { (err) in
            print("Failed to fetch:", err)
            cancel?(err)
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
    
    func fetchUserTokenNumSigned(withUID uid: String, token_id: String, completion: @escaping (Int) -> ()) {
        Database.database().reference().child("tokens").child(token_id).child("signer_users").child(uid).child("num_signer").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.value != nil {
                guard let val = snapshot.value as? Int else {
                    completion(-1)
                    return
                }
                completion(val)
            } else {
                completion(-1)
            }
        }) { (err) in
            print("Failed to fetch user from database:", err)
        }
    }
    
    func fetchTokenNumSigned(token_id: String, completion: @escaping (Int) -> ()) {
        Database.database().reference().child("numSignersForToken").child(token_id).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.value != nil {
                guard let val = snapshot.value as? Int else {
                    completion(-1)
                    return
                }
                completion(val)
            } else {
                completion(-1)
            }
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
