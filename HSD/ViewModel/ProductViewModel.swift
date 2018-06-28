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
    var tempupdateimage : String?
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
    func uploadImage(image : UIImage,barcode : String,productid : String,complete: @escaping DownloadComplete) {
      
      print("bat dau upload")
        if let data = UIImageJPEGRepresentation(image,1) {
            
            // You can change your image name here, i use NSURL image and convert into string
            let fileName = barcode + "-" + String(NSDate().timeIntervalSince1970)
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                multipartFormData.append(data, withName: "image", fileName: fileName, mimeType: "image/jpeg")
                  multipartFormData.append("\(productid)".data(using: .utf8)!, withName: "id_product")
            }, to:AppUtils.BASE_URL + "product/upload_image_product"){
                
             (result) in
               
                
                switch result {
              
                case .success(let upload, _, _):
                    
                    
                    
                    
                    upload.uploadProgress(closure: { (Progress) in
                        
                        //                        print("Upload Progress: \(Progress.fractionCompleted)")
                        
                    })
                    
                    upload.responseObject { (response: DataResponse<Response>) in
                        print(response)
                        if let err = response.result.error as? URLError, err.code  == URLError.Code.notConnectedToInternet
                        {
                            
                            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                            // choose a name for your image
                            
                            // create the destination file url to save your image
                            let fileURL = documentsDirectory.appendingPathComponent(fileName)
                            
                            // get your UIImage jpeg data representation and check if the destination file url already exists
                            if let data = UIImageJPEGRepresentation(image, 1.0),
                                !FileManager.default.fileExists(atPath: fileURL.path) {
                                do {
                                    
                                    // writes the image data to disk
                                    try data.write(to: fileURL)
                    
                        
                                    try! AppUtils.getInstance().write {
                                             let url = "\(AppUtils.BASE_URL)product/upload_image_product"
                                        let producttemp =  AppUtils.getInstance().objects(Product.self).filter(" _id = '\(productid)' ")
                                        
                                       
                                        producttemp[0].imagechanged = fileURL.absoluteString
                                        self.tempupdateimage = fileURL.absoluteString
                                        let a = RequestObject()
                                        a.url = url
                                        a._id = url + productid + barcode
                                        print("\(url + productid + barcode)")
                                        print(fileURL.absoluteString)
                                        let parameters = [
                                            "image" : fileName,
                                            "idproduct" : productid
                                            
                                        ]
                                        if  UserDefaults.standard.object(forKey: "listrequest") == nil {
                                            var b = Dictionary<String, Parameters>()
                                            b.updateValue(parameters, forKey: "\(url + productid + barcode)")
                                            UserDefaults.standard.set(b, forKey: "listrequest")
                                            UserDefaults.standard.synchronize()
                                            //  Doesn't exist
                                        }
                                        else{
                                            var b = UserDefaults.standard.object(forKey: "listrequest") as! Dictionary<String, Parameters>
                                            
                                            b.updateValue(parameters, forKey: "\(url + productid + barcode)")
                                            UserDefaults.standard.set(b, forKey: "listrequest")
                                            UserDefaults.standard.synchronize()
                                        }
                                        AppUtils.getInstance().add(a, update: true)
                                      
                                        
                                        
                                        
                                    }
                                    
                               
                                    
                                  
                                } catch {
                                    print("error saving file:", error)
                                }
                            }
                            
                              complete()
                        }
                       else  if(response.response?.statusCode == 200)
                        {
                            print("thanh cong")
                            try! AppUtils.getInstance().write {
                                let producttemp =  AppUtils.getInstance().objects(Product.self).filter(" _id = '\(productid)' ")
                             
                                
                                producttemp[0].imagechanged = response.result.value?.product?.imagechanged
                                self.tempupdateimage =  response.result.value?.product?.imagechanged
                               print("dfgfdhdh")
                           
                            }
                            complete()
                        }
                    }
                    
                case .failure(let encodingError):
                    
                      print(encodingError)
                   
                    //self.delegate?.showFailAlert()
                   
                }
            }
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
            
            complete()
        }
        
        
    }
}
