//
//  CreateController.swift
//  HSD
//
//  Created by Tô Tử Siêu on 6/1/18.
//  Copyright © 2018 Finger. All rights reserved.
//

import UIKit
import Photos
import Alamofire
import Kingfisher

class CreateController: UIViewController,UITextFieldDelegate,UIAlertViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIPopoverControllerDelegate,UITextViewDelegate {
    var product_temp = Product()
    @IBOutlet weak var UI_barcode: UITextField!
    @IBOutlet weak var UI_description: UITextView!
    @IBOutlet weak var UI_hint: UILabel!
    @IBOutlet weak var UI_productname: UITextField!
    @IBOutlet weak var UI_productimage: UIImageView!
    @IBOutlet weak var UI_topview: UIView!
    @IBOutlet weak var UI_bottomview: UIView!
     let processor = ResizingImageProcessor(referenceSize: CGSize(width: 300, height: 300)) >> RoundCornerImageProcessor(cornerRadius: 50)
    @IBAction func UI_scan_barcode(_ sender: UIButton) {
        //设置扫码区域参数
      
        
     
          self.performSegue(withIdentifier: "show_scanner", sender: self)
        //TODO:待设置框内识别
      
    }
    var dateFormate = Bool()
    @IBOutlet weak var UI_expiredtime: UITextField!
    var picker:UIImagePickerController?=UIImagePickerController()
    var popover:UIPopoverPresentationControllerDelegate?=nil
    var barcode_temp : String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UI_expiredtime.delegate = self
       
  
        picker!.delegate=self
        timepicker(textfield: UI_expiredtime)
        // Do any additional setup after loading the view.
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        UI_productimage.isUserInteractionEnabled = true
        UI_productimage.addGestureRecognizer(tapGestureRecognizer)
          UI_productimage.contentMode = .scaleAspectFill
        UI_barcode.delegate = self
        UI_productname.delegate = self
        UI_description.delegate = self
        UI_description.layer.cornerRadius = 5
        UI_description.layer.borderWidth =  0.25
        UI_description.layer.borderColor = UIColor.lightGray.cgColor
        UI_description.text = "Mô tả chi tiết sản phẩm"
        UI_description.textColor = UIColor.lightGray
        UI_productimage.kf.base.layer.cornerRadius = 20
        UI_productimage.kf.base.layer.masksToBounds = true
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
        }
        return true
    }
    func textField(_ textField: UITextField, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textField.resignFirstResponder()
        }
        return true
    }
   
    func textFieldShouldReturn(_ textField: UITextField) -> Bool // called when 'return' key pressed. return NO to ignore.
    {
        textField.resignFirstResponder()
        return true;
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case UI_barcode:
            UI_barcode.layer.borderWidth =  0.25
            UI_barcode.layer.borderColor = UIColor.lightGray.cgColor
        case UI_productname:
            UI_productname.layer.borderWidth =  0.25
            UI_productname.layer.borderColor = UIColor.lightGray.cgColor
        case UI_expiredtime:
            UI_expiredtime.layer.borderWidth =  0.25
            UI_expiredtime.layer.borderColor = UIColor.lightGray.cgColor
        case UI_description:
            UI_description.layer.borderWidth =  0.25
            UI_description.layer.borderColor = UIColor.lightGray.cgColor
        default: break
            
            
        }
    }
    @IBAction func UI_confirm(_ sender: CornerButton) {
        if(UI_barcode.text == "")
        {
            
            UI_barcode.layer.borderWidth = 2
            UI_barcode.layer.borderColor = UIColor.red.cgColor
            ToastCenter.default.cancelAll()
            let toast = Toast(text: "Vui lòng nhập barcode", duration: Delay.short)
            
            toast.show()
        }
        else if(UI_productname.text == "")
        {
            UI_productname.layer.borderWidth = 2
            UI_productname.layer.borderColor = UIColor.red.cgColor
            ToastCenter.default.cancelAll()
            let toast = Toast(text: "Vui lòng nhập tên sản phẩm", duration: Delay.short)
            
            toast.show()
        }
        else if(UI_expiredtime.text == "")
        {
            UI_expiredtime.layer.borderWidth = 2
            UI_expiredtime.layer.borderColor = UIColor.red.cgColor
            ToastCenter.default.cancelAll()
            let toast = Toast(text: "Vui lòng nhập ngày hết hạn", duration: Delay.short)
            
            toast.show()
        }
        else if(UI_description.textColor == UIColor.lightGray)
        {
            UI_description.layer.borderWidth = 2
            UI_description.layer.borderColor = UIColor.red.cgColor
            ToastCenter.default.cancelAll()
            let toast = Toast(text: "Vui lòng nhập mô tả", duration: Delay.short)
            
            toast.show()
        }
        else{
            product_temp.barcode = UI_barcode.text!
            product_temp.namechanged = UI_productname.text!
            product_temp.des = UI_description.text
            
            if let data = UIImageJPEGRepresentation(UI_productimage.image!,1) {
                let parameters: Parameters = [
                    "barcode" : product_temp.barcode!,
                    "nameproduct" : product_temp.namechanged!,
                    "hsd_ex" : product_temp.expiretime,
                    "detailproduct" : product_temp.des!,
                    "iduser" :    AppUtils.getUserID()
                ]
                
                // You can change your image name here, i use NSURL image and convert into string
                let fileName = UI_barcode.text! + "-" + String(NSDate().timeIntervalSince1970)
                Alamofire.upload(multipartFormData: { (multipartFormData) in
                    multipartFormData.append(data, withName: "image", fileName: fileName, mimeType: "image/jpeg")
                    for (key, value) in parameters {
                        
                        if value is String || value is Int || value is Double {
                            multipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
                        }
                    }
                }, to:AppUtils.BASE_URL + "product/add-product"){
                    
                 (result) in
                    switch result {
                    case .success(let upload, _, _):
                        let alertController = UIAlertController(title: nil, message: "Vui lòng đợi\n\n", preferredStyle: .alert)
                        
                        
                        
                        let spinnerIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
                        
                        spinnerIndicator.center = CGPoint(x: 135.0, y: 65.5)
                        spinnerIndicator.color = UIColor.black
                        spinnerIndicator.startAnimating()
                        
                        alertController.view.addSubview(spinnerIndicator)
                        
                        self.present(alertController, animated: true, completion: nil)
                        
                        
                        
                        
                        upload.uploadProgress(closure: { (Progress) in
                            
                            //                        print("Upload Progress: \(Progress.fractionCompleted)")
                            
                        })
                        
                        upload.responseObject { (response: DataResponse<Response>) in
                            alertController.message = "Thêm sản phẩm thành công"
                            spinnerIndicator.stopAnimating()
                            spinnerIndicator.removeFromSuperview()
                            alertController.addAction(UIAlertAction(title: "Xác nhận", style: .default, handler: self.dismissDialog))
                            
                            
                            //self.delegate?.showSuccessAlert()
                            //                        print(response.request)  // original URL request
                            //                        print(response.response) // URL response
                            //                        print(response.data)     // server data
                            //                        print(response.result)   // result of response serialization
                            //                        self.showSuccesAlert()
                            //self.removeImage("frame", fileExtension: "txt")
                            AppUtils.addProduct(product: response.result.value!.product!){
                                print("ok")
                                let home_controller = self.tabBarController?.viewControllers?.first as! HomeController
                                home_controller.reloadData()
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
        }
      
    }
    func dismissDialog(action: UIAlertAction) {
        //Use action.title
    }
    @IBAction func UI_cancel(_ sender: CornerButton) {
        UI_barcode.text = ""
        UI_description.text = ""
        UI_expiredtime.text = ""
        UI_productname.text = ""
        UI_hint.text = "Sử dụng camera để scan tự động mã barcode hoặc nhập barcode để tìm kiếm"
        UI_productimage.image = UIImage(named:"barcode")
          UI_hint.textColor = UIColor.black
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Mô tả chi tiết sản phẩm"
            textView.textColor = UIColor.lightGray
        }
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
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationItem.title = "Sản phẩm"
        
    }
    @IBAction func UI_barcodeChanged(_ sender: UITextField) {
        barcode_temp = sender.text!
        
        if(sender.text==""){
            self.UI_hint.text = "Sử dụng camera để scan tự động mã barcode hoặc nhập barcode để tìm kiếm"
            self.UI_hint.textColor = UIColor.black
        }
        else{
            AppUtils.getProductViewModel().searchBarcode(barcode:  barcode_temp){
                if(AppUtils.getProductViewModel()._producttype?._id == nil && sender.text != "")
                {
                    
                    self.UI_hint.text = "Không tìm thấy sản phẩm phù hợp với barcode"
                    self.UI_hint.textColor = UIColor.red
                    self.UI_productname.text = ""
                    self.UI_productimage.image = UIImage(named:"barcode")!
                    self.UI_description.text = "Mô tả chi tiết sản phẩm"
                    self.UI_description.textColor = UIColor.lightGray
                }
                else if(sender.text==""){
                    self.UI_hint.text = "Sử dụng camera để scan tự động mã barcode hoặc nhập barcode để tìm kiếm"
                    self.UI_hint.textColor = UIColor.black
                }
                else
                {
                    self.UI_productimage.kf.setImage(with: URL(string: AppUtils.BASE_URL_IMAGE + (AppUtils.getProductViewModel()._producttype?.image!)!))
                    self.UI_productimage.contentMode = .scaleAspectFill
                    self.UI_productimage.clipsToBounds = true
                    self.UI_productname.text = AppUtils.getProductViewModel()._producttype?.name
                    self.UI_hint.text = "Đã tìm thấy sản phẩm phù hợp với barcode"
                    self.UI_hint.textColor = UIColor.green
                    self.UI_description.text = AppUtils.getProductViewModel()._producttype?.des
                    self.UI_description.textColor = UIColor.black
                }
                
                
                
            }
           
        }
        
        
    }
  
    @objc func datePickerValueChanged(sender:UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = DateFormatter.Style.medium
        
        dateFormatter.timeStyle = DateFormatter.Style.none
        let calendar = Calendar.current
        
        let year = calendar.component(.year, from: sender.date)
        let month = calendar.component(.month, from: sender.date)
        let day = calendar.component(.day, from: sender.date)
        UI_expiredtime.text = "\(day)-\(month)-\(year)"
        
        product_temp.expiretime = calendar.date(byAdding: .hour, value: AppUtils.timezone, to: sender.date)!.timeIntervalSince1970 * 1000
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        //1. To make sure that this is applicable to only particular textfield add tag.
        if textField == UI_expiredtime {
            //2. this one helps to make sure that user enters only numeric characters and '-' in fields
            let numbersOnly = CharacterSet(charactersIn: "1234567890-")
            
            let Validate = string.rangeOfCharacter(from: numbersOnly.inverted) == nil ? true : false
            if !Validate {
                return false;
            }
            if range.length + range.location > (textField.text?.count)! {
                return false
            }
            let newLength = (textField.text?.count)! + string.count - range.length
            if newLength == 3 || newLength == 6 {
                let  char = string.cString(using: String.Encoding.utf8)!
                let isBackSpace = strcmp(char, "\\b")
                
                if (isBackSpace == -92) {
                    dateFormate = false;
                }else{
                    dateFormate = true;
                }
                
                if dateFormate {
                    let textContent:String!
                    textContent = textField.text
                    //3.Here we add '-' on overself.
                    let textWithHifen:String = (textContent)! + "-"
                    
                    textField.text = textWithHifen
                    dateFormate = false
                }
            }
            //4. this one helps to make sure only 8 character is added in textfield .(ie: dd-mm-yy)
            return newLength <= 10;
            
        }
        return true
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    func timepicker(textfield : UITextField){
        
        
        let datePicker = UIDatePicker()
        datePicker.locale = NSLocale(localeIdentifier: "vi_VN") as Locale
        datePicker.datePickerMode = UIDatePickerMode.date
        
        datePicker.addTarget(self, action: #selector(CreateController.datePickerValueChanged(sender:)), for: UIControlEvents.valueChanged)
        
        textfield.inputView = datePicker
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 40))
        
        toolbar.barStyle = UIBarStyle.blackTranslucent
        
        toolbar.tintColor = UIColor.white
        
        let todayButton = UIBarButtonItem(title: "Hiện tại", style: UIBarButtonItemStyle.plain, target: self, action: #selector(CreateController.todayPressed(sender:)))
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(CreateController.donePressed(sender:)))
        
        let flexButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width/3, height: 40))
        
        label.font = UIFont.systemFont(ofSize: 14)
        
        label.textColor = UIColor.yellow
        
        label.textAlignment = NSTextAlignment.center
        
        label.text = "Chọn ngày"
        
        let labelButton = UIBarButtonItem(customView: label)
        
        toolbar.setItems([todayButton, flexButton, labelButton, flexButton, doneButton], animated: true)
        
        textfield.inputAccessoryView = toolbar
        
    }
    @objc func donePressed(sender: UIBarButtonItem) {
        
        UI_expiredtime.resignFirstResponder()
        
    }
    
    @objc func todayPressed(sender: UIBarButtonItem) {
        
        let formatter = DateFormatter()
        
        formatter.dateStyle = DateFormatter.Style.medium
        
        formatter.timeStyle = DateFormatter.Style.none
        let calendar = Calendar.current
        
        let year = calendar.component(.year,from: NSDate() as Date)
        let month = calendar.component(.month, from: NSDate() as Date)
        let day = calendar.component(.day, from: NSDate() as Date)
       
        product_temp.expiretime = calendar.date(byAdding: .hour, value: AppUtils.timezone, to: Date())!.timeIntervalSince1970 * 1000
 
        UI_expiredtime.text = "\(day)-\(month)-\(year)"
        UI_expiredtime.resignFirstResponder()
        
        
    }
    @IBAction func clicked(_ sender: UIButton) {
        
        
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
         
             UI_productimage.kf.base.image = AppUtils.resize(image: image)
      
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
      @IBAction func unwindToMenu(segue: UIStoryboardSegue) {}
}

