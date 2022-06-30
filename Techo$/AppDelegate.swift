//
//  AppDelegate.swift
//  Techo$
//
//  Created by Yue Yan on 26/4/2022.
//

import UIKit
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    static let CATEGORY_IDENTIFIER = "Techo$.categories"
    
    var notificationsEnabled = false

    var databaseController: DatabaseProtocol?
    var authController: AuthenticationController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        authController = AuthenticationController()
        databaseController = FirebaseController()
//        authController?.addListener(listener: databaseController)
        registerForPushNotifications()
        return true
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


    // MARK: Push Notification
    func registerForPushNotifications() {
        let notificationCenter = UNUserNotificationCenter.current()
        
        notificationCenter.getNotificationSettings { notificationSettings in
            if notificationSettings.authorizationStatus == .notDetermined {
                
                notificationCenter.requestAuthorization(options: [.alert]) { granted, error in
                    self.notificationsEnabled = granted
                    if granted {
                        self.setupNotifications()
                    }
                }
            }
            else if notificationSettings.authorizationStatus == .authorized {
                self.notificationsEnabled = true
                self.setupNotifications()
            }
        }
    }
    
    func setupNotifications() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = self
        
        let acceptAction = UNNotificationAction(identifier: "accept", title: "Accept", options: .foreground)
        let declineAction = UNNotificationAction(identifier: "decline", title: "Decline", options: .destructive)
        // Set up the category
        let appCategory = UNNotificationCategory(identifier: AppDelegate.CATEGORY_IDENTIFIER, actions: [acceptAction, declineAction], intentIdentifiers: [], options: UNNotificationCategoryOptions(rawValue: 0))
        
        // Register the category just created with the notification centre
        notificationCenter.setNotificationCategories([appCategory])
    }

    // MARK: UNUserNotificationCenterDelegate methods

    // Function required when registering as a delegate. We can process notifications if they are in the foreground!
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Print some information to console saying we have recieved the notification
        // We could do some automatic processing here if we didnt want the user's response
        print("Notification triggered while app running")
        
        // By default iOS will silence a notification if the application is in the foreground. We can over-ride this with the following
        completionHandler([.banner])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping () -> Void) {
        // setup variables
        let content = notification.request.content
        let userInfo = content.userInfo
        guard let goalID = userInfo["id"] as? String else {return}
        let goalNotificationID = AppDelegate.CATEGORY_IDENTIFIER + "GOALS." + goalID
        
        // check if notification is for goal
        if content.categoryIdentifier == goalNotificationID {
            // remove notification if data cannot be set up
            guard let goal = databaseController?.fetchGoalByID(goalID), let date = goal.targetDate, let amount = goal.remainingAmount else {
                print("Notification has error! Delete!")
                center.removePendingNotificationRequests(withIdentifiers: [goalNotificationID])
                return
            }
            
            // if notification no longer satisfy conditions, delete notification
            if date < Date() || amount <= 0 {
                print("Date is already past! delete notification")
                center.removePendingNotificationRequests(withIdentifiers: [goalNotificationID])
            }
        }
        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // setup variables
        let content = response.notification.request.content
        let userInfo = content.userInfo
        guard let goalID = userInfo["id"] as? String else {return}
        let goalNotificationID = AppDelegate.CATEGORY_IDENTIFIER + "GOALS." + goalID
        
        // check if notification is for goal
        if content.categoryIdentifier == goalNotificationID {
            // remove notification if data cannot be set up
            guard let goal = databaseController?.fetchGoalByID(goalID), let date = goal.targetDate, let amount = goal.remainingAmount, let regularity = userInfo["regularity"] as? Int else {
                print("Notification has error! Delete!")
                center.removePendingNotificationRequests(withIdentifiers: [goalNotificationID])
                return
            }
            
            // if error in system do nothing
            guard let nextDate = Calendar.current.date(byAdding: .day, value: regularity, to: Date()) else {
                print("error in decoding date")
                return
                
            }
            
            // if notification no longer satisfy conditions, delete notification
            if date < Date() || amount <= 0 || nextDate > date{
                print("Date is already past! delete notification")
                center.removePendingNotificationRequests(withIdentifiers: [goalNotificationID])
            }
        }
        completionHandler()
    }


}

