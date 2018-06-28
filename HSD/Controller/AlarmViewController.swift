//
//  AlarmViewController.swift
//  HSD
//
//  Created by Tô Tử Siêu on 6/28/18.
//  Copyright © 2018 Finger. All rights reserved.
//

import UIKit
import RealmSwift
class AlarmViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    var user : User?=nil
    var rowselected : Int = 0
    var alertController = UIAlertController(title: nil, message:nil, preferredStyle: UIAlertControllerStyle.actionSheet)
    @IBOutlet weak var UI_tableview: UITableView!
  
    override func viewDidLoad() {
        super.viewDidLoad()
        user = AppUtils.getInstance().objects(User.self).first!
     
        UI_tableview.delegate = self
        UI_tableview.dataSource = self
        UI_tableview.setEditing(true, animated: true)
        UI_tableview.allowsSelectionDuringEditing = true
        configtimepicker()
        // Do any additional setup after loading the view.
    }
    func configtimepicker(){
        let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 20, width: self.view.frame.size.width, height: 260))
        datePicker.datePickerMode = UIDatePickerMode.time
        datePicker.locale = NSLocale(localeIdentifier: "en_US") as Locale
       
      
        let labelui = [
            NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 17),
            NSAttributedStringKey.foregroundColor : UIColor.black
            ] as [NSAttributedStringKey : Any]
        
        let customTitle = NSMutableAttributedString(string: "Chọn thời gian hiện thông báo\n", attributes:  labelui)
        
        alertController.setValue(customTitle, forKey: "attributedTitle")
        alertController.view.addSubview(datePicker)//add subview
        
        let cancelAction = UIAlertAction(title: "Hủy bỏ", style: UIAlertActionStyle.cancel)
        {
            UIAlertAction in
            
        }
        let confirmAction = UIAlertAction(title: "Xác nhận", style: .default) { (action) in
            
            self.dateSelected(datePicker: datePicker)
            
            
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        
        let height:NSLayoutConstraint = NSLayoutConstraint(item: alertController.view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 400)
        alertController.view.addConstraint(height)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("vao day")
        return (user?.setting!.frame_time.count)! + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          let cell = tableView.dequeueReusableCell(withIdentifier: "timeCell", for: indexPath)
        cell.selectionStyle = UITableViewCellSelectionStyle.default
        if(indexPath.row == (user?.setting?.frame_time.count)! )
        {
                cell.textLabel?.text = "Thêm mốc thời gian"
        }
        else
        {   print(user?.setting?.frame_time[indexPath.row])
            cell.textLabel?.text = convertto12h(time: (user?.setting?.frame_time[indexPath.row])!)
        }
        
        // Configure the cell...
     
        return cell
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
      
        if editingStyle == .delete {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "HH:mm"
            let date = dateFormatter.date(from: (user?.setting?.frame_time[indexPath.row])!)
            let hour = AppUtils.calendar.component(.hour, from:  date! )
            let minute = AppUtils.calendar.component(.minute, from: date!)
            try! AppUtils.getInstance().write {
                user?.setting?.frame_time.remove(at: indexPath.row)
            }
       
          
            AppUtils.removeScheduleRepeat(hour: hour, minute: minute)
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
          self.present(alertController, animated: true, completion: nil)
          
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
       
        if(indexPath.row == (user?.setting?.frame_time.count)! )
        {
             return .insert
        }
        else
        {
             return .delete
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        print(itemsection[indexPath.section][indexPath.row].productname!)
        print(indexPath)
        if(indexPath.row == (user?.setting?.frame_time.count)!  )
        {   print("day roi")
            DispatchQueue.main.async {
                self.rowselected = indexPath.row
                self.present(self.alertController, animated: true, completion: nil)
            }
         
        }
    }
  
    @objc func dateSelected(datePicker:UIDatePicker) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale?
        let time = formatter.string(from: datePicker.date)
       
      
    
        let hour = AppUtils.calendar.component(.hour, from: datePicker.date)
        let minute = AppUtils.calendar.component(.minute, from: datePicker.date)
        AppUtils.setScheduleRepeat(hour: hour, minute: minute)
        print(convertto24h(time: time))
        print(time)
        try! AppUtils.getInstance().write {
            user?.setting?.frame_time.append(convertto24h(time: time))
        }
       
        UI_tableview.insertRows(at: [IndexPath.init(row: rowselected, section: 0)], with: .automatic)
    
        
    }
    override func viewWillAppear(_ animated: Bool) {
            self.navigationController?.isNavigationBarHidden = false
    }
    override open func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
     
    }
    func convertto12h(time : String) -> String{
        var output : String = ""
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "HH:mm"
            if let inDate = dateFormatter.date(from: time) {
            dateFormatter.dateFormat = "hh:mm a"
            let outTime = dateFormatter.string(from:inDate)
                   output =  outTime
            }
            return output
        
    }
    func convertto24h(time : String) -> String{
          var output : String = ""
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "hh:mm a"
        if let inDate = dateFormatter.date(from: time) {
            dateFormatter.dateFormat = "HH:mm"
            let outTime = dateFormatter.string(from:inDate)
            
            
            output =  outTime
        }
        
           return output
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
