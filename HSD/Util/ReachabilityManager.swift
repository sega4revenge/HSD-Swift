//
//  Reac.swift
//  HSD
//
//  Created by Tô Tử Siêu on 6/18/18.
//  Copyright © 2018 Finger. All rights reserved.
//

import UIKit
import Reachability
import Alamofire
// 1. Importing the Library
class ReachabilityManager: NSObject {
    static  let shared = ReachabilityManager()  // 2. Shared instance
    // 3. Boolean to track network reachability
    var isNetworkAvailable : Bool {
        return reachabilityStatus != Reachability.Connection.none
    }
    // 4. Tracks current NetworkStatus (notReachable, reachableViaWiFi, reachableViaWWAN)
    var reachabilityStatus: Reachability.Connection = Reachability.Connection.none
    // 5. Reachability instance for Network status monitoring
    let reachability = Reachability()!
    @objc  func reachabilityChanged(notification: NSNotification) {
        let reachability = notification.object as! Reachability
        switch reachability.connection {
        case Reachability.Connection.none:
            
            debugPrint("Network became unreachable")
        case Reachability.Connection.wifi:
            
            
            debugPrint("Network reachable through WiFi")
            DispatchQueue.global(qos: .background).async {
                self.syncData()
            }
        case Reachability.Connection.cellular:
            debugPrint("Network reachable through Cellular Data")
           
            
            DispatchQueue.global(qos: .background).async {
                self.syncData()
            }
        }
        
    }
    func syncData(){
        if(UserDefaults.standard.object(forKey: "listrequest") != nil)
        {
              var b = UserDefaults.standard.object(forKey: "listrequest") as! Dictionary<String, Parameters>
            
                var c = Array(b.keys)
            if(c.count != 0){
                print(c)
                for index in 0...c.count - 1 {
                    
                    let result = AppUtils.getInstance().objects(RequestObject.self).filter(" _id = '\(c[index])' ").first
                    
                    Alamofire.request((result?.url)! , method: .post, parameters: b[c[index]] ,encoding: JSONEncoding.default, headers: nil).responseJSON { response in
                        if(response.response?.statusCode == 200)
                        {
                            try! AppUtils.getInstance().write {
                                
                                AppUtils.getInstance().delete(result!)
                                
                            }
                        
                            b.remove(at: b.index(forKey: c[index])!)
                        }
                    }
                }
                if(b.count == 0)
                {
                     UserDefaults.standard.removeObject(forKey: "listrequest")
                }
            }
        }
     
       
        
    }
    func startMonitoring() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.reachabilityChanged),
                                               name:NSNotification.Name.reachabilityChanged,
                                               object: reachability)
        do{
            try reachability.startNotifier()
        } catch {
            debugPrint("Could not start reachability notifier")
        }
    }
}
