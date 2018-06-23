//
//  ProfileController.swift
//  HSD
//
//  Created by Tô Tử Siêu on 6/1/18.
//  Copyright © 2018 Finger. All rights reserved.
//

import UIKit
import GoogleSignIn
class ProfileController: UIViewController {
    var setting : User?
    @IBOutlet weak var UI_frametime: UIView!
    @IBOutlet weak var UI_name: UIStackView!
    @IBOutlet weak var UI_type: UILabel!
    @IBOutlet weak var UI_phone: UILabel!
    @IBOutlet weak var UI_logout: UIView!
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
       
        // Do any additional setup after loading the view.
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
       UI_phone.text = UserDefaults.standard.string(forKey: "phone")
        
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
