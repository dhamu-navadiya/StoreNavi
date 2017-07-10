//
//  SplashVC.swift
//  StoreNavi
//
//  Created by Gaurang Makawana on 16/01/17.
//  Copyright © 2017 Gaurang Makawana. All rights reserved.
//

import UIKit
import EZLoadingActivity
import Alamofire

class SplashVC: UIViewController {

    @IBOutlet var splashImgView:UIImageView!
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.navigationController?.isNavigationBarHidden = true
        
        if UIDevice.current.userInterfaceIdiom == .phone{
            if UIScreen.main.bounds.size.height == 568 { //4 inch screen
                splashImgView.image = UIImage(named:"splashscreen_4.0_inch")
            }
            else if UIScreen.main.bounds.size.height == 667 { //4.7 inch screen
                splashImgView.image = UIImage(named:"splashscreen_4.7_inch")
            }
            else if UIScreen.main.bounds.size.height == 736 { //5.5 inch screen
                splashImgView.image = UIImage(named:"splashscreen_5.5_inch")
            }
        }
        else{
            if Device().description == "iPad Pro (12.9-inch" { //12 inch screen
                splashImgView.image = UIImage(named:"splashscreen_ipad_pro")
            }
            else{ //9 inch screen
                splashImgView.image = UIImage(named:"splashscreen_ipad_retina")
            }
        }
        
        //set background color
        self.view.backgroundColor = UIColor(red: 29.0/255.0, green: 135.0/255.0, blue: 187.0/255.0, alpha: 1.0)
        
        //need to updatestatus bar light content
        self.setNeedsStatusBarAppearanceUpdate()
        
        //make webservice call
        let fm = FileManager.default
        let fileURL:URL = try! fm.url(for:.libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let strFileURL = fileURL.appendingPathComponent("file.plist").path
        
        let responseDict:Dictionary<String,AnyObject>? = NSDictionary(contentsOfFile: strFileURL) as? Dictionary<String,AnyObject>
        if responseDict == nil {
            self.getAllStoreObjects()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
    
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Web Service Call
    func getAllStoreObjects() {
        
        EZLoadingActivity.show("Please wait...", disableUI: true)
        
        let objNetworkManager = NetworkManager(withRequestType: "http://storenavi-devapi.net/api/businessentity//GetEntitiesLocationMapping")
        
        objNetworkManager.getRequestTask(completionHandler: { (response) -> (Void) in
            
            EZLoadingActivity.hide()
            let responseDic : NSDictionary = response as! NSDictionary
            print(responseDic)
            
            let fm = FileManager.default
            var fileURL:URL = try! fm.url(for:.libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            fileURL = fileURL.appendingPathComponent("file.plist")
            responseDic.write(to : fileURL, atomically: true)
            
            do {
                var resourceValues = URLResourceValues()
                resourceValues.isExcludedFromBackup = true
                try fileURL.setResourceValues(resourceValues)
            } catch _{
            }
            
            let newViewController = self.storyboard?.instantiateViewController(withIdentifier: "FindStoreVC") as! FindStoreVC
            self.navigationController?.pushViewController(newViewController, animated: true)
            
        }) { (error) -> (Void) in
            
            print(error.localizedDescription)
            EZLoadingActivity.hide()
        }
    }
    

}

