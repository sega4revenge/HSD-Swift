//
//  aViewController.swift
//  HSD
//
//  Created by Tô Tử Siêu on 6/4/18.
//  Copyright © 2018 Finger. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper
class UserViewModel: NSObject {
    //Create apiClient property that we can use to call in our API Call.
    //This apiClient property is marked as an @IBOutlet so that we can instantiate it from the storyboard.  I mark this with a bang operator (!) since I know it will not be nil since the storyboard will be injecting it.
    var user : User = User()
    var response : Response?
    var status : Int?
    
    
    func downloadUser(id: String,complete: @escaping DownloadComplete) {
        
        Alamofire.request("http://45.77.36.109:8070/api/v1/data/"+id, method: .get,encoding: JSONEncoding.default, headers: nil).responseObject { (response: DataResponse<User>) in
            
            let repo = response.result.value
            self.user = repo!
            print(response.result.value!)
            complete()
        }
        
        
    }
    func registerUser(phone : String,password : String,type : Int,complete : @escaping DownloadComplete){
        let parameters : Parameters = [
            "phone" : phone,
            "password": password,
             "type": type
            ]
        
        Alamofire.request(AppUtils.BASE_URL + "register-android", method: .post, parameters: parameters,encoding: JSONEncoding.default, headers: nil).responseObject { (response: DataResponse<Response>) in
            
            self.response = response.result.value
       
            complete()
        }
    }
    func loginUser(phone : String,password : String,complete : @escaping DownloadComplete){
        let parameters = [
            "phone" : phone,
            "password": password
        ]
        
        Alamofire.request(AppUtils.BASE_URL + "login-android", method: .post, parameters: parameters,encoding: JSONEncoding.default, headers: nil).responseObject { (response: DataResponse<Response>) in
            self.response = response.result.value
            complete()
        }
    }
  

    
    
    
}
