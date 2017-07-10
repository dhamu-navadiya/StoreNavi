//
//  CartVC.swift
//  StoreNavi
//
//  Created by Gaurang Makawana on 02/02/17.
//  Copyright © 2017 Gaurang Makawana. All rights reserved.
//

import Foundation
import UIKit

protocol CartDelegate {
    func selectProduct(_ selectedData: Any, _ selectedOption: Int)
}

class CartVC: UITableViewController {

    //var arrSelectedProductList:Array<ProductModel>?
   
    var delegate:CartDelegate?
    
    // MARK: - View Setup
    override func viewDidLoad() {
        
        self.navigationItem.title = Constants.alertTitle
        
        let backButton = UIButton.init(type: .custom)
        //backButton.backgroundColor = UIColor.yellow
        backButton.setImage(UIImage.init(named: "back_button"), for: UIControlState.normal)
        backButton.addTarget(self, action:#selector(CartVC.backPressed), for: UIControlEvents.touchUpInside)
        backButton.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30) //CGRectMake(0, 0, 30, 30)
        let barButtonLeft = UIBarButtonItem.init(customView: backButton)
        self.navigationItem.leftBarButtonItem = barButtonLeft
        
        //need to updatestatus bar light content
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    // MARK: - OnClick Navigation function
    
    func backPressed() {
        //do stuff here
        _ = self.navigationController?.popViewController(animated: true)
    }

    // MARK: - Table View
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return appDelegate.arrSelectedProductList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CartCell", for: indexPath)
        
        let productModel: ProductModel = appDelegate.arrSelectedProductList[indexPath.row]
        cell.textLabel!.text = productModel.ProductName
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedData = appDelegate.arrSelectedProductList[indexPath.row]
        delegate?.selectProduct(selectedData, indexPath.row)
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            appDelegate.arrSelectedProductList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

}
