//
//  ProductDetailViewController.swift
//  HSD
//
//  Created by Tô Tử Siêu on 6/3/18.
//  Copyright © 2018 Finger. All rights reserved.
//

import UIKit

class ProductDetailViewController: UIViewController {
    var product : Product? = nil
    @IBOutlet weak var UI_productname: UILabel!
    @IBOutlet weak var UI_expiretime: UILabel!
    @IBOutlet weak var UI_barcode: UILabel!
    @IBOutlet weak var UI_description: UILabel!
    @IBOutlet weak var UI_productimage: UIImageView!
    @IBOutlet weak var UI_warning_detail: UILabel!
    @IBOutlet weak var UI_fullexpire_day: UILabel!
    
    @IBOutlet weak var UI_fullexpire_time: UILabel!
    @IBOutlet weak var UI_notification_time: UILabel!
    @IBOutlet weak var UI_label_expired: PaddingLabel!
    @IBOutlet weak var UI_label_warning: PaddingLabel!
    @IBOutlet weak var UI_label_safety: PaddingLabel!
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
        UI_productname.text = product?.namechanged
        UI_label_safety.layer.masksToBounds = true
        UI_label_safety.layer.cornerRadius = 15.0
        UI_label_warning.layer.masksToBounds = true
        UI_label_warning.layer.cornerRadius = 15.0
        UI_label_expired.layer.masksToBounds = true
        UI_label_expired.layer.cornerRadius = 15.0
        UI_fullexpire_time.text = AppUtils.dayString(from: (product?.expiretime)!)
      
        UI_description.text = product?.des
   
        UI_notification_time.text = "Thông báo trước \((product?.daybefore)! + 0 ) ngày "
      

        UI_barcode.text = (product?.producttype_id?.barcode)!
        UI_productimage.kf.setImage(with: URL(string: AppUtils.BASE_URL_IMAGE + (product?.imagechanged)!))
        UI_productimage.contentMode = .scaleAspectFill
        UI_productimage.clipsToBounds = true
        
        if AppUtils.countDay(from: (product?.expiretime)!) < 0
        {
            UI_warning_detail.text = "Sản phẩm đã hết hạn. Không nên sử dụng !"
            UI_warning_detail.textColor = UIColor.red
            UI_expiretime.textColor = UIColor.red
            UI_label_expired.backgroundColor = UIColor.red
            UI_expiretime.text = "Hết hạn " + AppUtils.dayDifference(from : (product?.expiretime)!)
        }
            
        else if AppUtils.countDay(from: (product?.expiretime)!) >= 0 && AppUtils.countDay(from: (product?.expiretime)!) <= (product?.daybefore)!
        {
            UI_warning_detail.text = "Sản phẩm sắp hết hạn. Chú ý sử dụng !"
            UI_warning_detail.textColor = UIColor.init(red: 254/255, green: 193/255, blue: 7/255, alpha: 1)
            UI_expiretime.textColor = UIColor.init(red: 254/255, green: 193/255, blue: 7/255, alpha: 1)
            UI_label_warning.backgroundColor = UIColor.init(red: 254/255, green: 193/255, blue: 7/255, alpha: 1)
            UI_expiretime.text = AppUtils.dayDifference(from : (product?.expiretime)!)
        }
            
        else
        {
            UI_warning_detail.text = "Sản phẩm còn hạn sử dụng nhiều. An toàn"
            UI_warning_detail.textColor = UIColor.init(red: 54/255, green: 156/255, blue: 18/255, alpha: 1)
            UI_expiretime.textColor = UIColor.init(red: 54/255, green: 156/255, blue: 18/255, alpha: 1)
            UI_label_safety.backgroundColor = UIColor.init(red: 54/255, green: 156/255, blue: 18/255, alpha: 1)
            UI_expiretime.text = AppUtils.dayDifference(from : (product?.expiretime)!)
        }
        
    }
}
