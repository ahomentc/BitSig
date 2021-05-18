//
//  Models.swift
//  BitSigApp
//
//  Created by Andrei Homentcovschi on 5/10/21.
//  Copyright © 2021 Andrei Homentcovschi. All rights reserved.
//

import Foundation

struct User: Equatable, Codable {
    
    let ethereum_address: String
    let uid: String
    let username: String
    let name: String
    let twitter: String
    let twitter_followers_count: Int
    let profileImageURL: String

    init(uid: String, dictionary: [String: Any]) {
        print(dictionary)
        self.ethereum_address = dictionary["eth_address"] as? String ?? ""
        self.uid = uid
        self.username = dictionary["username"] as? String ?? ""
        self.name = dictionary["name"] as? String ?? ""
        self.twitter = dictionary["twitter_username"] as? String ?? ""
        self.profileImageURL = dictionary["profileImageUrl"] as? String ?? ""
        if dictionary["twitter_followers_count"] as? Int ?? 0 > 0 {
            self.twitter_followers_count = dictionary["twitter_followers_count"] as? Int ?? 0
        }
        else {
            self.twitter_followers_count = 0
        }
    }
    
    static func ==(lhs: User, rhs: User) -> Bool {
        return lhs.uid == rhs.uid
    }
}


struct Token {
    let tokenID: String
    let name: String
    let description: String
    let imgURL: String
    let ipfs: String
    let owner: String
    
    init(tokenID: String, dictionary: [String: Any]) {
        self.tokenID = tokenID
        self.imgURL = dictionary["img"] as? String ?? ""
        self.ipfs = dictionary["ipfs"] as? String ?? ""
        self.owner = dictionary["owner"] as? String ?? ""
        self.name = dictionary["Name"] as? String ?? ""
        self.description = dictionary["Description"] as? String ?? ""
    }
}
