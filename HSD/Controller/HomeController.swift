//
//  HomeController.swift
//  HSD
//
//  Created by Tô Tử S iêu on 6/1/18.
//  Copyright © 2018 Finger. All rights reserved.
//

import UIKit
import EventKit
import Kingfisher
import Alamofire

class HomeController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchResultsUpdating,UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        
    }

    var eventStore = EKEventStore()
    var calendars:Array<EKCalendar> = []
    @IBOutlet weak var UI_Search: UIView!
    let namesection = ["Hết hạn","Sắp hết hạn","An Toàn"]
    var itemsection =  [[Product](),[Product](),[Product]()]
    let searchcontroller = UISearchController(searchResultsController: nil)
    @IBOutlet weak var UI_table: UITableView!
    @IBOutlet weak var UI_message: UIView!
    var product : Product?=nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
  
        AppUtils.setScheduleMidNight()
        configUI()
        loadData()
        self.searchcontroller.searchResultsUpdater = self
        self.searchcontroller.dimsBackgroundDuringPresentation = false
        self.searchcontroller.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        self.UI_Search.addSubview(self.searchcontroller.searchBar)
          
        for ob : UIView  in ((self.searchcontroller.searchBar.subviews[0] )).subviews {
            
            if let z = ob as? UIButton {
                let btn: UIButton = z
                btn.setTitleColor(UIColor.black, for: UIControlState.normal)
            }
        }
        searchcontroller.searchBar.placeholder = "Tìm kiếm sản phẩm"
       
        
        UI_table.delegate = self
        UI_table.dataSource = self
        // Do any additional setup after loading the view.
    }
    @objc func runcode(){
        print("123")
    }
    func loadData()  {
    
        itemsection[0].removeAll()
         itemsection[1].removeAll()
         itemsection[2].removeAll()
      
      
        
        let result = AppUtils.getInstance().objects(Product.self).sorted(byKeyPath: "expiretime", ascending: false)
        if(result.count>0)
        {
            for index in 0...result.count - 1 {
            
       
                if AppUtils.countDay(from: result[index].expiretime) < 0
                {
                    itemsection[0].insert(result[index], at: 0)
                }
                    
                else if AppUtils.countDay(from: result[index].expiretime) >= 0 && AppUtils.countDay(from: result[index].expiretime) <= result[index].daybefore
                {
                    itemsection[1].insert(result[index], at: 0)
                }
                    
                else
                {
                    itemsection[2].insert(result[index], at: 0)
                }
                
            }
        }
       
    }
    
    public func reloadData()  {
       loadData()
        self.UI_table.reloadData()
    }
    //================================================================================ table view
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
      
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            // delete item at indexPath
            
            
            AppUtils.getProductViewModel().deleteProduct(idproduct: self.itemsection[indexPath.section][indexPath.row]._id!, iduser: AppUtils.getUserID()){
                
            }
            
            try! AppUtils.getInstance().write {
                let objectsToDelete = AppUtils.getInstance().objects(Product.self).filter(" _id = '\(self.itemsection[indexPath.section][indexPath.row]._id!)'")
                print("da lay")
                AppUtils.getInstance().delete(objectsToDelete)
                
            }
         
        
            self.itemsection[indexPath.section].remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        
            // and then just remove the set with
          
            
        }
        
        let share = UITableViewRowAction(style: .default, title: "Share") { (action, indexPath) in
            // share item at indexPath
            print("I want to share: \(self.itemsection[indexPath.section].remove(at: indexPath.row))")
        }
        
        share.backgroundColor = UIColor.lightGray
        
        return [delete, share]
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print(itemsection[indexPath.section][indexPath.row].productname!)
        RunLoop.main.cancelPerform(#selector(runcode), target: self, argument: nil)
        product = AppUtils.getInstance().objects(Product.self).filter("_id = '\(itemsection[indexPath.section][indexPath.row]._id!)'").first
        self.performSegue(withIdentifier: "goto_detail", sender: self)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsection[section].count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.namesection[section]
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ProductTableViewCell
        cell.UI_name.text = itemsection[indexPath.section][indexPath.row].namechanged
        cell.UI_time.text = AppUtils.dayDifference(from :Double(itemsection[indexPath.section][indexPath.row].expiretime))
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.UI_barcode.text = itemsection[indexPath.section][indexPath.row].barcode
        cell.UI_image.kf.setImage(with: URL(string: AppUtils.BASE_URL_IMAGE + self.itemsection[indexPath.section][indexPath.row].imagechanged!))
        cell.UI_image.contentMode = .scaleAspectFill
         cell.UI_image.clipsToBounds = true
        cell.UI_warning.layer.masksToBounds = true
        cell.UI_warning.layer.cornerRadius = 10.0
        cell.UI_warning.textColor = UIColor.white
        switch indexPath.section {
        case 0:
            cell.UI_warning.backgroundColor = UIColor.red
            cell.UI_warning.text = "Cảnh báo"
            cell.UI_name.textColor = UIColor.red
        case 1:
            cell.UI_warning.backgroundColor = UIColor.init(red: 254/255, green: 193/255, blue: 7/255, alpha: 1)
            cell.UI_warning.text = "Sắp hết hạn"
            cell.UI_name.textColor = UIColor.init(red: 254/255, green: 193/255, blue: 7/255, alpha: 1)
        default:
            cell.UI_warning.backgroundColor = UIColor.init(red: 54/255, green: 156/255, blue: 18/255, alpha: 1)
            cell.UI_warning.text = "An toàn"
            cell.UI_name.textColor = UIColor.init(red: 54/255, green: 156/255, blue: 18/255, alpha: 1)
        }
        return cell
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10.0
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var height : CGFloat = 42.0
        switch section {
        case 0:
            if(itemsection[0].count==0)
            {
                height = 0.0
            }
            
            
        case 1:
            if(itemsection[1].count==0)
            {
                height = 0.0
            }
        
        default:
            if(itemsection[2].count==0)
            {
                height = 0.0
            }
        }
        return height
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.namesection.count
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.white
        let header = view as! UITableViewHeaderFooterView
        
        let frame = header.frame
//        let button = UIButton(frame: CGRect(x: frame.width-200, y: 0,width: 200,height: 40))
//
//        button.tag = section
//        button.setTitle("Xóa tất cả",  for: UIControlState.normal)
//        button.setTitleColor(UIColor.init(red: 254/255, green: 193/255, blue: 7/255, alpha: 1),for: UIControlState.normal)
//        button.addTarget(self,action:#selector(buttonClicked),for:.touchUpInside)
//        button.tag = section
//        header.addSubview(button)

//        let headerTapGesture = UITapGestureRecognizer()
//        headerTapGesture.addTarget(self, action: #selector(HomeController.sectionHeaderWasTouched(_:)))
//        header.addGestureRecognizer(headerTapGesture)
        switch section {
        case 0:
            header.textLabel?.textColor = UIColor.red
         
         
        case 1:
            header.textLabel?.textColor = UIColor.init(red: 254/255, green: 193/255, blue: 7/255, alpha: 1)
        default:
            header.textLabel?.textColor = UIColor.init(red: 54/255, green: 156/255, blue: 18/255, alpha: 1)
        }
        
        
    }
