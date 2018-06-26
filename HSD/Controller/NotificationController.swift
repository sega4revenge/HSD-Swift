//
//  NotificationController.swift
//  HSD
//
//  Created by Tô Tử Siêu on 6/1/18.
//  Copyright © 2018 Finger. All rights reserved.
//

import UIKit
import RealmSwift
class NotificationController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    var notification_list = [NotificationModel]()
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notification_list.count
    }
    
    @IBOutlet weak var UI_noti_no: UIView!
    @IBOutlet weak var UI_tableview: UITableView!
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
     
        
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notification_cell") as! NotificationViewCell
       
        cell.UI_content.text = notification_list[indexPath.row].content
       
        cell.UI_time.text = AppUtils.dayDifference(from : notification_list[indexPath.row].create_at)
        if(notification_list[indexPath.row].image == nil || notification_list[indexPath.row].image == ""){
            cell.UI_image.image = UIImage(named: "barcode")
        }
        else{
           
            cell.UI_image.kf.setImage(with: URL(string: AppUtils.BASE_URL_IMAGE + notification_list[indexPath.row].image!))
        }
     
        return cell
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
     
        NotificationCenter.default.addObserver(self, selector: #selector(updateNotification(_:)), name: NSNotification.Name(rawValue: "notification_update"), object: nil)
         reload()
        UI_tableview.delegate = self
        UI_tableview.dataSource = self
        // Do any additional setup after loading the view.
    }
    @objc func updateNotification(_ notification: NSNotification) {
//        if let foo = notification_list.first(where: {$0.productid == (notification.userInfo!["notification"] as? Notification)?.productid}) {
//            // do something with foo
//        } else {
//
//        }
        print("dang them")
      
        var vitri : Int
        if let index = notification_list.index(where: {$0.productid == (notification.userInfo!["notification"] as? NotificationModel)!.productid}) {
            print(index)
            vitri = index
             notification_list.remove(at: vitri)
            self.notification_list.insert((notification.userInfo!["notification"] as? NotificationModel)!, at: 0)
            self.UI_tableview.beginUpdates()
            
              self.UI_tableview.deleteRows(at: [IndexPath.init(row: vitri, section: 0)], with: .automatic)
            self.UI_tableview.insertRows(at: [IndexPath.init(row: 0, section: 0)], with: .automatic)
            self.UI_tableview.endUpdates()
        }
     
        
        
    }
    func reload(){
        let result = AppUtils.getInstance().objects(NotificationModel.self).sorted(byKeyPath: "create_at", ascending: false)
        print(result.count)
        if(result.count>0)
        {
                UI_noti_no.isHidden = true
                 UI_tableview.isHidden = false
           
            notification_list = result.toArray(ofType: NotificationModel.self)
            
        }
        else{
              UI_noti_no.isHidden = false
           UI_tableview.isHidden = true
        }
        UI_tableview.reloadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationItem.title = "Thông báo"
        
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
