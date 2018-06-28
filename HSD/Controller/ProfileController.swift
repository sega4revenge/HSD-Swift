//
//  ProfileController.swift
//  HSD
//
//  Created by Tô Tử Siêu on 6/1/18.
//  Copyright © 2018 Finger. All rights reserved.
//

import UIKit
import GoogleSignIn
import Kingfisher
class ProfileController: UIViewController {
    var setting : User?
    @IBOutlet weak var UI_frametime: UIView!
    @IBOutlet weak var UI_avatar: UIImageView!
    @IBOutlet weak var UI_type: UILabel!
    @IBOutlet weak var UI_username: UILabel!
    
    @IBOutlet weak var UI_view_notification: UIView!
    @IBOutlet weak var UI_phone: UILabel!
    @IBOutlet weak var UI_product_warning: UILabel!
    
    
    @IBOutlet weak var UI_product_safe: UILabel!
    @IBOutlet weak var UI_product_expired: UILabel!
    @IBOutlet weak var UI_logout: UIView!
    @IBOutlet weak var UI_top_view: UIView!
    @IBOutlet weak var UI_bottom_view: UIView!
  
    @IBAction func UI_noti_switch(_ sender: UISwitch) {
        if sender.isOn {
          
            UIView.animate(withDuration: 0.4, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                
                self.UI_frametime.alpha = 1.0
                self.UI_frametime.isHidden = false
                
            })
        } else {
          
            UIView.animate(withDuration: 0.4, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
              
                self.UI_frametime.alpha = 0.0
                self.UI_frametime.isHidden = true
            })
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(timeTapped(tapGestureRecognizer:)))
        UI_view_notification.isUserInteractionEnabled = true
         UI_view_notification.addGestureRecognizer(tapGestureRecognizer)
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadprofile(_:)), name: NSNotification.Name(rawValue: "ReloadProfile"), object: nil)
        // Do any additional setup after loading the view.
    }
    @objc func timeTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
          self.performSegue(withIdentifier: "goto_time", sender: self)
     
    }
    @objc func reloadprofile(_ notification: NSNotification) {
        //        if let foo = notification_list.first(where: {$0.productid == (notification.userInfo!["notification"] as? Notification)?.productid}) {
        //            // do something with foo
        //        } else {
        //
        //        }
       configUI()
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationItem.title = "Tài khoản"
        
    }
    
    func configUI(){
     
        UI_username.text = "Tô Tử Siêu"
       
        let viewcontroller = tabBarController?.viewControllers![0] as! HomeController
        UI_product_expired.text = String(viewcontroller.itemsection[0].count)
        UI_product_warning.text =  String(viewcontroller.itemsection[1].count)
        UI_product_safe.text =  String(viewcontroller.itemsection[2].count)
        UI_top_view.layer.cornerRadius = 10
        UI_bottom_view.layer.cornerRadius = 10
        let processor = RoundCornerImageProcessor(cornerRadius: 40)
        UI_avatar.kf.setImage(with: URL(string: AppUtils.getAvatar()),options: [.transition(.fade(1)),.processor(processor)], completionHandler: { image, error, cacheType, imageURL in
            
            
        })
        UI_username.text = AppUtils.getName()
        UI_logout.isUserInteractionEnabled = true
        UI_logout.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(logout(tapGestureRecognizer:))))
    }
    
    @objc func logout(tapGestureRecognizer: UITapGestureRecognizer)
    {
        GIDSignIn.sharedInstance().signOut()
        try! AppUtils.getInstance().write {
            
            AppUtils.getInstance().deleteAll()
          
        }
        AppUtils.clearCache()
        AppUtils.removeCalendar()
        AppUtils.removeNotification()
        self.navigationController?.isNavigationBarHidden = true
        self.performSegue(withIdentifier: "logout", sender: self)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
