//
//  Util.swift
//  HSD
//
//  Created by Tô Tử Siêu on 6/3/18.
//  Copyright © 2018 Finger. All rights reserved.
//

import UIKit
import RealmSwift
import EventKit

import UserNotifications
import Kingfisher
import Alamofire
extension Results {
    func toArray<T>(ofType: T.Type) -> [T] {
        let array = Array(self) as! [T]
        return array
    }
}
class AppUtils : NSObject  {
    static var productviewmodel : ProductViewModel? = nil
    static var userviewmodel : UserViewModel? = nil
    static var timezone  = 7
    static var calendar : Calendar = {
        var a = NSCalendar.current
        return a
    }()
    static var notificationCenter: UNUserNotificationCenter?
    static let BASE_URL = "https://hansudung.com/"
    static let NORMAL = 0
    static let FACEBOOK = 1
    static let GOOGLE = 2
    static let BASE_URL_IMAGE = BASE_URL + "getimage/?image="
    static var realm : Realm? = nil
    static var eventStore = EKEventStore()
    static var calendars:Array<EKCalendar> = []
    //==========================================================================
    static func getProductViewModel() -> ProductViewModel
    {
        
        if(productviewmodel == nil)
        {
          
            productviewmodel = ProductViewModel()
        }
      
        return productviewmodel!
    }
    static func getUserViewModel() -> UserViewModel
    {
        
        if(userviewmodel == nil)
        {
            userviewmodel = UserViewModel()
        }
        return userviewmodel!
    }
    static func getInstance() -> Realm{
        
        realm = try! Realm()
        
        return realm!
    }
    //==========================================================================   time function
    

