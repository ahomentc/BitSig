//
//  web3utilities.swift
//  BitSigApp
//
//  Created by Andrei Homentcovschi on 6/25/21.
//  Copyright © 2021 Andrei Homentcovschi. All rights reserved.
//

import Foundation
import web3swift

func getWallet(completion: @escaping (Wallet) -> ()) {
    let keystore_service = "keystoreService"
    let address_service = "addressService"
    let account = "myAccount"
    print("1.1")
    if let keyStoreString = KeychainService.loadPassword(service: keystore_service, account: account) {
        print("2.2")
        if let address = KeychainService.loadPassword(service: address_service, account: account) {
            print("3.3")
            if let keyData = keyStoreString.data(using: .utf8) {
                let name = "New HD Wallet"
                let wallet = Wallet(address: address, data: keyData, name: name, isHD: true)
                completion(wallet)
            }
        }
    }
}


func getPrivateKey(completion: @escaping (Data) -> ()) {
    let keystore_service = "keystoreService"
    let address_service = "addressService"
    let account = "myAccount"
    
    if let keyStoreString = KeychainService.loadPassword(service: keystore_service, account: account) {
        if let address = KeychainService.loadPassword(service: address_service, account: account) {
            if let keyData = keyStoreString.data(using: .utf8) {
                let keystore = BIP32Keystore(keyData)!
                let keystoreManager = KeystoreManager([keystore])
                let pkData = try! keystoreManager.UNSAFE_getPrivateKeyData(password: "", account: EthereumAddress(address)!)
                completion(pkData)
            }
        }
    }
}

func getKeystoreManager(completion: @escaping (KeystoreManager) -> ()) {
    let keystore_service = "keystoreService"
    let address_service = "addressService"
    let account = "myAccount"
    
    if let keyStoreString = KeychainService.loadPassword(service: keystore_service, account: account) {
        if let address = KeychainService.loadPassword(service: address_service, account: account) {
            if let keyData = keyStoreString.data(using: .utf8) {
                let keystore = BIP32Keystore(keyData)!
                let keystoreManager = KeystoreManager([keystore])
                completion(keystoreManager)
            }
        }
    }
}

func setKeystoreIfWalletSet() {
    let mnemonics_service = "mnemonicsService"
    let keystore_service = "keystoreService"
    let address_service = "addressService"
    let account = "myAccount"
    
    if let keyStoreString = KeychainService.loadPassword(service: keystore_service, account: account) {
        // nothing to do here, keystore already exists
    }
    else {
        if let mnemonicsString = KeychainService.loadPassword(service: mnemonics_service, account: account) {
            DispatchQueue.global(qos: .userInitiated).async {
                let keystore = try! BIP32Keystore(
                    mnemonics: mnemonicsString,
                    password: "",
                    mnemonicsPassword: "",
                    language: .english)!
                let address = keystore.addresses!.first!.address
                let keyData = try! JSONEncoder().encode(keystore.keystoreParams)
                let keyStoreString = String(data: keyData, encoding: .utf8)
                KeychainService.savePassword(service: keystore_service, account: account, data: keyStoreString ?? "")
                KeychainService.savePassword(service: address_service, account: account, data: address)
                print("set keystore")
                NotificationCenter.default.post(name: NSNotification.Name("keychainSet"), object: nil)
            }
        }
    }
}

