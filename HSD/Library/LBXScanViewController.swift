//
//  LX.swift
//  HSD
//
//  Created by Tô Tử Siêu on 6/22/18.
//  Copyright © 2018 Finger. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation

public protocol LBXScanViewControllerDelegate {
    func scanFinished(scanResult: LBXScanResult, error: String?)
}


open class LBXScanViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //返回扫码结果，也可以通过继承本控制器，改写该handleCodeResult方法即可
    open var scanResultDelegate: LBXScanViewControllerDelegate?
    
    open var scanObj: LBXScanWrapper?
    
    open var scanStyle: LBXScanViewStyle = LBXScanViewStyle()
    
    open var qRScanView: LBXScanView?
    open var result_barcode : String = ""
    
    //启动区域识别功能
    open var isOpenInterestRect = false
    var isOpenedFlash:Bool = false
    
    // MARK: - 底部几个功能：开启闪光灯、相册、我的二维码
    
    //底部显示的功能项
    var bottomItemsView:UIView?
    
    //相册
   
    
    //闪光灯
    var btnFlash:UIButton = UIButton()
    
    //我的二维码
  
    //识别码的类型
    public var arrayCodeType:[AVMetadataObject.ObjectType]?
    
    //是否需要识别后的当前图像
    public  var isNeedCodeImage = false
    
    //相机启动提示文字
    public var readyString:String! = "loading"
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        scanStyle.centerUpOffset = 44;
        scanStyle.photoframeAngleStyle = LBXScanViewPhotoframeAngleStyle.On;
        scanStyle.photoframeLineW = 6;
        scanStyle.photoframeAngleW = 24;
        scanStyle.photoframeAngleH = 24;
        scanStyle.isNeedShowRetangle = true;
        
        scanStyle.anmiationStyle = LBXScanViewAnimationStyle.NetGrid;
        
        
        //矩形框离左边缘及右边缘的距离
        scanStyle.xScanRetangleOffset = 80;
        
        //使用的支付宝里面网格图片
        scanStyle.animationImage = UIImage(named: "CodeScan.bundle/qrcode_scan_part_net")
        isOpenInterestRect = true
        // Do any additional setup after loading the view.
        
        // [self.view addSubview:_qRScanView];
        self.view.backgroundColor = UIColor.black
        self.edgesForExtendedLayout = UIRectEdge(rawValue: 0)
        
        
    }
    func drawBottomItems()
    {
        if (bottomItemsView != nil) {
            
            return;
        }
        
        let yMax = self.view.frame.maxY - self.view.frame.minY
        
        bottomItemsView = UIView(frame:CGRect(x: 0.0, y: yMax-200,width: self.view.frame.size.width, height: 100 ) )
        
        
        bottomItemsView!.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.6)
        
        self.view .addSubview(bottomItemsView!)
        
        
        let size = CGSize(width: 65, height: 87);
        
        self.btnFlash = UIButton()
        btnFlash.bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        btnFlash.center = CGPoint(x: bottomItemsView!.frame.width/2, y: bottomItemsView!.frame.height/2)
        btnFlash.setImage(UIImage(named: "CodeScan.bundle/qrcode_scan_btn_flash_nor"), for:UIControlState.normal)
        btnFlash.addTarget(self, action: #selector(LBXScanViewController.openOrCloseFlash), for: UIControlEvents.touchUpInside)
        
        
     
        
        bottomItemsView?.addSubview(btnFlash)
      
        
        self.view .addSubview(bottomItemsView!)
        
    }
    @objc func openOrCloseFlash()
    {
        print("loi")
        scanObj!.changeTorch()
        
        isOpenedFlash = !isOpenedFlash
        
        if isOpenedFlash
        {
            btnFlash.setImage(UIImage(named: "CodeScan.bundle/qrcode_scan_btn_flash_down"), for:UIControlState.normal)
        }
        else
        {
            btnFlash.setImage(UIImage(named: "CodeScan.bundle/qrcode_scan_btn_flash_nor"), for:UIControlState.normal)
        }
    }
    open func setNeedCodeImage(needCodeImg:Bool)
    {
        isNeedCodeImage = needCodeImg;
    }
    //设置框内识别
    open func setOpenInterestRect(isOpen:Bool){
        isOpenInterestRect = isOpen
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        drawScanView()
        
        perform(#selector(LBXScanViewController.startScan), with: nil, afterDelay: 0.3)
        
    }
    
    @objc open func startScan()
    {
        
        if (scanObj == nil)
        {
            var cropRect = CGRect.zero
            if isOpenInterestRect
            {
                cropRect = LBXScanView.getScanRectWithPreView(preView: self.view, style:scanStyle )
            }
            
            //指定识别几种码
            if arrayCodeType == nil
            {
                arrayCodeType = [AVMetadataObject.ObjectType.ean13 ,AVMetadataObject.ObjectType.code128]
            }
            
            scanObj = LBXScanWrapper(videoPreView: self.view,objType:arrayCodeType!, isCaptureImg: isNeedCodeImage,cropRect:cropRect, success: { [weak self] (arrayResult) -> Void in
                
                if let strongSelf = self
                {
                    //停止扫描动画
                   
                    
                    strongSelf.handleCodeResult(arrayResult: arrayResult)
                }
            })
        }
         drawBottomItems()
        //结束相机等待提示
        qRScanView?.deviceStopReadying()
        
        //开始扫描动画
        qRScanView?.startScanAnimation()
        
        //相机运行
        scanObj?.start()
    }
    
    open func drawScanView()
    {
        if qRScanView == nil
        {
            qRScanView = LBXScanView(frame: self.view.frame,vstyle:scanStyle )
            self.view.addSubview(qRScanView!)
        }
        qRScanView?.deviceStartReadying(readyStr: readyString)
        
    }
    
    
    /**
     处理扫码结果，如果是继承本控制器的，可以重写该方法,作出相应地处理，或者设置delegate作出相应处理
     */
    open func handleCodeResult(arrayResult:[LBXScanResult])
    {
        if let delegate = scanResultDelegate  {
            
            self.navigationController? .popViewController(animated: true)
            let result:LBXScanResult = arrayResult[0]
            
            delegate.scanFinished(scanResult: result, error: nil)
            
        }else{
            
            for result:LBXScanResult in arrayResult
            {
                print("%@",result.strScanned ?? "")
            }
            
            let result:LBXScanResult = arrayResult[0]
            
            showMsg(title: result.strBarCodeType, message: result.strScanned)
        }
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        
        qRScanView?.stopScanAnimation()
        
        scanObj?.stop()
    }
    
    open func openPhotoAlbum()
    {
        LBXPermissions.authorizePhotoWith { [weak self] (granted) in
            
            let picker = UIImagePickerController()
            
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            
            picker.delegate = self;
            
            picker.allowsEditing = true
            
            self?.present(picker, animated: true, completion: nil)
        }
    }
    
    //MARK: -----相册选择图片识别二维码 （条形码没有找到系统方法）
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        picker.dismiss(animated: true, completion: nil)
        
        var image:UIImage? = info[UIImagePickerControllerEditedImage] as? UIImage
        
        if (image == nil )
        {
            image = info[UIImagePickerControllerOriginalImage] as? UIImage
        }
        
        if(image != nil)
        {
            let arrayResult = LBXScanWrapper.recognizeQRImage(image: image!)
            if arrayResult.count > 0
            {
                handleCodeResult(arrayResult: arrayResult)
                return
            }
        }
        
        showMsg(title: nil, message: NSLocalizedString("Identify failed", comment: "Identify failed"))
    }
    
    func showMsg(title:String?,message:String?)
    {
      
        let alertPrompt = UIAlertController(title: "Đã tìm thấy barcode", message: message!, preferredStyle: .actionSheet)
       
        let confirmAction = UIAlertAction(title: "Xác nhận sử dụng barcode này", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            self.result_barcode = message!
         self.performSegue(withIdentifier: "unwindToMenu", sender: self)
        })
        let cancelAction = UIAlertAction(title: "Hủy bỏ", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            
            self.scanObj?.isNeedScanResult = true
        })
     
        
        alertPrompt.addAction(confirmAction)
        alertPrompt.addAction(cancelAction)
        
        present(alertPrompt, animated: true, completion: nil)
    }
    deinit
    {
        //        print("LBXScanViewController deinit")
    }
    override open func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("bat dau")
        if let destinationViewController = segue.destination as? CreateController {
            destinationViewController.UI_barcode.text = result_barcode
            destinationViewController.UI_barcodeChanged(destinationViewController.UI_barcode)
        }
    }
  
    
    // ...
}





