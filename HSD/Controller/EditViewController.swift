//
//  EditViewController.swift
//  HSD
//
//  Created by Tô Tử Siêu on 6/25/18.
//  Copyright © 2018 Finger. All rights reserved.
//

import UIKit
import Photos
import Kingfisher
import RealmSwift
class EditViewController: UIViewController,UITextFieldDelegate,UIAlertViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextViewDelegate {
    var product = Product()
    var isUpdateImage : Bool = false
    let alertController : UIAlertController? = nil
    @IBOutlet weak var UI_productimage: UIImageView!
    @IBOutlet weak var UI_productname: UITextField!
    @IBOutlet weak var UI_expiredtime: UITextField!
    @IBOutlet weak var UI_daybefore: UITextField!
    @IBOutlet weak var UI_description: UITextView!
    @IBOutlet weak var UI_barcode: UILabel!
    let processor = ResizingImageProcessor(referenceSize: CGSize(width: 300, height: 300)) >> RoundCornerImageProcessor(cornerRadius: 50)
    @IBAction func btn_confirm(_ sender: CornerButton) {
        
        if(isUpdateImage == true)
        {
            
            AppUtils.getProductViewModel().uploadImage(image: UI_productimage.image!, barcode: (product.producttype_id?.barcode!)!, productid: product._id!)
            {
              
               
                self.updateinformation()
           
            }
        }
        else{
           
            updateinformation()
        }
    
       
    }
    func updateinformation(){
     
        
        
        
            let realm = try! Realm()
            try! realm.write {
                if(isUpdateImage == true)
                {
                       product.imagechanged =  AppUtils.getProductViewModel().tempupdateimage
                }
               
                product.namechanged = UI_productname.text
                product.expiretime = timetemp
                product.daybefore = Int(UI_daybefore.text!)!
                product.des = UI_description.text
                realm.add(product, update: true)
            }
        
            
        
        AppUtils.getProductViewModel().updateProduct(product: product){
            
          self.performSegue(withIdentifier: "unwindToDetail", sender: self)
        }
    }
    var timetemp : Double = 0.0
    var picker:UIImagePickerController?=UIImagePickerController()
    override func viewDidLoad() {
        super.viewDidLoad()
        picker!.delegate=self
        timepicker(textfield: UI_expiredtime)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        UI_productimage.isUserInteractionEnabled = true
        UI_productimage.addGestureRecognizer(tapGestureRecognizer)
        // Do any additional setup after loading the view.
        UI_productname.delegate = self
        UI_description.delegate = self
        UI_description.layer.cornerRadius = 5
        UI_description.layer.borderWidth =  0.25
        UI_description.layer.borderColor = UIColor.lightGray.cgColor
        UI_description.text = "Mô tả chi tiết sản phẩm"
        UI_description.textColor = UIColor.lightGray
        UI_productimage.kf.base.layer.cornerRadius = 20
        UI_productimage.kf.base.layer.masksToBounds = true
        timetemp = product.expiretime
        configUI()
        
    }
    func configUI(){
        UI_productname.text = product.namechanged
        
        
        
        UI_description.text = product.des
        UI_daybefore.text = String(product.daybefore)
        UI_expiredtime.text = AppUtils.dayString(from: (product.expiretime))
        
        
        UI_barcode.text = (product.producttype_id?.barcode)!
      
        UI_productimage.kf.setImage(with: URL(string: AppUtils.BASE_URL_IMAGE + (product.imagechanged)!),options: [.transition(.fade(1)),.processor(processor)], completionHandler: { image, error, cacheType, imageURL in
            
            
        })
    
        UI_productimage.contentMode = .scaleAspectFill
        UI_productimage.clipsToBounds = true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillDisappear(_ animated: Bool) {
        alertController?.dismiss(animated: true, completion: nil)
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
        
        datePicker.addTarget(self, action: #selector(EditViewController.datePickerValueChanged(sender:)), for: UIControlEvents.valueChanged)
        
        textfield.inputView = datePicker
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 40))
        
        toolbar.barStyle = UIBarStyle.blackTranslucent
        
        toolbar.tintColor = UIColor.white
        
        let todayButton = UIBarButtonItem(title: "Hiện tại", style: UIBarButtonItemStyle.plain, target: self, action: #selector(EditViewController.todayPressed(sender:)))
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(EditViewController.donePressed(sender:)))
        
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
    @objc func datePickerValueChanged(sender:UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = DateFormatter.Style.medium
        
        dateFormatter.timeStyle = DateFormatter.Style.none
        let calendar = Calendar.current
        
        let year = calendar.component(.year, from: sender.date)
        let month = calendar.component(.month, from: sender.date)
        let day = calendar.component(.day, from: sender.date)
        UI_expiredtime.text = "\(day)-\(month)-\(year)"
        
        timetemp = calendar.date(byAdding: .hour, value: AppUtils.timezone, to: sender.date)!.timeIntervalSince1970 * 1000
     
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
        
        timetemp = calendar.date(byAdding: .hour, value: AppUtils.timezone, to: Date())!.timeIntervalSince1970 * 1000
        
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
            isUpdateImage = true
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
    override open func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      
        if let destinationViewController = segue.destination as? ProductDetailViewController {
            let data:[String: Product] = ["date": product]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ReloadReceive"), object: nil, userInfo: data)
           
            destinationViewController.product = product
            destinationViewController.updateUI()
        }
    }
}
