//
//  ProductViewModel.swift
//  HSD
//
//  Created by Tô Tử Siêu on 6/4/18.
//  Copyright © 2018 Finger. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper
import RealmSwift
typealias DownloadComplete = () -> ()
class ProductViewModel: NSObject {
    
    var _productList = List<Product>()
    var _producttype : ProductType?
    var barcode_request : Request?=nil
    func getAllProductInGroup(iduser : String,complete: @escaping DownloadComplete) {
        let parameters = [
            "iduser" : iduser
        ]
        Alamofire.request("\(AppUtils.BASE_URL)product/getAllProductInGroup", method: .post, parameters: parameters,encoding: JSONEncoding.default, headers: nil).responseObject { (response: DataResponse<Response>) in
            
            let repo = response.result.value
            self._productList.append(objectsIn : repo!.listproduct)
            
            print(self._productList.count)
            
            
            complete()
        }
        
        
    }
    func searchBarcode(barcode : String,complete: @escaping DownloadComplete) {
        let parameters = [
            "barcode" : barcode
        ]
        
        barcode_request?.cancel()
        barcode_request = Alamofire.request("\(AppUtils.BASE_URL)product/checkbarcode", method: .post, parameters: parameters,encoding: JSONEncoding.default, headers: nil).responseObject { (response: DataResponse<Response>) in
            let repo = response.result.value
            if(repo?.producttype != nil)
            {
                self._producttype = repo?.producttype
                
            }
            print("okokoo")
            complete()
        }
        
        
    }
    func deleteProduct(idproduct : String,iduser : String,complete: @escaping DownloadComplete) {
        print("bat dau xoa")
        let parameters = [
            "id_product" : idproduct,
            "id_user" : iduser
        ]
        
        
        Alamofire.request("\(AppUtils.BASE_URL)product/delete_product", method: .post, parameters: parameters,encoding: JSONEncoding.default, headers: nil).responseObject { (response: DataResponse<Response>) in
            if let err = response.result.error as? URLError, err.code  == URLError.Code.notConnectedToInternet
            {
                let url = "\(AppUtils.BASE_URL)product/delete_product"
                
                try! AppUtils.getInstance().write {
                    let a = RequestObject()
                    a.url = url
                    a._id = url + idproduct
                    
                    if  UserDefaults.standard.object(forKey: "listrequest") == nil {
                        var b = Dictionary<String, Parameters>()
                        b.updateValue(parameters, forKey: "\(url + idproduct)")
                        UserDefaults.standard.set(b, forKey: "listrequest")
                        //  Doesn't exist
                    }
                    else{
                        var b = UserDefaults.standard.object(forKey: "listrequest") as! Dictionary<String, Parameters>
                        
                        b.updateValue(parameters, forKey: "\(url + idproduct)")
                        UserDefaults.standard.set(b, forKey: "listrequest")
                    }
                    AppUtils.getInstance().add(a, update: true)
                    
                    
                    
                }
            }
            else
            {
                // Other errors
            }
            print(response)
            complete()
        }
        
        
    }
    
    func updateProduct(product : Product,complete: @escaping DownloadComplete) {
        print("bat dau xoa")
        let parameters = [
            "id_product" : product._id!,
            "nameproduct" : product.namechanged!,
            "hsd_ex" : product.expiretime,
              "description" : product.des!,
                "daybefore" : product.daybefore
            ] as [String : Any]
        
        
        Alamofire.request("\(AppUtils.BASE_URL)product/update-infomation", method: .post, parameters: parameters,encoding: JSONEncoding.default, headers: nil).responseObject { (response: DataResponse<Response>) in
            if let err = response.result.error as? URLError, err.code  == URLError.Code.notConnectedToInternet
            {
                let url = "\(AppUtils.BASE_URL)product/update-infomation"
                
                try! AppUtils.getInstance().write {
                    let a = RequestObject()
                    a.url = url
                    a._id = url + product._id!
                    
                    if  UserDefaults.standard.object(forKey: "listrequest") == nil {
                        var b = Dictionary<String, Parameters>()
                        b.updateValue(parameters, forKey: "\(url + product._id!)")
                        UserDefaults.standard.set(b, forKey: "listrequest")
                        //  Doesn't exist
                    }
                    else{
                        var b = UserDefaults.standard.object(forKey: "listrequest") as! Dictionary<String, Parameters>
                        
                        b.updateValue(parameters, forKey: "\(url + product._id!)")
                        UserDefaults.standard.set(b, forKey: "listrequest")
                    }
                    AppUtils.getInstance().add(a, update: true)
                    
                    
                    
                }
            }
            else
            {
                // Other errors
            }
            print(response)
            complete()
        }
        
        
    }
}
