//
//  ProductDetailViewController.swift
//  HSD
//
//  Created by Tô Tử Siêu on 6/3/18.
//  Copyright © 2018 Finger. All rights reserved.
//

import UIKit
import Photos
import Kingfisher

class ProductDetailViewController: UIViewController,UIAlertViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    var product : Product? = nil
    
    var previewtime = Date()
    @IBOutlet weak var UI_productname: UILabel!


  
    @IBOutlet weak var UI_productimage: UIImageView!

    @IBOutlet weak var UI_warning: UILabel!
    
    @IBOutlet weak var UI_topview: UIView!
    @IBOutlet weak var UI_timeline: ISTimeline!
    @IBOutlet weak var UI_expiretime: UILabel!
    @IBOutlet weak var UI_description: UILabel!
    
    @IBOutlet weak var UI_barcode: UILabel!

    
 
    var picker:UIImagePickerController?=UIImagePickerController()

 


    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        
        
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    func updateUI(){
   
        
     
        previewtime =  Date(timeIntervalSince1970: (product?.expiretime)!/1000)
        picker!.delegate=self
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        UI_productimage.isUserInteractionEnabled = true
        UI_productimage.addGestureRecognizer(tapGestureRecognizer)
        
   


        UI_productname.text = product?.namechanged
    
    
        
        UI_description.text = product?.des
        
     
        
        
        UI_barcode.text = (product?.producttype_id?.barcode)!
        let processor = ResizingImageProcessor(referenceSize: CGSize(width: 300, height: 300)) >> RoundCornerImageProcessor(cornerRadius: 50)
        UI_productimage.kf.setImage(with: URL(string: AppUtils.BASE_URL_IMAGE + (product?.imagechanged)!),options: [.transition(.fade(1)),.processor(processor)], completionHandler: { image, error, cacheType, imageURL in
            
            
        })
       
        UI_productimage.contentMode = .scaleAspectFill
        UI_productimage.clipsToBounds = true
        let myPoints : [ISPoint]
        if AppUtils.countDay(from: (product?.expiretime)!) < 0
        {
          
            UI_warning.text = "Hết hạn"
            UI_expiretime.textColor = UIColor.red
              UI_warning.textColor = UIColor.red
            UI_expiretime.text = AppUtils.dayDifference(from : (product?.expiretime)!)
            myPoints = [
                ISPoint(title: AppUtils.dayString(from: (product?.createtime)!), description: "Sản phẩm này đang trong thời hạn an toàn", pointColor: UIColor.red, lineColor: UIColor.red,textColor : UIColor.black, touchUpInside: nil, fill: false),
                ISPoint(title: AppUtils.dayString(from: ((product?.expiretime)! - Double((product?.daybefore)! * 86400000))), description: "Sản phẩm này sắp hết hạn sử dụng . Chú ý sử dụng trước thời hạn", pointColor: UIColor.red, lineColor: UIColor.red,textColor : UIColor.black, touchUpInside: nil, fill: false),
                ISPoint(title: AppUtils.dayString(from: (product?.expiretime)!), description: "Sản phẩm này đã hết hạn sử dụng", pointColor: UIColor.red, lineColor: UIColor.red,textColor : UIColor.red, touchUpInside: nil, fill: false),
                
                ]
            
        }
            
        else if AppUtils.countDay(from: (product?.expiretime)!) >= 0 && AppUtils.countDay(from: (product?.expiretime)!) <= (product?.daybefore)!
        {
                 UI_warning.text = "Cảnh báo"
            UI_expiretime.textColor = UIColor.init(red: 254/255, green: 193/255, blue: 7/255, alpha: 1)
            UI_warning.textColor = UIColor.init(red: 254/255, green: 193/255, blue: 7/255, alpha: 1)
            UI_expiretime.text = AppUtils.dayDifference(from : (product?.expiretime)!)
            myPoints = [
                ISPoint(title: AppUtils.dayString(from: (product?.createtime)!), description: "Sản phẩm này đang trong thời hạn an toàn", pointColor:  UIColor.init(red: 254/255, green: 193/255, blue: 7/255, alpha: 1), lineColor: UIColor.init(red: 254/255, green: 193/255, blue: 7/255, alpha: 1),textColor : UIColor.black, touchUpInside: nil, fill: false),
                ISPoint(title: AppUtils.dayString(from: ((product?.expiretime)! - Double((product?.daybefore)! * 86400000))), description: "Sản phẩm này sắp hết hạn sử dụng . Chú ý sử dụng trước thời hạn", pointColor: UIColor.init(red: 254/255, green: 193/255, blue: 7/255, alpha: 1), lineColor: UIColor.black,textColor : UIColor.init(red: 254/255, green: 193/255, blue: 7/255, alpha: 1), touchUpInside: nil, fill: false),
                ISPoint(title: AppUtils.dayString(from: (product?.expiretime)!), description: "Sản phẩm này đã hết hạn sử dụng", pointColor: UIColor.black, lineColor: UIColor.black,textColor : UIColor.black, touchUpInside: nil, fill: false),
                
                ]
        }
            
        else
        {
                   UI_warning.text = "An toàn"
            UI_expiretime.textColor = UIColor.init(red: 54/255, green: 156/255, blue: 18/255, alpha: 1)
            UI_warning.textColor = UIColor.init(red: 54/255, green: 156/255, blue: 18/255, alpha: 1)
            UI_expiretime.text = AppUtils.dayDifference(from : (product?.expiretime)!)
            myPoints = [
                ISPoint(title: AppUtils.dayString(from: (product?.createtime)!), description: "Sản phẩm này đang trong thời hạn an toàn", pointColor: UIColor.init(red: 54/255, green: 156/255, blue: 18/255, alpha: 1), lineColor: UIColor.black,textColor : UIColor.init(red: 54/255, green: 156/255, blue: 18/255, alpha: 1), touchUpInside: nil, fill: false),
                ISPoint(title: AppUtils.dayString(from: ((product?.expiretime)! - Double((product?.daybefore)! * 86400000))), description: "Sản phẩm này sắp hết hạn sử dụng . Chú ý sử dụng trước thời hạn", pointColor: UIColor.black, lineColor: UIColor.black,textColor : UIColor.black, touchUpInside: nil, fill: false),
                ISPoint(title: AppUtils.dayString(from: (product?.expiretime)!), description: "Sản phẩm này đã hết hạn sử dụng", pointColor: UIColor.black, lineColor: UIColor.black,textColor : UIColor.black, touchUpInside: nil, fill: false),
                
                ]
        }
      
        UI_timeline.contentInset = UIEdgeInsetsMake(20.0, 20.0, 20.0, 20.0)
        UI_timeline.points = myPoints
        
    }
    @objc func editTapped()
    {
       self.performSegue(withIdentifier: "goto_edit", sender: self)
        
    }
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        print("chon anh")
        
        let alert:UIAlertController=UIAlertController(title: "Chọn hình ảnh", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let cameraAction = UIAlertAction(title: "Chụp ảnh", style: UIAlertActionStyle.default)
        {
            UIAlertAction in
            self.openCamera()
            
        }
        let gallaryAction = UIAlertAction(title: "Thư viện", style: UIAlertActionStyle.default)
        {
            UIAlertAction in
            self.openGallary()
        }
        let cancelAction = UIAlertAction(title: "Hủy bỏ", style: UIAlertActionStyle.cancel)
        {
            UIAlertAction in
            
        }
        
        // Add the actions
        picker?.delegate = self
        alert.addAction(cameraAction)
        alert.addAction(gallaryAction)
        alert.addAction(cancelAction)
        // Present the controller
        if UIDevice.current.userInterfaceIdiom == .phone
        {
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            
        }
    }
    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera))
        {
            picker!.sourceType = UIImagePickerControllerSourceType.camera
            self .present(picker!, animated: true, completion: nil)
        }
        else
        {
            openGallary()
        }
    }
    func openGallary()
    {
        self.authorizeToAlbum { (authorized) in
            if authorized == true {
                self.picker!.sourceType = UIImagePickerControllerSourceType.photoLibrary
                
                self.present(self.picker!, animated: true, completion: nil)
                
                
                
            }
        }
        
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            UI_productimage.image = AppUtils.resize(image: image)
        }
        
        picker.dismiss(animated: true, completion: nil);
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        picker.dismiss(animated: true, completion: nil);
    }
    
    func authorizeToAlbum(completion:@escaping (Bool)->Void) {
        
        if PHPhotoLibrary.authorizationStatus() != .authorized {
            NSLog("Will request authorization")
            PHPhotoLibrary.requestAuthorization({ (status) in
                if status == .authorized {
                    DispatchQueue.main.async(execute: {
                        completion(true)
                    })
                } else {
                    DispatchQueue.main.async(execute: {
                        completion(false)
                    })
                }
            })
            
        } else {
            DispatchQueue.main.async(execute: {
                completion(true)
            })
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sửa", style: .done, target: self, action: #selector(editTapped))
     
       
 
    }
    override func viewDidDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
      
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("bat dau")
        if let destinationViewController = segue.destination as? EditViewController {
            destinationViewController.product = product!
        }
    }
       @IBAction func unwindToDetail(segue: UIStoryboardSegue) {}
}
