//
//  AppDelegate.swift
//  HSD
//
//  Created by Tô Tử Siêu on 5/30/18.
//  Copyright © 2018 Finger. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import Firebase
import GoogleSignIn
import UserNotifications
import EventKit
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate  {
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    @objc func calendarDayDidChange()
    {
        
        AppUtils.setScheduleRepeat(hour: 8,minute: 10)
        AppUtils.loadEventsToNotification()
        print("fgdfgdfhdfh")
        
    }
    
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        UNUserNotificationCenter.current().delegate = self
            NotificationCenter.default.addObserver(self, selector:#selector(self.calendarDayDidChange), name: NSNotification.Name.NSCalendarDayChanged, object:nil)
       UNUserNotificationCenter.current().scheduleNotificationMidNight()
        if(AppUtils.getUserID() != "")
        {

            let storyboard = UIStoryboard(name: "Main", bundle: nil)

            let initialViewController = storyboard.instantiateViewController(withIdentifier: "home")
            let rootViewController = self.window!.rootViewController as! UINavigationController

            rootViewController.pushViewController(initialViewController, animated: false)

            ReachabilityManager.shared.startMonitoring()
            
            return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        }
        else
        {
            // Setup Notifications
         
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
                
                guard error == nil else {
                    //Display Error.. Handle Error.. etc..
                    return
                }
                
                if granted {
//                    //Do stuff here..
//                    let eventStore = EKEventStore()
//                    eventStore.requestAccess(to: EKEntityType.event) { (granted, error) -> Void in
//
//                        if let e = error {
//                            print("Error \(e.localizedDescription)")
//                            return
//                        }
//
//                        if granted {
//
//
//                            print("access granted")
//                            let calendars = eventStore.calendars(for: .event)
//                            var isCreate :Bool = false
//                            for calendar in calendars {
//                                if calendar.title == "HSD" {
//                                    isCreate = true
//                                    print("da tao")
//                                    if(AppUtils.getCalendarID()==""||AppUtils.getFirstTime()==true)
//                                    {
//                                        do{
//                                            try  eventStore.removeCalendar(calendar, commit: true)
//                                            let newCalendar = EKCalendar(for :EKEntityType.event, eventStore:eventStore)
//
//                                            newCalendar.title="HSD"
//                                            newCalendar.source = eventStore.defaultCalendarForNewEvents?.source
//                                            AppUtils.storeCalendarID(id: newCalendar.calendarIdentifier)
//                                            try eventStore.saveCalendar(newCalendar, commit:true)
//
//
//
//                                        }
//                                        catch
//                                        {
//                                            print("error")
//                                        }
//                                    }
//
//
//
//                                }
//                            }
//                            if(isCreate == false)
//                            {
//                                print("chua tao")
//                                let newCalendar = EKCalendar(for :EKEntityType.event, eventStore:eventStore)
//
//                                newCalendar.title="HSD"
//                                newCalendar.source = eventStore.defaultCalendarForNewEvents?.source
//                                AppUtils.storeCalendarID(id: newCalendar.calendarIdentifier)
//                                do{
//
//                                    try eventStore.saveCalendar(newCalendar, commit:true)
//
//                                }
//                                catch {
//                                    print("error")
//                                }
//                            }
//
//
//
//                        }
//                        else{
//                            let alertController = UIAlertController (title: "Cảnh báo", message: "Ứng dụng không thể hoạt động nếu không được cấp quyền truy cập lịch", preferredStyle: .alert)
//
//                            let settingsAction = UIAlertAction(title: "Đi đến cài đặt", style: .default) { (_) -> Void in
//                                guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
//                                    return
//                                }
//                                if UIApplication.shared.canOpenURL(settingsUrl) {
//                                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
//
//                                    })
//                                }
//                            }
//                            alertController.addAction(settingsAction)
//                            DispatchQueue.main.sync {
//                                self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
//                            }
//
//
//
//
//
//                        }
                    
                  
                    
                }
                else {
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
           
            
   
              ReachabilityManager.shared.startMonitoring()
            
             return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        }
       
      
       
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        if(notification.request.content.categoryIdentifier == "midnight")
        {
            print("1 lan")
            AppUtils.setScheduleRepeat(hour: 0,minute: 10)
            AppUtils.loadEventsToNotification()
              completionHandler([])
        }
        else if(notification.request.content.title == "Tổng hợp")
            {
                let noti = NotificationModel()
                noti._id = AppUtils.objectId()
                noti.type = 1
                noti.created_at = AppUtils.calendar.date(byAdding: .hour, value: 0, to: Date())!.timeIntervalSince1970*1000
                noti.content = notification.request.content.body
                try! AppUtils.getInstance().write {
                    
                    print("da them")
                    AppUtils.getInstance().add(noti, update: false)
                }
                let data:[String: NotificationModel] = ["notification": noti]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notification_update"), object: nil,
                                                userInfo: data)
                 completionHandler([.alert, .badge, .sound])
            }

        
     
       
      
      
      
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("da nhan thong bao 1")
        print(response.notification.request.content.categoryIdentifier)
        
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
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
       
    
            
    
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
     
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
      
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

