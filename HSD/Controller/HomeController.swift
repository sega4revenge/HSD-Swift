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

extension UISearchBar {
    func changeSearchBarColor(color : UIColor) {
        for subView in self.subviews {
            for subSubView in subView.subviews {
                if subSubView.conforms(to: UITextInputTraits.self) {
                    let textField = subSubView as! UITextField
                    textField.backgroundColor = color
                    break
                }
            }
        }
    }
}
class HomeController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchResultsUpdating,UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    var sectionindex : Int = 0
    var rowindex : Int = 0
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var UI_searchbar: UISearchBar!
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
        print(AppUtils.objectId())
        definesPresentationContext = true
      
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadreceived(_:)), name: NSNotification.Name(rawValue: "ReloadReceive"), object: nil)

        
        
        UI_table.delegate = self
        UI_table.dataSource = self
        // Do any additional setup after loading the view.
    }
    @objc func reloadreceived(_ notification: NSNotification) {
        //        if let foo = notification_list.first(where: {$0.productid == (notification.userInfo!["notification"] as? Notification)?.productid}) {
        //            // do something with foo
        //        } else {
        //
        //        }
       reloadData()
        
        
    }
    func loadData()  {
        
        itemsection[0].removeAll()
        itemsection[1].removeAll()
        itemsection[2].removeAll()
        
        
        
        let result = AppUtils.getInstance().objects(Product.self).sorted(byKeyPath: "expiretime", ascending: false)
        if(result.count>0)
        {
            containerView.isHidden = false
            UI_message.isHidden = true
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
        else
        {
            containerView.isHidden = true
            UI_message.isHidden = false
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
        
        let delete = UITableViewRowAction(style: .destructive, title: "Xóa") { (action, indexPath) in
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
        
        
        
        
        return [delete]
    }
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        let shadowView = UIView()
//
//
//
//
//        let gradient = CAGradientLayer()
//        gradient.frame.size = CGSize(width: tableView.bounds.width, height: 5)
//        let stopColor = UIColor.gray.cgColor
//
//        let startColor = UIColor.white.cgColor
//
//
//        gradient.colors = [stopColor,startColor]
//
//
//        gradient.locations = [0.0,0.8]
//
//        shadowView.layer.addSublayer(gradient)
//
//
//        return shadowView
//    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        print(itemsection[indexPath.section][indexPath.row].productname!)
        
        product = AppUtils.getInstance().objects(Product.self).filter("_id = '\(itemsection[indexPath.section][indexPath.row]._id!)'").first
        sectionindex = indexPath.section
        rowindex = indexPath.row
        self.performSegue(withIdentifier: "goto_detail", sender: self)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsection[section].count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.namesection[section]
    }
    override func willAnimateRotation(to toInterfaceOrientation:      UIInterfaceOrientation, duration: TimeInterval)
    {
        self.UI_table.reloadData()
    }
    
  
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ProductTableViewCell
        cell.UI_name.text = itemsection[indexPath.section][indexPath.row].namechanged
        cell.UI_time.text = AppUtils.dayString(from: Double(itemsection[indexPath.section][indexPath.row].expiretime))
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.UI_barcode.text = itemsection[indexPath.section][indexPath.row].producttype_id?.barcode
        let processor = ResizingImageProcessor(referenceSize: CGSize(width: 300, height: 300)) >> RoundCornerImageProcessor(cornerRadius: 50)
        if (self.itemsection[indexPath.section][indexPath.row].imagechanged!.hasPrefix("file:///"))
        {
            print("khong co anh")
            cell.UI_image.kf.setImage(with: URL(string: self.itemsection[indexPath.section][indexPath.row].imagechanged!),options: [.transition(.fade(1)),.processor(processor)], completionHandler: { image, error, cacheType, imageURL in
                
                
            })
        }
        else
        {
        cell.UI_image.kf.setImage(with: URL(string: AppUtils.BASE_URL_IMAGE + self.itemsection[indexPath.section][indexPath.row].imagechanged!),options: [.transition(.fade(1)),.processor(processor)], completionHandler: { image, error, cacheType, imageURL in
           
            
        })
        }
        cell.UI_image.contentMode = .scaleAspectFit
        cell.UI_image.clipsToBounds = true
        cell.UI_expired.text =  AppUtils.dayDifference(from :Double(itemsection[indexPath.section][indexPath.row].expiretime))
        cell.UI_expired.layer.masksToBounds = true
        cell.UI_expired.layer.cornerRadius = 10.0
        cell.UI_expired.textColor = UIColor.white
      
        
        
        switch indexPath.section {
        case 0:
            cell.UI_expired.backgroundColor = UIColor.red
            
            cell.UI_name.textColor = UIColor.red
        case 1:
            cell.UI_expired.backgroundColor = UIColor.init(red: 254/255, green: 193/255, blue: 7/255, alpha: 1)
            
            cell.UI_name.textColor = UIColor.init(red: 254/255, green: 193/255, blue: 7/255, alpha: 1)
        default:
            cell.UI_expired.backgroundColor = UIColor.init(red: 54/255, green: 156/255, blue: 18/255, alpha: 1)
            
            cell.UI_name.textColor = UIColor.init(red: 54/255, green: 156/255, blue: 18/255, alpha: 1)
        }
//        if(indexPath.row == itemsection[indexPath.section].count-1)
//        {
//            DispatchQueue.main.async {
//                let maskPath1 = UIBezierPath(roundedRect:   cell.bounds,
//                                             byRoundingCorners: [.bottomLeft , .bottomRight],
//                                             cornerRadii: CGSize(width: 10, height: 10))
//                let maskLayer1 = CAShapeLayer()
//                maskLayer1.frame = cell.bounds
//                maskLayer1.path = maskPath1.cgPath
//                cell.layer.mask = maskLayer1
////                cell.back_view.layer.borderWidth = 1
////                cell.back_view.layer.cornerRadius = 3
////                cell.back_view.layer.borderColor = UIColor.blue.cgColor
////                cell.back_view.layer.masksToBounds = true
//            }
//
//        }
        return cell
        
    }
  
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 2
    }
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.groupTableViewBackground
        
        
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
//        let path = UIBezierPath(roundedRect:header.bounds,
//                                byRoundingCorners:[.topRight, .topLeft],
//                                cornerRadii: CGSize(width: 10, height:  10))
//
//        let maskLayer = CAShapeLayer()
//
//        maskLayer.path = path.cgPath
//        header.layer.mask = maskLayer
        
        
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
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar .resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar .resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.navigationItem.title = "Trang chủ"
        
    }
    override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
         NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ReloadProfile"), object: nil, userInfo: nil)
    }
    func configUI(){
//
//        containerView.backgroundColor = UIColor.clear
//        containerView.layer.shadowColor = UIColor.darkGray.cgColor
//        containerView.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
//        containerView.layer.shadowOpacity = 0.6
//        containerView.layer.shadowRadius = 5.0
//
//        UI_table.layer.cornerRadius = 10
//        UI_table.layer.masksToBounds = true
      
        UI_searchbar.layer.borderWidth = 1
        UI_searchbar.layer.borderColor = UIColor.white.cgColor
        UI_searchbar.changeSearchBarColor(color: UIColor.groupTableViewBackground)
        self.UI_searchbar.delegate = self
        self.UI_message.layer.cornerRadius = 20
        // border
        let searchBarStyle = UI_searchbar.value(forKey: "searchField") as? UITextField
        searchBarStyle?.clearButtonMode = .whileEditing
        // drop shadow
        self.UI_message.layer.shadowColor = UIColor.lightGray.cgColor
        self.UI_message.layer.shadowOpacity = 0.8
        self.UI_message.layer.shadowRadius = 2.5
        self.UI_message.layer.shadowOffset = CGSize.zero
        // Do any additional setup after loading the view.
    }
    
    //=================================================================================== segue pass data
  
   
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return nil
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("bat dau")
        if let destinationViewController = segue.destination as? ProductDetailViewController {
            destinationViewController.product = product
        }
    }
    
}
