//
//  UNUserNotificationCenter.swift
//  HSD
//
//  Created by Tô Tử S iêu on 6/15/18.
//  Copyright © 2018 Finger. All rights reserved.
//

import UIKit
import UserNotifications
import EventKit
extension UNUserNotificationCenter {
    //=============================================================================
    func scheduleNotification(at date: Date, product : Product,hour : Int , minute : Int) {
        
        var triggerWeekly = AppUtils.calendar.dateComponents([.day,.month,.year,.hour,.minute,.second,], from: date)
        triggerWeekly.hour = hour
        triggerWeekly.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerWeekly, repeats: false)
        
        let content = UNMutableNotificationContent()
        content.categoryIdentifier = product.namechanged!
        content.title = product.namechanged!
        content.body = product._id!
        
        let request = UNNotificationRequest(identifier: product._id!, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [product._id!])
        //UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().add(request) {(error) in
            if let error = error {
                print(" We had an error: \(error)")
            }
            else{
                
            }
        }
    }
    //=============================================================================
    func scheduleNotificationRepeat(hour : Int , minute : Int) {
        
        
        var triggerWeekly = DateComponents()
        triggerWeekly.hour = hour
        triggerWeekly.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerWeekly, repeats: true)
       
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)
        let content = UNMutableNotificationContent()
        content.title = "Tổng hợp"
        content.sound = UNNotificationSound.default()
      content.categoryIdentifier = "report"
        content.body = "Hôm nay có \(AppUtils.loadEvents()) sản phẩm sắp hết hạn và \(AppUtils.loadEventsExpired()) sản phẩm đã hết hạn"
  
        let request = UNNotificationRequest(identifier: "\(hour):\(minute)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["\(hour):\(minute)"])
                UNUserNotificationCenter.current().add(request) {(error) in
                    if let error = error {
                        print(" We had an error: \(error)")
                    }
                    else{
                        print(" thanh cong roi")
                    }
              
            
        }
       
      
    }
    
    func scheduleNotificationMidNight() {
        
        
        var triggerWeekly = DateComponents()
        triggerWeekly.hour = 0
        triggerWeekly.minute = 0
        
                let trigger = UNCalendarNotificationTrigger(dateMatching: triggerWeekly, repeats: true)
        
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 70, repeats: true)
        let content = UNMutableNotificationContent()
        content.title = "Chú ý"
        content.categoryIdentifier = "midnight"
   
        content.body = "Có \(AppUtils.loadEventsExpired()) bắt đầu hết hạn hôm nay"
        
        let request = UNNotificationRequest(identifier: "midnight", content: content, trigger: trigger)
        
        //UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
     UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["midnight"])
                UNUserNotificationCenter.current().add(request) {(error) in
                    if let error = error {
                        print(" We had an error: \(error)")
                    }
                    else{
                        print(" thanh cong roi 2")
                    }
                }

    }
    //    func readEvents() {
    //
    //
    //        let eventStore = EKEventStore()
    //        let calendars = eventStore.calendars(for: .event)
    //        let oneMonthAgo = NSDate(timeIntervalSinceNow: -30*24*3600)
    //        let oneMonthAfter = NSDate(timeIntervalSinceNow: +30*24*3600)
    //
    //
    //        let predicate = eventStore.predicateForEvents(withStart: oneMonthAgo as Date, end: oneMonthAfter as Date, calendars: [calendar])
    //
    //        var events = eventStore.events(matching: predicate)
    //
    //        for event in events {
    //
    //            titles.append(event.title)
    //        }
    //     }
    
}
