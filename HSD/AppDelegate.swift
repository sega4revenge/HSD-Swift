///
///  AppDelegate.swift
///  HSD
///
///  Created by Tô Tử Siêu on 5/30/18.
///  Copyright © 2018 Finger. All rights reserved.
///
extension String {
    
    func localized(bundle: Bundle = .main, tableName: String = "Localizable") -> String {
        return NSLocalizedString(self, tableName: tableName, value: "**\(self)**", comment: "")
    }
}


import UIKit
import FBSDKCoreKit
import Firebase
import GoogleSignIn
import UserNotifications
import EventKit
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate  {
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        //// Perform any operations when the user disconnects from app here.
        //// ...
    }
    
    
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        /// Pre Config monitor network and notification
        FirebaseApp.configure()
        UNUserNotificationCenter.current().delegate = self
        ReachabilityManager.shared.startMonitoring()
        //         (self.window!.rootViewController as! UINavigationController).navigationBar.setValue(true, forKey: "hidesShadow")
        /// Check is logged
        if(AppUtils.getUserID() != "")
        {
            /// Go to home controller if logged
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "home")
            let rootViewController = self.window!.rootViewController as! UINavigationController
            
            rootViewController.pushViewController(initialViewController, animated: false)
            
            ReachabilityManager.shared.startMonitoring()
            
            return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        }
        else
        {
            /// Request permision notification
            
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
                
                guard error == nil else {
                    /// Display error something
                    return
                }
                
                if granted {
                    /// Do something after grant
                }
                else {
                    /// Show alert dialog to warning permision
                    let alertController = UIAlertController (title: "Cảnh báo", message: "Ứng dụng không thể thông báo hạn sử dụng nếu không được cấp quyền truy cập thông báo", preferredStyle: .alert)
                    
                    let settingsAction = UIAlertAction(title: "Đi đến cài đặt", style: .default) { (_) -> Void in
                        guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                            return
                        }
                        
                        if UIApplication.shared.canOpenURL(settingsUrl) {
                            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                
                            })
                        }
                    }
                    alertController.addAction(settingsAction)
                    DispatchQueue.main.sync {
                        self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
                    }
                    
                    
                    
                }
            }
            
            
            
            
            
            return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        }
        
        
        
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        if(notification.request.content.categoryIdentifier == "midnight")
        {
            /// Daily check expired product at midnight
            AppUtils.reloadNotification()
            AppUtils.loadEventsToNotification()
            completionHandler([])
        }
        else if(notification.request.content.categoryIdentifier == "report")
        {
            /// Report  expired and warning product
            AppUtils.loadEventsToNotification()
            //                let noti = NotificationModel()
            //                noti._id = AppUtils.objectId()
            //                noti.type = 1
            //                noti.created_at = AppUtils.calendar.date(byAdding: .hour, value: 0, to: Date())!.timeIntervalSince1970*1000
            //                noti.content = notification.request.content.body
            //                try! AppUtils.getInstance().write {
            //
            //                    print("da them")
            //                    AppUtils.getInstance().add(noti, update: false)
            //                }
            //                let data:[String: NotificationModel] = ["notification": noti]
            //                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notification_update"), object: nil,
            //                                                userInfo: data)
            completionHandler([.alert, .badge, .sound])
        }
        
        
        
        
        
        
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
       
        /// When user click to notification
        completionHandler()
    }
    func applicationWillResignActive(_ application: UIApplication) {
        FBSDKAppEvents.activateApp()
        
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any])
        -> Bool {
            return GIDSignIn.sharedInstance().handle(url,
                                                     sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                     annotation: [:])
    }
    
    
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        /// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        /// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        
        
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        /// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        /// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        
        /// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

