//
//  RegisterController.swift
//  HSD
//
//  Created by Tô Tử Siêu on 5/31/18.
//  Copyright © 2018 Finger. All rights reserved.
//

import UIKit
import Toaster
class RegisterController: UIViewController,UITextFieldDelegate {
    @IBOutlet weak var UI_register: UIView!
    @IBOutlet weak var tf_phone: UITextField!
    @IBOutlet weak var tf_pass: UITextField!
    @IBOutlet weak var tf_repass: UITextField!
    
    
    @IBAction func btn_register(_ sender: CornerButton) {
        if(tf_phone.text == "")
        {
            
            tf_phone.layer.borderWidth = 2
            tf_phone.layer.borderColor = UIColor.red.cgColor
            ToastCenter.default.cancelAll()
            let toast = Toast(text: "Vui lòng nhập số điện thoại", duration: Delay.short)
            
            toast.show()
        }
        else if(tf_pass.text == "")
        {
            tf_phone.layer.borderWidth = 2
            tf_phone.layer.borderColor = UIColor.red.cgColor
            tf_pass.layer.borderWidth = 2
            tf_pass.layer.borderColor = UIColor.red.cgColor
            ToastCenter.default.cancelAll()
            let toast = Toast(text: "Vui lòng nhập mật khẩu", duration: Delay.short)
            
            toast.show()
        }
        else if(tf_pass.text != tf_repass.text)
        {
            tf_pass.layer.borderWidth = 2
            tf_pass.layer.borderColor = UIColor.red.cgColor
            tf_repass.layer.borderWidth = 2
            tf_repass.layer.borderColor = UIColor.red.cgColor
            ToastCenter.default.cancelAll()
            let toast = Toast(text: "Xác nhận mật khẩu không trùng khớp", duration: Delay.short)
            
            toast.show()
        }
        else{
            
            AppUtils.getUserViewModel().registerUser(phone : tf_phone.text! , password: tf_pass.text!,type: AppUtils.NORMAL){
                switch (AppUtils.getUserViewModel().response?.status){
                case 200 :
                
                    AppUtils.storeUser(user: (AppUtils.getUserViewModel().response?.user)!)
                    AppUtils.setReminder(from: (AppUtils.getUserViewModel().response?.user?.listgroup[0].listproduct)!,viewcontroller: self)
                        {
                            
                            
                            
                            
                            
                            try! AppUtils.getInstance().write {
                                
                                AppUtils.getInstance().deleteAll()
                                
                                AppUtils.getInstance().add(AppUtils.getProductViewModel()._productList, update: true)
                                
                                
                                OperationQueue.main.addOperation {
                                    [weak self] in
                                    self?.performSegue(withIdentifier: "goto_main", sender: self)
                                }
                                
                                
                                
                                
                                
                                
                                
                            }
                            
                            
                        }
                     
                        
                        
                    
                    
                    
                case nil :
                    ToastCenter.default.cancelAll()
                    let toast = Toast(text: "Kết nối đến server bị lỗi", duration: Delay.short)
                    
                    toast.show()
                default :
                    ToastCenter.default.cancelAll()
                    let toast = Toast(text: "Đăng ký không thành công", duration: Delay.short)
                    
                    toast.show()
                    
                    
                }
            }
            
            
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case tf_phone:
            tf_phone.layer.borderWidth =  0.25
            tf_phone.layer.borderColor = UIColor.lightGray.cgColor
        case tf_pass:
            tf_pass.layer.borderWidth =  0.25
            tf_pass.layer.borderColor = UIColor.lightGray.cgColor
        case tf_repass:
            tf_repass.layer.borderWidth =  0.25
            tf_repass.layer.borderColor = UIColor.lightGray.cgColor
        default: break
            
            
        }
    }
    
    @IBAction func btn_backtoLogin(_ sender: Any) {
         self.navigationController?.popViewController(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func configUI(){
        self.UI_register.layer.cornerRadius = 20
        
        // border
     
        self.tf_phone.delegate = self
        self.tf_pass.delegate = self
        self.tf_repass.delegate = self
        // drop shadow
        self.UI_register.layer.shadowColor = UIColor.lightGray.cgColor
        self.UI_register.layer.shadowOpacity = 0.8
        self.UI_register.layer.shadowRadius = 2.5
        self.UI_register.layer.shadowOffset = CGSize.zero
        // Do any additional setup after loading the view.
    }

}
