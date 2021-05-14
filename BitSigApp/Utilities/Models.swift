//
//  Models.swift
//  BitSigApp
//
//  Created by Andrei Homentcovschi on 5/10/21.
//  Copyright © 2021 Andrei Homentcovschi. All rights reserved.
//

import Foundation

struct User: Equatable, Codable {
    
    let uid: String
    let username: String
    let name: String
    let twitter: String
    let ethereum_address: String
    
    init(uid: String, dictionary: [String: Any]) {
        self.uid = uid
        self.username = dictionary["username"] as? String ?? ""
        self.name = dictionary["name"] as? String ?? ""
        self.twitter = dictionary["twitter"] as? String ?? ""
        self.ethereum_address = dictionary["ethereum_address"] as? String ?? ""
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