    static func removeNotification(){
        
         UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                 UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    static func clearCache(){
        
        KingfisherManager.shared.cache.clearDiskCache()
        KingfisherManager.shared.cache.cleanExpiredDiskCache()
        KingfisherManager.shared.cache.clearMemoryCache()
    }
    static func dayDifference(from interval : Double) -> String
    {
        let date = Date(timeIntervalSince1970: interval/1000)
        
        if calendar.isDateInYesterday(date) { return "Hôm qua" }
        else if calendar.isDateInToday(date) { return "Hôm nay" }
        else if calendar.isDateInTomorrow(date) { return "Ngày mai" }
        else {
            let startOfNow = AppUtils.getStartLocalDate(date: Date())
            
            
            let startOfTimeStamp = AppUtils.getStartLocalDate(date: date)
            
            let components = calendar.dateComponents([.day], from: startOfNow, to: startOfTimeStamp)
            let day = components.day!
            if day < 1 { return "\(abs(day)) ngày" }
            else { return "\(day) ngày" }
        }
    }
    
    static func dayString(from interval : Double) -> String
    {
        let date = Date(timeIntervalSince1970: interval/1000)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "dd-MM-yyyy" //Specify your format that you want
        return dateFormatter.string(from: date)
    }
    static func createDate(weekday: Int, hour: Int, minute: Int, year: Int)->Date{
        
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        components.year = year
        components.weekday = weekday // sunday = 1 ... saturday = 7
        components.weekdayOrdinal = 10
        components.timeZone = .current
        
        let calendar = Calendar(identifier: .gregorian)
        return calendar.date(from: components)!
    }
    static func getCurrentLocalDate()-> Date {
        var now = Date()
        var nowComponents = DateComponents()
        
        
        nowComponents.year = Calendar.current.component(.year, from: now)
        nowComponents.month = Calendar.current.component(.month, from: now)
        nowComponents.day = Calendar.current.component(.day, from: now)
        nowComponents.hour = Calendar.current.component(.hour, from: now)
        nowComponents.minute = Calendar.current.component(.minute, from: now)
        nowComponents.second = Calendar.current.component(.second, from: now)
        now = calendar.date(from: nowComponents)!
        return calendar.date(byAdding: .hour, value: timezone, to: now)!
    }
    static func getStartLocalDate(date : Date)-> Date {
        var now = date
        
        var nowComponents = DateComponents()
        
        
        nowComponents.year = Calendar.current.component(.year, from: now)
        nowComponents.month = Calendar.current.component(.month, from: now)
        nowComponents.day = Calendar.current.component(.day, from: now)
        nowComponents.hour = 0
        nowComponents.minute = 0
        nowComponents.second = 0
        now = calendar.date(from: nowComponents)!
        return  calendar.date(byAdding: .hour, value: timezone, to: now)!
    }
    
    static func getEndLocalDate(date : Date)-> Date {
        var now = date
        var nowComponents = DateComponents()
        
        nowComponents.year = Calendar.current.component(.year, from: now)
        nowComponents.month = Calendar.current.component(.month, from: now)
        nowComponents.day = Calendar.current.component(.day, from: now)
   
        nowComponents.hour = 23
        nowComponents.minute = 59
        nowComponents.second = 59
        now = calendar.date(from: nowComponents)!
        return calendar.date(byAdding: .hour, value: timezone, to: now)!
    }
    
    static func countDay(from interval : Double) -> Int
    {
        
        let date =  calendar.date(byAdding: .hour, value: 0,to : Date(timeIntervalSince1970: interval/1000))!
     
      
        if calendar.isDateInYesterday(date) { return -1 }
        else if calendar.isDateInToday(date) { return 0 }
        else if calendar.isDateInTomorrow(date) { return 1 }
        else {
            let startOfNow = AppUtils.getStartLocalDate(date: calendar.date(byAdding: .hour, value: 0, to: Date())!)
          
            
            let startOfTimeStamp = AppUtils.getStartLocalDate(date: date)
            let components = calendar.dateComponents([.day], from: startOfNow, to: startOfTimeStamp)
            let day = components.day!
            return day
        
        }
    }
    //==========================================================================
    
    //==========================================================================   notification function
//    static func test(){
//         let   result = AppUtils.getInstance().objects(Product.self).filter("expiretime < \(calendar.date(byAdding: .hour, value: 0, to:AppUtils.getStartLocalDate(date: Date()))!.timeIntervalSince1970*1000) AND expiretime >= \(calendar.date(byAdding: .hour, value: 0, to:AppUtils.calendar.date(byAdding: .day, value: -1, to:AppUtils.getStartLocalDate(date: Date()))!)!.timeIntervalSince1970*1000)").sorted(byKeyPath: "expiretime", ascending: false)
//     
//        for index in 0...result.count - 1 {
//         
//            
//            
//        }
//      
//    }
//  
  
    static func loadEventsToNotification()  {
     
      let   result = AppUtils.getInstance().objects(Product.self).filter("expiretime < \(calendar.date(byAdding: .hour, value: 0, to:AppUtils.getStartLocalDate(date: Date()))!.timeIntervalSince1970*1000) AND expiretime >= \(calendar.date(byAdding: .hour, value: 0, to:AppUtils.calendar.date(byAdding: .day, value: -1, to:AppUtils.getStartLocalDate(date: Date()))!)!.timeIntervalSince1970*1000)").sorted(byKeyPath: "expiretime", ascending: false)
        
        if(result.count > 0){
            for index in 0...result.count - 1 {
                      let result2 = AppUtils.getInstance().objects(NotificationModel.self).filter("productid =  '\(result[index]._id!)' ")
              
                if(result2.count==0)
                {
                 
                    let notification = NotificationModel()
                    notification._id = objectId()
                    notification.content = result[index].namechanged! + " đã hết hạn vào hôm nay"
                    notification.type = 0
                    notification.create_at = calendar.date(byAdding: .hour, value: AppUtils.timezone, to: Date())!.timeIntervalSince1970*1000
                    notification.productid = result[index]._id
                    notification.image = result[index].imagechanged
                    try! AppUtils.getInstance().write {
                        AppUtils.getInstance().add(notification, update: true)
                    }
                    let data:[String: NotificationModel] = ["notification": notification]
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notification_update"), object: nil,
                                                    userInfo: data)
                }
                else{
                
                    
                    try! AppUtils.getInstance().write {
                        result2[0].content = result[index].namechanged! + " đã hết hạn vào hôm nay"
                        result2[0].type = 0
                        result2[0].create_at = calendar.date(byAdding: .hour, value: AppUtils.timezone, to: Date())!.timeIntervalSince1970*1000
                        result2[0].productid = result[index]._id
                        result2[0].image = result[index].imagechanged
                        AppUtils.getInstance().add( result2[0], update: true)
                    }
                    let data:[String: NotificationModel] = ["notification":  result2[0]]
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notification_update"), object: nil,
                                                    userInfo: data)
                }
               
                
                
            }
        }
        
        
        
    }
    static func objectId() -> String {
        let time = String(Int(NSDate().timeIntervalSince1970), radix: 16, uppercase: false)
        let machine = String(arc4random_uniform(900000) + 100000, radix: 16, uppercase: false)
        let pid =  String(arc4random_uniform(9000) + 1000, radix: 16, uppercase: false)
        let counter =  String(arc4random_uniform(90000) + 100000, radix: 16, uppercase: false)
         let counter2 =  String(arc4random_uniform(900) + 10, radix: 16, uppercase: false)
        return time + machine + pid + counter + counter2
    }
    static func loadEvents() -> Int {
        
         let   result = AppUtils.getInstance().objects(Product.self).filter("expiretime < \(calendar.date(byAdding: .hour, value: 0, to:AppUtils.getStartLocalDate(date: AppUtils.calendar.date(byAdding: .day, value: 3, to:AppUtils.getStartLocalDate(date: Date()))!))!.timeIntervalSince1970*1000)AND expiretime >= \(calendar.date(byAdding: .hour, value: 0, to:AppUtils.getStartLocalDate(date: Date()))!.timeIntervalSince1970*1000)").sorted(byKeyPath: "expiretime", ascending: false)
     
//        let eventStore = EKEventStore()
//        let ekcalendar = eventStore.calendar(withIdentifier: AppUtils.getCalendarID())
//
//        let eventsPredicate = eventStore.predicateForEvents(withStart: calendar.date(byAdding: .hour, value: -timezone, to:startDate)!, end: calendar.date(byAdding: .hour, value: -timezone, to:endDate)!, calendars: [ekcalendar!])
//
//        numberofevent =  eventStore.events(matching: eventsPredicate).count
//        for index in 0...eventStore.events(matching: eventsPredicate).count - 1 {
//        print(eventStore.events(matching: eventsPredicate)[index].location)
//            print(eventStore.events(matching: eventsPredicate)[index].endDate)
//        }
        return result.count
    }
    
    static func loadEventsExpired() -> Int {
       
        
        let   result = AppUtils.getInstance().objects(Product.self).filter("expiretime < \(calendar.date(byAdding: .hour, value: 0, to:AppUtils.getStartLocalDate(date: Date()))!.timeIntervalSince1970*1000) AND expiretime >= \(calendar.date(byAdding: .hour, value: 0, to:AppUtils.calendar.date(byAdding: .day, value: -1, to:AppUtils.getStartLocalDate(date: Date()))!)!.timeIntervalSince1970*1000)").sorted(byKeyPath: "expiretime", ascending: false)
      
//        let eventStore = EKEventStore()
//        let ekcalendar = eventStore.calendar(withIdentifier: AppUtils.getCalendarID())
//
//        let eventsPredicate = eventStore.predicateForEvents(withStart: calendar.date(byAdding: .hour, value: -timezone, to:startDate)!, end: calendar.date(byAdding: .hour, value: -timezone, to:endDate)!, calendars: [ekcalendar!])
//
//        numberofevent =  eventStore.events(matching: eventsPredicate).count
//        for index in 0...eventStore.events(matching: eventsPredicate).count - 1 {
//            print(eventStore.events(matching: eventsPredicate)[index].location)
//            print(eventStore.events(matching: eventsPredicate)[index].endDate)
//            if(eventStore.events(matching: eventsPredicate)[index].endDate > calendar.date(byAdding: .hour, value: -timezone, to:endDate)!)
//            {
//                numberofevent = numberofevent - 1
//            }
//        }
        return result.count
    }
    static func removeScheduleRepeat(hour : Int , minute : Int){
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["\(hour):\(minute)"])
    }
    static func setScheduleRepeat(hour : Int , minute : Int){

         UNUserNotificationCenter.current().scheduleNotificationRepeat(hour: hour, minute: minute)
    }
    static func setScheduleMidNight(){

        UNUserNotificationCenter.current().scheduleNotificationMidNight()
      
    }
    static func removeAllNotification(){
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
 
        
    }
    static func reloadNotification(){
        let listnotification = AppUtils.getInstance().objects(User.self).first!.setting?.frame_time
        if((listnotification?.count)!>0)
        {
            for index in 0...(listnotification?.count)! - 1 {
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                dateFormatter.dateFormat = "HH:mm"
                let date = dateFormatter.date(from: (listnotification![index]))
                let hour = AppUtils.calendar.component(.hour, from:  date! )
                let minute = AppUtils.calendar.component(.minute, from: date!)
                UNUserNotificationCenter.current().scheduleNotificationRepeat(hour: hour, minute: minute)
            }
        }
       
        
    }
    static func addProduct(product : Product,complete: @escaping DownloadComplete){
        try! AppUtils.getInstance().write {
            
            
        
            
            AppUtils.getInstance().add(product, update: true)
//            let date = Date(timeIntervalSince1970: product.expiretime/1000)
//
//            let endDate =    calendar.date(byAdding: .hour, value: -timezone, to:AppUtils.getEndLocalDate(date: date))!
//
//            let startDate =
//                calendar.date(byAdding: .hour, value: -timezone, to:calendar.date(byAdding: .day, value: -product.daybefore, to:AppUtils.getStartLocalDate(date: date))!)!
//
//            let event = EKEvent(eventStore: eventStore)
//            event.isAllDay = true
//            event.location = product._id
//            event.title = product.namechanged
//            event.startDate = startDate
//            event.endDate = endDate
//            event.notes = product.des
//            event.calendar = eventStore.calendar(withIdentifier: AppUtils.getCalendarID())
//            event.url = URL(string: product.imagechanged!)
//            do {
//
//                try eventStore.save(event, span: .thisEvent, commit: true)
//
//            } catch {
//                print("Error occurred exist")
//            }
            if(product.expiretime < calendar.date(byAdding: .hour, value: 0, to:AppUtils.getStartLocalDate(date: Date()))!.timeIntervalSince1970*1000 && product.expiretime >= calendar.date(byAdding: .hour, value: 0, to:AppUtils.calendar.date(byAdding: .day, value: -1, to:AppUtils.getStartLocalDate(date: Date()))!)!.timeIntervalSince1970*1000 ){
                print("het han roi may")
                let notification = NotificationModel()
                notification.content = "\(product.namechanged!) đã hết hạn vào hôm nay"
                notification.type = 0
                notification.create_at = NSDate().timeIntervalSince1970
                notification.productid = product._id
                notification.image = product.imagechanged
                AppUtils.getInstance().add(notification, update: true)
            }
            AppUtils.reloadNotification()
            complete()
            
        }
    }
    static func getAllProduct() -> List<Product>{
        
        let converted = AppUtils.getInstance().objects(Product.self).sorted(byKeyPath: "expiretime", ascending: false).reduce(List<Product>()) { (list, element) -> List<Product> in
            list.append(element)
            return list
        }
       return converted
    }
