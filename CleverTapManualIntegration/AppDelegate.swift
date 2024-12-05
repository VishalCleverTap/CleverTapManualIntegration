//
//  AppDelegate.swift
//  CleverTapManualIntegration
//
//  Created by Vishal More on 28/11/24.
//

import UIKit
import FirebaseCore
import FirebaseMessaging
import UserNotifications
import CleverTapSDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        //CleverTap Implementation
        CleverTap.setDebugLevel(CleverTapLogLevel.debug.rawValue)
        CleverTap.sharedInstance()?.enableDeviceNetworkInfoReporting(true)
        registerForPush()
        return true
    }
    
    func registerForPush() {
        
        let action1 = UNNotificationAction(identifier: "action_1", title: "Back", options: [])
        let action2 = UNNotificationAction(identifier: "action_2", title: "Next", options: [])
        //let action3 = UNNotificationAction(identifier: "action_3", title: "View In App", options: [])
        let categorywithAction = UNNotificationCategory(identifier: "CTNotification", actions: [action1, action2], intentIdentifiers: [], options: [])
        let categoryNoAction = UNNotificationCategory(identifier: "CTNotification2", actions: [], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([categoryNoAction,categorywithAction])
        
        // Register for Push notifications
        UNUserNotificationCenter.current().delegate = self
        // request Permissions
        UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .badge, .alert], completionHandler: {granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        })
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken.description)")
        NSLog("%@: registered for remote notifications: %@", self.description, deviceToken.description)
        
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        NSLog("%@: Device registered for remote notifications: %@", self.description, deviceTokenString )
        
        Messaging.messaging().apnsToken = deviceToken
        
        CleverTap.sharedInstance()?.setPushToken(deviceToken as Data)

    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        //When Push Notification is clicked.
        NSLog("%@: did receive notification response: %@", self.description, response.notification.request.content.userInfo)
        
        if(CleverTap.sharedInstance()?.isCleverTapNotification(response.notification.request.content.userInfo) ?? false){
            CleverTap.sharedInstance()?.handleNotification(withData: response.notification.request.content.userInfo, openDeepLinksInForeground: true)
        }
        
        completionHandler()
    }
    
    func userNotificationCenter(
       _ center: UNUserNotificationCenter,
       willPresent notification: UNNotification,
       withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
           
           //When Push Notification received
           NSLog("%@: did receive notification response: %@", self.description, notification.request.content.userInfo)
           
       completionHandler([.badge, .sound, .alert])
     }
}

// MARK: UISceneSession Lifecycle

func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
}

func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}







