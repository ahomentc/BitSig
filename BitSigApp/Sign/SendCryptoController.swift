//
//  SendCryptoController.swift
//  BitSigApp
//
//  Created by Andrei Homentcovschi on 7/2/21.
//  Copyright © 2021 Andrei Homentcovschi. All rights reserved.
//

import UIKit
import web3swift
import Foundation

class SendCryptoController: UIViewController {
    
//    let web3 = Web3.InfuraMainnetWeb3(accessToken: "a1d2d05b386a403296580b00c8032130")
//    let web3 = Web3.InfuraRinkebyWeb3(accessToken: "a1d2d05b386a403296580b00c8032130")
    let web3 = Web3.InfuraRopstenWeb3(accessToken: "a1d2d05b386a403296580b00c8032130")
//    let web3 = Web3.InfuraRopstenWeb3()
    
        
    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.backgroundColor = UIColor(red: 0/255, green: 166/255, blue: 107/255, alpha: 1)
        button.layer.cornerRadius = 15
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(sendEth), for: .touchUpInside)
        return button
    }()
    
    private lazy var amountInput: UITextField = {
        let tf = UITextField()
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        tf.backgroundColor = UIColor(white: 0, alpha: 0)
        tf.borderStyle = .none
        tf.textColor = .clear
        tf.tintColor = .clear
        tf.textAlignment = .center
        tf.keyboardType = .numberPad
        tf.font = UIFont.systemFont(ofSize: 40)
        tf.delegate = self
        tf.addTarget(self, action: #selector(handleAmountInputChange), for: .editingChanged)
        return tf
    }()
    
    // this displays over the actual input
    private lazy var amountInputFormatted: UITextField = {
        let tf = UITextField()
        tf.backgroundColor = UIColor(white: 0, alpha: 0)
        tf.borderStyle = .none
        tf.placeholder = "$ Amount"
        tf.textAlignment = .center
        tf.isUserInteractionEnabled = false
        tf.font = UIFont.systemFont(ofSize: 40)
        return tf
    }()
    
    private lazy var ethAmountFormatted: UITextField = {
        let tf = UITextField()
        tf.backgroundColor = UIColor(white: 0, alpha: 0)
        tf.borderStyle = .none
        tf.placeholder = ""
        tf.textColor = UIColor(white: 0.7, alpha: 1)
        tf.textAlignment = .center
        tf.isUserInteractionEnabled = false
        tf.font = UIFont.systemFont(ofSize: 20)
        return tf
    }()
    
    private lazy var addressInput: UITextField = {
        let tf = UITextField()
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        tf.placeholder = "Recipient Address"
        tf.backgroundColor = UIColor.init(white: 0.95, alpha: 1)
        tf.borderStyle = .none
        tf.layer.cornerRadius = 15
        tf.setLeftPaddingPoints(15)
        tf.clipsToBounds = true
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.delegate = self
        tf.addTarget(self, action: #selector(handleAddressInputChange), for: .editingChanged)
        return tf
    }()
    
    private lazy var transacationIDLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.black
        label.layer.zPosition = 4
        label.numberOfLines = 0
        label.lineBreakMode = .byCharWrapping
        label.textAlignment = .center
        return label
    }()
    
    var ethValue = -1.0
    var ethAmount = NSDecimalNumber(0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        self.view.backgroundColor = .white
        
        let btnDone = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissView))
        self.navigationItem.rightBarButtonItem = btnDone
        self.navigationItem.title = "Send Eth"
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        amountInput.frame = CGRect(x: UIScreen.main.bounds.width/2 - (UIScreen.main.bounds.width - 50)/2, y: 100, width: UIScreen.main.bounds.width - 50, height: 50)
        view.insertSubview(amountInput, at: 5)
        
        amountInputFormatted.frame = CGRect(x: UIScreen.main.bounds.width/2 - (UIScreen.main.bounds.width - 50)/2, y: 100, width: UIScreen.main.bounds.width - 50, height: 50)
        view.insertSubview(amountInputFormatted, at: 6)
        
        ethAmountFormatted.frame = CGRect(x: UIScreen.main.bounds.width/2 - (UIScreen.main.bounds.width - 50)/2, y: 150, width: UIScreen.main.bounds.width - 50, height: 50)
        view.insertSubview(ethAmountFormatted, at: 6)
        
        addressInput.frame = CGRect(x: UIScreen.main.bounds.width/2 - (UIScreen.main.bounds.width - 50)/2, y: 210, width: UIScreen.main.bounds.width - 50, height: 45)
        view.insertSubview(addressInput, at: 5)
        
        sendButton.frame = CGRect(x: UIScreen.main.bounds.width/2 - 100, y: 300, width: 180, height: 55)
        view.insertSubview(sendButton, at: 5)
        
        transacationIDLabel.frame = CGRect(x: UIScreen.main.bounds.width/2 - (UIScreen.main.bounds.width - 50)/2, y: 380, width: UIScreen.main.bounds.width - 50, height: 95)
        view.insertSubview(transacationIDLabel, at: 5)
        
        
        self.makeValueGETRequest(url: URL(string: "https://min-api.cryptocompare.com/data/price?fsym=ETH&tsyms=USD")!) { (value) in
            DispatchQueue.main.async {
                let valueDouble = value?.doubleValue
                if valueDouble != nil {
                    self.ethValue = valueDouble!
                }
            }
        }
        amountInput.becomeFirstResponder()
        
        getKeystoreManager(completion: { (keystoreManager) in
            self.web3.addKeystoreManager(keystoreManager)
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @objc func sendEth() {
//        try! self.web3.eth.getBalance(address: walletAddress!)
//        options.gasPrice = gasPrice
        
                
        if let toAddressString = addressInput.text {
            if toAddressString.count == 42 {
                getWallet(completion: { (wallet) in
                    let walletAddress = EthereumAddress(wallet.address)! // Your wallet address
                    let toAddress = EthereumAddress(toAddressString)!
                    self.sendButton.isEnabled = false
                    self.sendButton.backgroundColor = .clear
                    self.sendButton.setTitleColor(UIColor(red: 0/255, green: 166/255, blue: 107/255, alpha: 1), for: .normal)
                    self.sendButton.setTitle("Confirming Transaction", for: .normal)
                    DispatchQueue.global(qos: .userInitiated).async {
                        do {
                            let tx = self.web3.eth.sendETH(from: walletAddress, to: toAddress, amount: String(self.ethAmount.stringValue.prefix(8)))
                            print(tx)
                            let result  = try tx?.send(password: "", transactionOptions: tx?.transactionOptions)
                            DispatchQueue.main.async {
                                if result != nil && result!.transaction.txid != nil {
                                    print(result)
                                    self.sendButton.setTitle("Sent!", for: .normal)
                                    self.transacationIDLabel.text = "Transaction ID:\n" + result!.transaction.txid!
                                }
                                else {
                                    self.sendButton.isEnabled = true
                                    self.sendButton.backgroundColor = UIColor(red: 0/255, green: 166/255, blue: 107/255, alpha: 1)
                                    self.sendButton.setTitleColor(.white, for: .normal)
                                    self.sendButton.setTitle("Send", for: .normal)
                                    print("transaction failed")
                                    let ac = UIAlertController(title: "Transaction Failed", message: "Please try again in a few minutes.", preferredStyle: .alert)
                                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                                    self.present(ac, animated: true)
                                }
                            }
                            
                        }
                        catch {
                            print(error)
                        }
                    }
                })
                
//                https://github.com/skywinder/web3swift/blob/develop/Tests/web3swiftTests/web3swift_User_cases.swift
//                getWallet(completion: { (wallet) in
//                    DispatchQueue.global(qos: .userInitiated).async {
//                        getKeystoreManager(completion: { (keystoreManager) in
//                            self.web3.addKeystoreManager(keystoreManager)
//
//                            let value: String = String(self.ethAmount.stringValue.prefix(8))
//                            let walletAddress = EthereumAddress(wallet.address)! // Your wallet address
//                            let toAddress = EthereumAddress(toAddressString)!
//                            let contract = self.web3.contract(Web3.Utils.coldWalletABI, at: toAddress, abiVersion: 2)!
//                            let amount = Web3.Utils.parseToBigUInt(value, units: .eth)
//                            var options = TransactionOptions.defaultOptions
//                            options.value = amount
//                            options.from = walletAddress
//                            options.gasPrice = .automatic
//                            options.gasLimit = .automatic
//
//                            let parameters = [toAddress, amount as Any] as [AnyObject]
//                            let tx = contract.write(
//                                "fallback",
//                                parameters: parameters,
//                                extraData: Data(),
//                                transactionOptions: options)
//                            do {
//                                let result  = try tx?.send(password: "", transactionOptions: options)
//                                print(result)
//                                print(result?.transaction.description)
//                                print(result?.transaction.gasPrice)
//                                print(result?.transaction.txid)
//                            } catch {
//                                print(error)
//                            }
//                        })
//                    }
//                })
            }
        }
    }
    
    @objc private func handleAmountInputChange() {
        let isFormValid = amountInput.text?.isEmpty == false
        if isFormValid {
            let amountString = amountInput.text!
            let amount = Double(amountString)! / 100
            amountInputFormatted.text = formatAsCurrencyString(value: NSNumber(value: amount))
            
            if ethValue > 0 {
//                ethAmount.text = String((amount/ethValue).rounded(toPlaces: 5)) + "eth"
                let decimalNumber = NSDecimalNumber(decimal: Decimal((amount/ethValue)))
                self.ethAmount = decimalNumber
                ethAmountFormatted.text = decimalNumber.stringValue.prefix(8) + " eth"
            }
        }
        else {
            amountInputFormatted.text = ""
            ethAmountFormatted.text = ""
        }
    }
    
    @objc private func handleAddressInputChange() {
        let isFormValid = addressInput.text?.isEmpty == false
        if isFormValid {
//            submitRestoreButton.isEnabled = true
//            submitRestoreButton.backgroundColor = UIColor(red: 0/255, green: 166/255, blue: 107/255, alpha: 1)
        } else {
//            submitRestoreButton.isEnabled = false
//            submitRestoreButton.backgroundColor = UIColor(red: 0/255, green: 166/255, blue: 107/255, alpha: 0.7)
        }
    }
    
    @objc func dismissView() {
        self.dismiss(animated: true, completion: {})
    }
    
    @objc func dismissKeyboard() {
        addressInput.resignFirstResponder()
        amountInput.resignFirstResponder()
    }
    
    private func formatAsCurrencyString(value: NSNumber?) -> String? {
        /// Construct a NumberFormatter that uses the US Locale and the currency style
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .currency

        // Ensure the value is non-nil and we can format it using the numberFormatter, if not return nil
        guard let value = value,
            let formattedCurrencyAmount = formatter.string(from: value) else {
                return nil
        }
        return formattedCurrencyAmount
    }
    
    private func makeValueGETRequest(url: URL, completion: @escaping (_ value: NSNumber?) -> Void) {
        let request = URLSession.shared.dataTask(with: url) { (data, response, error) in
            // Unwrap the data and make sure that an error wasn't returned
            guard let data = data, error == nil else {
                // If an error was returned set the value in the completion as nil and print the error
                completion(nil)
                print(error?.localizedDescription ?? "")
                return
            }
            
            do {
                // Unwrap the JSON dictionary and read the USD key which has the value of Ethereum
                guard let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
                    let value = json["USD"] as? NSNumber else {
                        completion(nil)
                        return
                }
                completion(value)
            } catch  {
                // If we couldn't serialize the JSON set the value in the completion as nil and print the error
                completion(nil)
                print(error.localizedDescription)
            }
        }
        
        request.resume()
    }
}

extension SendCryptoController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
