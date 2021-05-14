//
//  PushNotificationSender.swift
//  BitSigApp
//
//  Created by Andrei Homentcovschi on 5/13/21.
//  Copyright © 2021 Andrei Homentcovschi. All rights reserved.
//

import UIKit

class PushNotificationSender {
    func sendPushNotification(to token: String, title: String, body: String, click_action: String? = nil) {
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        let paramString: [String : Any] = ["to" : token,
                                           "notification" : ["title" : title, "body" : body, "badge": 1, "click_action": click_action ?? ""]
        ]

        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=AAAAWXgR4k8:APA91bGZtFQe2sGb-pS_IChEibwNQyJ_gNqx8vWTwQe_bZjt2otnaFU7QtPNkOIDe6mIi0z_mgr45ZFfzN4qE1EKQP3vwvL0ra5hhILlLT2azt9afTh9032o564N6Evb29kNTiz9i1L5", forHTTPHeaderField: "Authorization")

        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        NSLog("Received data:\n\(jsonDataDict))")
                    }
                }
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
        task.resume()
    }
    
    func sendJustBadgePushNotification(to token: String) {
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        let paramString: [String : Any] = ["to" : token, "notification" : ["badge": 1]
        ]

        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=AAAAWXgR4k8:APA91bGZtFQe2sGb-pS_IChEibwNQyJ_gNqx8vWTwQe_bZjt2otnaFU7QtPNkOIDe6mIi0z_mgr45ZFfzN4qE1EKQP3vwvL0ra5hhILlLT2azt9afTh9032o564N6Evb29kNTiz9i1L5", forHTTPHeaderField: "Authorization")

        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        NSLog("Received data:\n\(jsonDataDict))")
                    }
                }
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
        task.resume()
    }
}