//    static func setReminder(from product : List<Product>,viewcontroller : UIViewController,complete: @escaping DownloadComplete) {
////        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
////
////            guard error == nil else {
////                //Display Error.. Handle Error.. etc..
////                return
////            }
////
////            if granted {
////                //Do stuff here..
////
////            }
////            else
////            {
////                let alertController = UIAlertController (title: "Cảnh báo", message: "Ứng dụng không thể thông báo hạn sử dụng nếu không được cấp quyền truy cập thông báo", preferredStyle: .alert)
////
////                let settingsAction = UIAlertAction(title: "Đi đến cài đặt", style: .default) { (_) -> Void in
////                    guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
////                        return
////                    }
////                    if UIApplication.shared.canOpenURL(settingsUrl) {
////                        UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
////
////                        })
////                    }
////                }
////                alertController.addAction(settingsAction)
////                DispatchQueue.main.sync {
////                    viewcontroller.present(alertController, animated: true, completion: nil)
////                }
////
////            }
////
////
////
////        }
////
//        //Register for RemoteNotifications. Your Remote Notifications can display alerts now :)
//
//        eventStore.requestAccess(to: EKEntityType.event) { (granted, error) -> Void in
//
//            if let e = error {
//                print("Error \(e.localizedDescription)")
//
//            }
//
//            if granted {
//
//
//                print("access granted")
//                let calendars = eventStore.calendars(for: .event)
//                var isCreate :Bool = false
//                for calendar in calendars {
//                    if calendar.title == "HSD" {
//                        isCreate = true
//                        print("da tao")
//                        if(AppUtils.getCalendarID()==""||AppUtils.getFirstTime()==true)
//                        {
//                            do{
//                                try  eventStore.removeCalendar(calendar, commit: true)
//                                let newCalendar = EKCalendar(for :EKEntityType.event, eventStore:eventStore)
//
//                                newCalendar.title="HSD"
//                                newCalendar.source = eventStore.defaultCalendarForNewEvents?.source
//                                AppUtils.storeCalendarID(id: newCalendar.calendarIdentifier)
//                                try eventStore.saveCalendar(newCalendar, commit:true)
//
//
//
//                            }
//                            catch
//                            {
//                                print("error")
//                            }
//                        }
//
//
//
//                    }
//                }
//                if(isCreate == false)
//                {
//                    print("chua tao")
//                    let newCalendar = EKCalendar(for :EKEntityType.event, eventStore:eventStore)
//
//                    newCalendar.title="HSD"
//                    newCalendar.source = eventStore.defaultCalendarForNewEvents?.source
//                    AppUtils.storeCalendarID(id: newCalendar.calendarIdentifier)
//                    do{
//
//                        try eventStore.saveCalendar(newCalendar, commit:true)
//                    }
//                    catch {
//                        print("error")
//                    }
//                }
//
//
//
//
//
//                if(product.count > 0)
//                {
//
//
//
//                    for index in 0...product.count - 1 {
//
//                        let date = Date(timeIntervalSince1970: product[index].expiretime/1000)
//
//                        let endDate =    calendar.date(byAdding: .hour, value: -timezone, to:AppUtils.getEndLocalDate(date: date))!
//
//                        let startDate =
//                            calendar.date(byAdding: .hour, value: -timezone, to:calendar.date(byAdding: .day, value: -product[index].daybefore, to:AppUtils.getStartLocalDate(date: date))!)!
//                        var eventAlreadyExists = false
//                        let event = EKEvent(eventStore: eventStore)
//                        event.isAllDay = true
//                        event.location = product[index]._id
//                        event.title = product[index].namechanged
//                        event.startDate = startDate
//                        event.endDate = endDate
//                        event.notes = product[index].des
//                        event.calendar = eventStore.calendar(withIdentifier: AppUtils.getCalendarID())
//                        event.url = URL(string: product[index].imagechanged!)
//
//                        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
//                        let existingEvents = eventStore.events(matching: predicate)
//                        for singleEvent in existingEvents {
//                            if singleEvent.location == product[index]._id {
//                                eventAlreadyExists = true
//                                singleEvent.title = product[index].namechanged
//                                singleEvent.startDate = startDate
//                                singleEvent.endDate = endDate
//                                singleEvent.notes = product[index].des
//                                singleEvent.calendar = eventStore.calendar(withIdentifier: AppUtils.getCalendarID())
//                                do {
//
//                                    try eventStore.save(singleEvent, span: .thisEvent, commit: true)
//
//                                } catch {
//                                    print("Error occurred exist")
//                                }
//                                break
//                            }
//                        }
//                        if !eventAlreadyExists {
//                            do {
//                                try eventStore.save(event, span: .thisEvent)
//                                //                                self.notificationCenter!.scheduleNotification(at: date, product: product[index],hour: 6,minute: 0)
//
//
//                            } catch {
//                                print("Error occurred")
//                            }
//                        }
//                    }
//                }
//
//                complete()
//            }
//            else
//            {
//                let alertController = UIAlertController (title: "Cảnh báo", message: "Ứng dụng không thể hoạt động nếu không được cấp quyền truy cập lịch", preferredStyle: .alert)
//
//                let settingsAction = UIAlertAction(title: "Đi đến cài đặt", style: .default) { (_) -> Void in
//                    guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
//                        return
//                    }
//                    if UIApplication.shared.canOpenURL(settingsUrl) {
//                        UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
//
//                        })
//                    }
//                }
//                alertController.addAction(settingsAction)
//                DispatchQueue.main.sync {
//                    viewcontroller.present(alertController, animated: true, completion: nil)
//                }
//            }
//        }
//    }
   
    @objc func runcode(){
        
    }
    //=========================================================================  store local setting
    static func storeUser(user : User){
        let preferences = UserDefaults.standard
        
        
        
        preferences.set(user._id, forKey: "iduser")
        preferences.set(user.phone, forKey: "phone")
        preferences.set(user.type_login, forKey: "type_login")
        preferences.set(user.create_at, forKey: "create_at")
        preferences.synchronize()
        
    }
    static func storeTest(image : String,name : String){
        let preferences = UserDefaults.standard
        
        
        
        preferences.set(image, forKey: "avatar")
        preferences.set(name, forKey: "name")
      
        preferences.synchronize()
        
    }
    static func getAvatar() -> String {
        let preferences = UserDefaults.standard
        
        
        if preferences.object(forKey: "avatar") == nil {
            return ""
            //  Doesn't exist
        } else {
            return preferences.string(forKey: "avatar")!
        }
    }
    static func getName() -> String {
        let preferences = UserDefaults.standard
        
        
        if preferences.object(forKey: "name") == nil {
            return ""
            //  Doesn't exist
        } else {
            return preferences.string(forKey: "name")!
        }
    }
    static func getUserID() -> String {
        let preferences = UserDefaults.standard
        
        
        if preferences.object(forKey: "iduser") == nil {
            return ""
            //  Doesn't exist
        } else {
            return preferences.string(forKey: "iduser")!
        }
    }
    static func storeCalendarID(id : String){
        let preferences = UserDefaults.standard
        
        
        
        preferences.set(id, forKey: "calendarid")
        
        preferences.synchronize()
        
    }
    static func getCalendarID() -> String {
        let preferences = UserDefaults.standard
        
        
        if preferences.object(forKey: "calendarid") == nil {
            return ""
            //  Doesn't exist
        } else {
            return preferences.string(forKey: "calendarid")!
        }
    }
    static func storeFirstTime(first : Bool){
        let preferences = UserDefaults.standard
        
        
        
        preferences.set(first, forKey: "firsttime")
        
        preferences.synchronize()
        
    }
    static func getFirstTime() -> Bool {
        let preferences = UserDefaults.standard
        
        
        
        return preferences.bool(forKey: "firsttime")
        
    }
    static func getUser() -> User {
        let result = AppUtils.getInstance().objects(User.self)
        return result.first!
    }
    //========================================================================== image function
    static func resize(image: UIImage) -> UIImage {
        var actualHeight = Float(image.size.height)
        var actualWidth = Float(image.size.width)
        let maxHeight: Float = 800
        let maxWidth: Float = 1000
        var imgRatio: Float = actualWidth / actualHeight
        let maxRatio: Float = maxWidth / maxHeight
        let compressionQuality: Float = 0.5
        //50 percent compression
        if actualHeight > maxHeight || actualWidth > maxWidth {
            if imgRatio < maxRatio {
                //adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight
                actualWidth = imgRatio * actualWidth
                actualHeight = maxHeight
            }
            else if imgRatio > maxRatio {
                //adjust height according to maxWidth
                imgRatio = maxWidth / actualWidth
                actualHeight = imgRatio * actualHeight
                actualWidth = maxWidth
            }
            else {
                actualHeight = maxHeight
                actualWidth = maxWidth
            }
        }
        let rect = CGRect(x: 0.0, y: 0.0, width: CGFloat(actualWidth), height: CGFloat(actualHeight))
        UIGraphicsBeginImageContext(rect.size)
        image.draw(in: rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        let imageData = UIImageJPEGRepresentation(img!, CGFloat(compressionQuality))
        UIGraphicsEndImageContext()
        return UIImage(data: imageData!) ?? UIImage()
    }
    //===================================================================   network function
    func isConnectedToInternet() ->Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}
