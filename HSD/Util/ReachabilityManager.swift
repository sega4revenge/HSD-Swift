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
import RealmSwift
// 1. Importing the Library
class ReachabilityManager: NSObject {
    var documentsUrl: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
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
              
                let myGroup = DispatchGroup()
          
                let realm = try! Realm()
                for index in 0...c.count - 1 {
                    myGroup.enter()
               
                    let result = realm.objects(RequestObject.self).filter(" _id = '\(c[index])' ")
                    if(result.count>0)
                    {
                        print("bat dau o day")
                        let url = result[0].url
                        
                        if(url == AppUtils.BASE_URL + "product/upload_image_product"){
                            let tempurl = b[c[index]]?["image"] as! String
                            
                            let fileURL = self.documentsUrl.appendingPathComponent(tempurl)
                            let imageData = try! Data(contentsOf: fileURL)
                            
                            Alamofire.upload(multipartFormData: { (multipartFormData) in
                                multipartFormData.append(imageData, withName: "image", fileName: tempurl, mimeType: "image/jpeg")
                                
                                
                                
                                multipartFormData.append("\(b[c[index]]!["idproduct"]!)".data(using: .utf8)!, withName: "id_product")
                                
                            }, to:AppUtils.BASE_URL + "product/upload_image_product") {
                                
                             (result2) in
                                
                                switch result2 {
                                case .success(let upload, _, _):
                                    
                                    
                                    
                                    
                                    upload.uploadProgress(closure: { (Progress) in
                                        
                                        //                        print("Upload Progress: \(Progress.fractionCompleted)")
                                        
                                    })
                                    
                                    upload.responseObject { (response: DataResponse<Response>) in
                                        if(response.response?.statusCode == 200)
                                        {
                                            let realm = try! Realm()
                                            try! FileManager.default.removeItem(at : fileURL)
                                            try! realm.write {
                                                let producttemp =  realm.objects(Product.self).filter(" _id = '\(b[c[index]]!["idproduct"]!)' ")
                                                if(producttemp.count != 0)
                                                {
                                                    producttemp[0].imagechanged = response.result.value?.product?.imagechanged
                                                    realm.delete(realm.objects(RequestObject.self).filter(" _id = '\(c[index])' "))
                                                }
                                             
                                            }
                                            
                                            
                                            
                                            
                                            b.remove(at: b.index(forKey: c[index])!)
                                            
                                            myGroup.leave()
                                            
                                            
                                        }
                                        
                                        if let JSON = response.result.value {
                                            print("JSON: \(JSON)")
                                        }
                                    }
                                    
                                case .failure(let encodingError):
                                    
                                    //self.delegate?.showFailAlert()
                                    print(encodingError)
                                }
                            }
                        }
                        else
                        {
                            Alamofire.request(url! , method: .post, parameters: b[c[index]] ,encoding: JSONEncoding.default, headers: nil).responseJSON { response in
                                if(response.response?.statusCode == 200)
                                {
                                    let realm = try! Realm()
                                    
                                    try! realm.write {
                                        
                                        realm.delete(realm.objects(RequestObject.self).filter(" _id = '\(c[index])' "))
                                    }
                                    
                                    
                                    b.remove(at: b.index(forKey: c[index])!)
                                    myGroup.leave()
                                    
                                }
                                else
                                {
                                    
                                }
                            }
                        }
                    }
                  
                     myGroup.wait()
                 
                }
                
                myGroup.notify(queue: .main) {
                   
                    if(b.count == 0)
                    {
                        print("da het request")
                        UserDefaults.standard.removeObject(forKey: "listrequest")
                    }
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
