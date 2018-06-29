//
//  ViewController.swift
//  HSD
//
//  Created by Tô Tử Siêu on 5/30/18.
//  Copyright © 2018 Finger. All rights reserved.
//


import FacebookCore
import FacebookLogin
import UIKit

import Firebase
import RealmSwift
import GoogleSignIn
class LoginController: UIViewController,UITextFieldDelegate, GIDSignInUIDelegate,GIDSignInDelegate {
    let alertController = UIAlertController(title: nil, message: "Đang đăng nhập\n\n", preferredStyle: .alert)
    
    
    
    let spinnerIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
  
    var shadowLayer: CAShapeLayer!
    @IBOutlet weak var tf_phone: UITextField!
    @IBOutlet weak var tf_password: UITextField!
    @IBOutlet weak var UI_login: UIView!
    @IBAction func btn_facebook_login(_ sender: CornerButton) {

        let loginManager = LoginManager()
        loginManager.logIn(readPermissions : [ .publicProfile ], viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                self.alertController.dismiss(animated: true, completion: nil)
                let toast = Toast(text: "Kết nối đến server bị lỗi", duration: Delay.short)
                toast.show()
                print(error)
            case .cancelled:
                self.alertController.dismiss(animated: true, completion: nil)
                let toast = Toast(text: "Người dùng từ chối đăng nhập", duration: Delay.short)
                toast.show()
                print("User cancelled login.")
            case .success( _, _, _):
                let connection = GraphRequestConnection()
                connection.add(GraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email"], accessToken: AccessToken.current, httpMethod: GraphRequestHTTPMethod(rawValue: "GET")!, apiVersion: "2.8")) { httpResponse, result in
                    
                    switch result {
                    case .success(let response):
                        self.prepareDialog()
                        self.loginsocial(phone: response.dictionaryValue?["id"] as! String , type: AppUtils.FACEBOOK)
                        
                    case .failed(let error):
                        self.alertController.dismiss(animated: true, completion: nil)
                        let toast = Toast(text: "Kết nối đến server bị lỗi", duration: Delay.short)
                        toast.show()
                        print("Graph Request Failed: \(error)")
                    }
                }
                
                connection.start()
            }
        }
    }
    
    @IBAction func btn_google_login(_ sender: CornerButton) {
        GIDSignIn.sharedInstance().signIn()
    }
    func prepareDialog(){
        self.alertController.message = "Đang đăng nhập\n\n"
        spinnerIndicator.center = CGPoint(x: 135.0, y: 65.5)
        spinnerIndicator.color = UIColor.black
        spinnerIndicator.startAnimating()
        
        alertController.view.addSubview(spinnerIndicator)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    func getData(user : User){
        self.alertController.message = "Đăng nhập thành công\n\n"
        AppUtils.storeUser(user: user)

//        AppUtils.setReminder(from: user.listgroup[0].listproduct,viewcontroller: self)
//            {
//
//
//
//            }
    
        
        try! AppUtils.getInstance().write {
            
            AppUtils.getInstance().deleteAll()
            
            AppUtils.getInstance().add(user, update: true)
            
       
            AppUtils.removeAllNotification()
             self.alertController.dismiss(animated: true, completion: {() -> Void in     self.performSegue(withIdentifier: "goto_main", sender: self)
               
           
       
       
            
            
        })
        }
        
    }
   
    func loginsocial(phone : String,type : Int)
    {
        
        AppUtils.getUserViewModel().registerUser(phone : phone , password: "",type: type){
            
            switch (AppUtils.getUserViewModel().response?.status){
            case 200 :
                self.getData(user: (AppUtils.getUserViewModel().response?.user)!)
                  
            case nil :
                ToastCenter.default.cancelAll()
                let toast = Toast(text: "Kết nối đến server bị lỗi", duration: Delay.short)
                self.alertController.dismiss(animated: true, completion: nil)
                toast.show()
            default :
                ToastCenter.default.cancelAll()
                let toast = Toast(text: "Đăng ký không thành công", duration: Delay.short)
                self.alertController.dismiss(animated: true, completion: nil)
                toast.show()
                
                
            }
        }
    }
    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
                     withError error: Error!) {
        if (error == nil) {
            // Perform any operations on signed in user here.
            //            let userId = user.userID                  // For client-side use only!
            //            let idToken = user.authentication.idToken // Safe to send to the server
            //            let fullName = user.profile.name
            //            let givenName = user.profile.givenName
            //            let familyName = user.profile.familyName
            //            let email = user.profile.email
            AppUtils.storeTest(image:(user.profile.imageURL(withDimension: 120)).absoluteString, name: user.profile.name)
            prepareDialog()
            self.loginsocial(phone: user.userID , type: AppUtils.GOOGLE)
            // ...
        } else {
            print("\(error)")
        }
    }
    func sign(_ signIn: GIDSignIn!,
              present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!,
              dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func btn_Login(_ sender: Any) {
        if(tf_phone.text == "")
        {
            
            tf_phone.layer.borderWidth = 2
            tf_phone.layer.borderColor = UIColor.red.cgColor
            ToastCenter.default.cancelAll()
            let toast = Toast(text: "Vui lòng nhập số điện thoại", duration: Delay.short)
            
            toast.show()
        }
        else if(tf_password.text == "")
        {
            tf_password.layer.borderWidth = 2
            tf_password.layer.borderColor = UIColor.red.cgColor
            ToastCenter.default.cancelAll()
            let toast = Toast(text: "Vui lòng nhập mật khẩu", duration: Delay.short)
            
            toast.show()
        }
        else{
            prepareDialog()
            AppUtils.getUserViewModel().loginUser(phone : tf_phone.text! , password: tf_password.text!){
                switch (AppUtils.getUserViewModel().response?.status){
                case 200 :  self.getData(user: (AppUtils.getUserViewModel().response?.user)!)
                    
                case nil :
                    ToastCenter.default.cancelAll()
                    let toast = Toast(text: "Kết nối đến server bị lỗi", duration: Delay.short)
                       self.alertController.dismiss(animated: true, completion: nil)
                    toast.show()
                default :
                    ToastCenter.default.cancelAll()
                    let toast = Toast(text: "Sai tên đăng nhập hoặc mật khẩu", duration: Delay.short)
                       self.alertController.dismiss(animated: true, completion: nil)
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
        case tf_password:
            tf_password.layer.borderWidth =  0.25
            tf_password.layer.borderColor = UIColor.lightGray.cgColor
        default: break
            
            
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
      
        
            GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
            GIDSignIn.sharedInstance().delegate=self
            GIDSignIn.sharedInstance().uiDelegate=self
            var a = NSCalendar.current
            a.timeZone = TimeZone(abbreviation: "GMT")!
            
            print(a.startOfDay(for: Date()))
            configUI()
        
      
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configUI(){
        
        tf_phone.delegate = self
        tf_password.delegate = self
        
        // MARK: Apply Validation on textfield.
        
        
        
        
        
        
        self.navigationController?.isNavigationBarHidden = true
        self.UI_login.layer.cornerRadius = 20
        
        // border
        
        
        // drop shadow
        self.UI_login.layer.shadowColor = UIColor.lightGray.cgColor
        self.UI_login.layer.shadowOpacity = 0.8
        self.UI_login.layer.shadowRadius = 2.5
        self.UI_login.layer.shadowOffset = CGSize.zero
        // Do any additional setup after loading the view.
        
        
        ToastView.appearance().font = .boldSystemFont(ofSize: 14)
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
    
    
}

