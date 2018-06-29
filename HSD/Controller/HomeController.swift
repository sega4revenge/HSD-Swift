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
    var filteredData = [Section]()
    var searchstring : String = ""
    var inSearchMode = false
    var sectionindex : Int = 0
    var rowindex : Int = 0
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var UI_searchbar: UISearchBar!
    var eventStore = EKEventStore()
    var calendars:Array<EKCalendar> = []
    @IBOutlet weak var UI_Search: UIView!
  
    var itemsection = [Section]()
 
  
  
    @IBOutlet weak var UI_table: UITableView!
    @IBOutlet weak var UI_message: UIView!
    var product : Product?=nil
    
    @IBAction func UI_button_tocreate(_ sender: CornerButton) {
          switchToDataTab()
    }
   
    func switchToDataTab(){
        Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(switchToDataTabCont), userInfo: nil,repeats: false)
    }
    
    @objc func switchToDataTabCont(){
        tabBarController!.selectedIndex = 1
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        itemsection = [
            Section(name: "Hết hạn", items: []),
            Section(name: "Sắp hết hạn", items: []),
            Section(name: "An Toàn", items: [])
        ]
        filteredData = [
            Section(name: "Hết hạn", items: []),
            Section(name: "Sắp hết hạn", items: []),
            Section(name: "An Toàn", items: [])
        ]
        AppUtils.setScheduleMidNight()
        AppUtils.reloadNotification()
        configUI()
        loadData()
        print(AppUtils.objectId())
        definesPresentationContext = true
        UI_searchbar.delegate = self
        UI_searchbar.returnKeyType = UIReturnKeyType.done
    
        let textFieldInsideSearchBar = UI_searchbar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.darkText
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadreceived(_:)), name: NSNotification.Name(rawValue: "ReloadReceive"), object: nil)

        
      
  
        UI_table.delegate = self
        UI_table.dataSource = self
        // Do any additional setup after loading the view.
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text == nil || searchBar.text == "" {
            
            inSearchMode = false
            
            view.endEditing(true)
            searchstring = ""
            let range = NSMakeRange(0, self.UI_table.numberOfSections)
            let sections = NSIndexSet(indexesIn: range)
            self.UI_table.reloadSections(sections as IndexSet, with: .automatic)
            
        } else {
            
            inSearchMode = true
               searchstring = searchText
            filteredData[0].items = itemsection[0].items.filter({$0.namechanged?.lowercased().range(of:searchBar.text!.lowercased()) != nil || $0.producttype_id?.barcode?.lowercased().range(of:searchBar.text!.lowercased()) != nil})
            filteredData[1].items = itemsection[1].items.filter({$0.namechanged?.lowercased().range(of:searchBar.text!.lowercased()) != nil || $0.producttype_id?.barcode?.lowercased().range(of:searchBar.text!.lowercased()) != nil})
            filteredData[2].items = itemsection[2].items.filter({$0.namechanged?.lowercased().range(of:searchBar.text!.lowercased()) != nil || $0.producttype_id?.barcode?.lowercased().range(of:searchBar.text!.lowercased()) != nil})
            let range = NSMakeRange(0, self.UI_table.numberOfSections)
            let sections = NSIndexSet(indexesIn: range)
            self.UI_table.reloadSections(sections as IndexSet, with: .automatic)
        }
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
        
        itemsection[0].items.removeAll()
        itemsection[1].items.removeAll()
        itemsection[2].items.removeAll()
        
        
        
        let result = AppUtils.getInstance().objects(Product.self).sorted(byKeyPath: "expiretime", ascending: false)
        if(result.count>0)
        {
            containerView.isHidden = false
            UI_message.isHidden = true
            for index in 0...result.count - 1 {
                
                
                if AppUtils.countDay(from: result[index].expiretime) < 0
                {
                    itemsection[0].items.insert(result[index], at: 0)
                }
                    
                else if AppUtils.countDay(from: result[index].expiretime) >= 0 && AppUtils.countDay(from: result[index].expiretime) <= result[index].daybefore
                {
                    itemsection[1].items.insert(result[index], at: 0)
                }
                    
                else
                {
                    itemsection[2].items.insert(result[index], at: 0)
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
            
            
            AppUtils.getProductViewModel().deleteProduct(idproduct: self.itemsection[indexPath.section].items[indexPath.row]._id!, iduser: AppUtils.getUserID()){
                
            }
            
            try! AppUtils.getInstance().write {
                let objectsToDelete = AppUtils.getInstance().objects(Product.self).filter(" _id = '\(self.itemsection[indexPath.section].items[indexPath.row]._id!)'")
                print("da lay")
                AppUtils.getInstance().delete(objectsToDelete)
                  let NotificationToDelete = AppUtils.getInstance().objects(NotificationModel.self).filter(" productid = '\(self.itemsection[indexPath.section].items[indexPath.row]._id!)'")
                     AppUtils.getInstance().delete(NotificationToDelete)
                let data:[String: NotificationModel] = ["notification":  NotificationToDelete[0]]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notification_update"), object: nil,
                                                userInfo: data)
            }
            if(AppUtils.getInstance().objects(Product.self).count == 0)
            {
                self.containerView.isHidden = true
                self.UI_message.isHidden = false
            }
            
            self.itemsection[indexPath.section].items.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
             AppUtils.reloadNotification()
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
        
        product = AppUtils.getInstance().objects(Product.self).filter("_id = '\(itemsection[indexPath.section].items[indexPath.row]._id!)'").first
        sectionindex = indexPath.section
        rowindex = indexPath.row
        self.performSegue(withIdentifier: "goto_detail", sender: self)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if inSearchMode {
             return filteredData[section].collapsed ? 0 : filteredData[section].items.count
          
        }
            return itemsection[section].collapsed ? 0 : itemsection[section].items.count
      
    }
 
    override func willAnimateRotation(to toInterfaceOrientation:   UIInterfaceOrientation, duration: TimeInterval)
    {
        self.UI_table.reloadData()
    }
    
  
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ProductTableViewCell
        var data : Product
        if inSearchMode {
            
            data = filteredData[indexPath.section].items[indexPath.row]
            
        } else {
            
            data = itemsection[indexPath.section].items[indexPath.row]
        }
//        cell.UI_name.text = data.namechanged

//         cell.UI_name.text = data.namechanged!
     
        
//        UIView.animate(withDuration: 12.0, delay: 1, options: ([.curveLinear, .repeat]), animations: {() -> Void in
//           cell.UI_time.center =  CGPoint.init(x: 0 - cell.UI_time.bounds.size.width / 2, y: cell.UI_time.center.y)
//
//
//        }, completion:  { _ in })
        cell.UI_time.text = AppUtils.dayString(from: Double(data.expiretime))
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.UI_barcode.text = data.producttype_id?.barcode
        let processor = ResizingImageProcessor(referenceSize: CGSize(width: 300, height: 300)) >> RoundCornerImageProcessor(cornerRadius: 50)
        if (data.imagechanged!.hasPrefix("file:///"))
        {
            print("khong co anh")
            cell.UI_image.kf.setImage(with: URL(string: data.imagechanged!),options: [.transition(.fade(1)),.processor(processor)], completionHandler: { image, error, cacheType, imageURL in
                
                
            })
        }
        else
        {
        cell.UI_image.kf.setImage(with: URL(string: AppUtils.BASE_URL_IMAGE + data.imagechanged!),options: [.transition(.fade(1)),.processor(processor)], completionHandler: { image, error, cacheType, imageURL in
           
            
        })
        }
        cell.UI_image.contentMode = .scaleAspectFit
        cell.UI_image.clipsToBounds = true
        cell.UI_expired.text =  AppUtils.dayDifference(from :Double(data.expiretime))
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
        highlightlabel(label: cell.UI_name,coretext: data.namechanged!,highlighttext: searchstring)
        highlightlabel(label: cell.UI_barcode,coretext: (data.producttype_id?.barcode)!,highlighttext: searchstring)
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
    func highlightlabel(label : UILabel,coretext : String,highlighttext : String){
        let range = (coretext as NSString).range(of: highlighttext)
     
        let attributedText = NSMutableAttributedString.init(string: coretext)
        attributedText.addAttribute(.backgroundColor, value: UIColor.blue , range: range)
        attributedText.addAttribute(.foregroundColor, value: UIColor.white , range: range)
        label.attributedText = attributedText
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return itemsection[(indexPath as NSIndexPath).section].collapsed ? 0 : 110
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
            if(itemsection[0].items.count==0)
            {
                height = 0.0
            }
            
            
        case 1:
            if(itemsection[1].items.count==0)
            {
                height = 0.0
            }
            
        default:
            if(itemsection[2].items.count==0)
            {
                height = 0.0
            }
        }
        return height
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.itemsection.count
    }
    @objc func labelTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        
        let collapsed = !itemsection[(tapGestureRecognizer.view?.tag)!].collapsed
        
        // Toggle collapse
        itemsection[(tapGestureRecognizer.view?.tag)!].collapsed = collapsed
     
      
        // Reload the whole section
        UI_table.reloadSections(NSIndexSet(index: (tapGestureRecognizer.view?.tag)!) as IndexSet, with: .automatic)
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = UI_table.dequeueReusableHeaderFooterView(withIdentifier: "header") as? CollapsibleTableViewHeader ?? CollapsibleTableViewHeader(reuseIdentifier: "header")
        if inSearchMode {
            
       header.titleLabel.text = "\(filteredData[section].name)(\(filteredData[section].items.count))"
            
        } else {
            
             header.titleLabel.text = "\(itemsection[section].name)(\(itemsection[section].items.count))"
        }
      
        header.section = section
        header.titleLabel.tag = section
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(labelTapped(tapGestureRecognizer:)))
        header.titleLabel.isUserInteractionEnabled = true
        header.titleLabel.addGestureRecognizer(tapGestureRecognizer)
        if(itemsection[section].collapsed == true)
        {
            switch (section) {
            case 0:
                header.backgroundView?.backgroundColor = UIColor.red
                header.titleLabel.textColor = UIColor.white
            case 1:
                header.backgroundView?.backgroundColor = UIColor.init(red: 254/255, green: 193/255, blue: 7/255, alpha: 1)
                header.titleLabel.textColor = UIColor.white
            default:
                header.backgroundView?.backgroundColor = UIColor.init(red: 54/255, green: 156/255, blue: 18/255, alpha: 1)
                header.titleLabel.textColor = UIColor.white
            }
        }
        else
        {
            switch section {
            case 0:
                   header.backgroundView?.backgroundColor = UIColor.white
                header.titleLabel.textColor = UIColor.red
                
                
            case 1:
                 header.backgroundView?.backgroundColor = UIColor.white
                header.titleLabel.textColor = UIColor.init(red: 254/255, green: 193/255, blue: 7/255, alpha: 1)
            default:
                 header.backgroundView?.backgroundColor = UIColor.white
                header.titleLabel.textColor = UIColor.init(red: 54/255, green: 156/255, blue: 18/255, alpha: 1)
            }
        }
        
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
      
 
        
        return header
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
      
        
      
        
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
    
//    func toggleSection(header: CollapsibleTableViewHeader, section: Int) {
//        let collapsed = !itemsection[section].collapsed
//
//        // Toggle collapse
//        itemsection[section].collapsed = collapsed
//
//
//        // Reload the whole section
//        UI_table.reloadSections(NSIndexSet(index: section) as IndexSet, with: .automatic)
//    }
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
  
   
 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("bat dau")
        if let destinationViewController = segue.destination as? ProductDetailViewController {
            destinationViewController.product = product
        }
    }
    
}
