//
//  PushNotificationManager.swift
//  BitSigApp
//
//  Created by Andrei Homentcovschi on 5/13/21.
//  Copyright © 2021 Andrei Homentcovschi. All rights reserved.
//

import Firebase
import FirebaseMessaging
import UIKit
import UserNotifications
import FirebaseAuth
import FirebaseDatabase

class PushNotificationManager: NSObject, MessagingDelegate, UNUserNotificationCenterDelegate {
    
    func registerForPushNotifications() {
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            // For iOS 10 data message (sent via FCM)
            Messaging.messaging().delegate = self
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }

        UIApplication.shared.registerForRemoteNotifications()
        updatePushTokenIfNeeded()
    }

    func updatePushTokenIfNeeded() {
        if let token = Messaging.messaging().fcmToken {
            Database.database().setUserfcmToken(token:token) { (err) in
                if err != nil {
                    return
                }
            }
        }
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        updatePushTokenIfNeeded()
    }
    
}
