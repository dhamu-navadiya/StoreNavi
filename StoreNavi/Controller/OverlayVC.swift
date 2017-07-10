//
//  OverlayVC.swift
//  StoreNavi
//
//  Created by Gaurang Makawana on 17/02/17.
//  Copyright © 2017 Gaurang Makawana. All rights reserved.
//

import Foundation
import UIKit

class OverlayVC: UIViewController {
    
    @IBOutlet var btnClose:UIButton?
    @IBOutlet var overlayImgView:UIImageView!
    var isProductOvrlay: Bool = false
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.navigationController?.isNavigationBarHidden = true
        
        self.view.backgroundColor = UIColor.clear
        self.view.isOpaque = false
        btnClose?.backgroundColor = UIColor(red: 29.0/255.0, green: 135.0/255.0, blue: 187.0/255.0, alpha: 1.0)
        
        if UIDevice.current.userInterfaceIdiom == .phone{
            if UIScreen.main.bounds.size.height == 568 { //4 inch screen
                overlayImgView.image = self.isProductOvrlay ? UIImage(named:"product_overlay_4.0_inch") : UIImage(named:"store_overlay_4.0_inch")
            }
            else if UIScreen.main.bounds.size.height == 667 { //4.7 inch screen
                overlayImgView.image = self.isProductOvrlay ? UIImage(named:"product_overlay_4.7_inch") : UIImage(named:"store_overlay_4.7_inch")
            }
            else if UIScreen.main.bounds.size.height == 736 { //5.5 inch screen
                overlayImgView.image = self.isProductOvrlay ? UIImage(named:"product_overlay_5.5_inch") : UIImage(named:"store_overlay_5.5_inch")
            }
        }
        else{
            if Device().description == "iPad Pro (12.9-inch" { //12 inch screen
                overlayImgView.image = self.isProductOvrlay ? UIImage(named:"product_overlay_iPadAir") : UIImage(named:"store_overlay_iPadAir")
            }
            else{ //9 inch screen
                overlayImgView.image = self.isProductOvrlay ? UIImage(named:"product_overlay_iPadPro") : UIImage(named:"store_overlay_iPadPro")
            }
        }
    
        //need to updatestatus bar light content
        //self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
    }

    
    @IBAction func closeOverlay(sender: UIButton) {
        self.dismiss(animated: false)
    }

}