//    func sectionHeaderWasTouched(_ sender: UITapGestureRecognizer) {
//        let headerView = sender.view as! UITableViewHeaderFooterView
//        let section    = headerView.tag
//        let eImageView = headerView.viewWithTag(kHeaderSectionTag + section) as? UIImageView
//
//        if (self.expandedSectionHeaderNumber == -1) {
//            self.expandedSectionHeaderNumber = section
//            tableViewExpandSection(section, imageView: eImageView!)
//        } else {
//            if (self.expandedSectionHeaderNumber == section) {
//                tableViewCollapeSection(section, imageView: eImageView!)
//            } else {
//                let cImageView = self.view.viewWithTag(kHeaderSectionTag + self.expandedSectionHeaderNumber) as? UIImageView
//                tableViewCollapeSection(self.expandedSectionHeaderNumber, imageView: cImageView!)
//                tableViewExpandSection(section, imageView: eImageView!)
//            }
//        }
//    }
    @objc func buttonClicked(sender:UIButton)
    {
        if(sender.tag == 1){
            
            print("buttonClicked")
        }
        
    }
    
    
    //================================================================================ parent view
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationItem.title = "Trang chủ"
      
    }
    func configUI(){
   
        self.UI_message.layer.cornerRadius = 20
        // border

        // drop shadow
        self.UI_message.layer.shadowColor = UIColor.lightGray.cgColor
        self.UI_message.layer.shadowOpacity = 0.8
        self.UI_message.layer.shadowRadius = 2.5
        self.UI_message.layer.shadowOffset = CGSize.zero
        // Do any additional setup after loading the view.
    }
   
    //=================================================================================== segue pass data
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("bat dau")
        if let destinationViewController = segue.destination as? ProductDetailViewController {
            destinationViewController.product = product
        }
    }
    
}
