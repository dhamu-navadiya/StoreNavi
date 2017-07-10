//
//  LocateProductVC.swift
//  StoreNavi
//
//  Created by Gaurang Makawana on 17/01/17.
//  Copyright © 2017 Gaurang Makawana. All rights reserved.
//

import Foundation
import UIKit
import EZLoadingActivity

class LocateProductVC: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate, ProductAutoCompleteTextFieldVCDelegate, CartDelegate {

    // MARK: - Variable Declaration
    @IBOutlet weak var locateProductButton: UIButton?
    @IBOutlet weak var addToCartButton: UIButton?
    
    @IBOutlet weak var productCategotyTextFiled: UITextField!
    @IBOutlet weak var productTypeTextFiled: UITextField!
    @IBOutlet weak var productTextFiled: UITextField!
    @IBOutlet weak var productNameTextFiled: UITextField!
    
    var selectedCategoty: ProductModel?
    var selectedType: ProductModel?
    var selectedProduct: ProductModel?
    var selectedProductName: ProductModel?
    
    var currentTextField: UITextField?
    var arrAllProductList:Array<ProductModel>?
    var selectedMapID:String = ""
    
    var autoCompleteTextFieldViewController:ProductAutoCompleteTextFieldVC?
    
    var addCartButton:MIBadgeButton!
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        locateProductButton?.backgroundColor = UIColor(red: 29.0/255.0, green: 135.0/255.0, blue: 187.0/255.0, alpha: 1.0)
        addToCartButton?.backgroundColor = UIColor(red: 29.0/255.0, green: 135.0/255.0, blue: 187.0/255.0, alpha: 1.0)
        
//        locateProductButton?.backgroundColor = UIColor.gray
//        addToCartButton?.backgroundColor = UIColor.gray
        
        locateProductButton?.layer.cornerRadius = 4
        locateProductButton?.layer.borderWidth = 1
        locateProductButton?.layer.borderColor = UIColor.clear.cgColor
        
        addToCartButton?.layer.cornerRadius = 4
        addToCartButton?.layer.borderWidth = 1
        addToCartButton?.layer.borderColor = UIColor.clear.cgColor
        
        // Do any additional setup after loading the view.
        //need to updatestatus bar light content
        self.setNeedsStatusBarAppearanceUpdate()
        
        self.navigationItem.title = Constants.alertTitle
        
        addCartButton = MIBadgeButton.init(type: .custom)
        addCartButton.setImage(UIImage.init(named: "shopping_cart"), for: UIControlState.normal)
        //addCart.backgroundColor = UIColor.green
        addCartButton.addTarget(self, action:#selector(LocateProductVC.callAddCart), for: UIControlEvents.touchUpInside)
        addCartButton.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30) //CGRectMake(0, 0, 30, 30)
        let barButtonRight = UIBarButtonItem.init(customView: addCartButton)
        self.navigationItem.rightBarButtonItem = barButtonRight
        
        //use below to adjust badge
        //button.badgeEdgeInsets = UIEdgeInsetsMake(10, 0, 0, 15)
        addCartButton.badgeTextColor = UIColor.white
        addCartButton.badgeBackgroundColor = UIColor.red
        
        let backButton = UIButton.init(type: .custom)
        //backButton.backgroundColor = UIColor.yellow
        backButton.setImage(UIImage.init(named: "back_button"), for: UIControlState.normal)
        backButton.addTarget(self, action:#selector(LocateProductVC.backPressed), for: UIControlEvents.touchUpInside)
        backButton.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30) //CGRectMake(0, 0, 30, 30)
        let barButtonLeft = UIBarButtonItem.init(customView: backButton)
        self.navigationItem.leftBarButtonItem = barButtonLeft
        
        //add right view in textfield
        productCategotyTextFiled.rightViewMode = .always
        let rightView:UIImageView = UIImageView(frame: CGRect(x: (productCategotyTextFiled?.frame.width)!-30, y: 0, width: 30, height: 30))
        rightView.image = UIImage(named: "downarrow")
        productCategotyTextFiled.rightView = rightView
        
        productTypeTextFiled.rightViewMode = .always
        let rightView1:UIImageView = UIImageView(frame: CGRect(x: (productTypeTextFiled?.frame.width)!-30, y: 0, width: 30, height: 30))
        rightView1.image = UIImage(named: "downarrow")
        productTypeTextFiled.rightView = rightView1
        
        productTextFiled.rightViewMode = .always
        let rightView2:UIImageView = UIImageView(frame: CGRect(x: (productTextFiled?.frame.width)!-30, y: 0, width: 30, height: 30))
        rightView2.image = UIImage(named: "downarrow")
        productTextFiled.rightView = rightView2
        
        //add line below
        self.perform(#selector(self.addLineBelowAllTextfield), with: nil, afterDelay: 0.3)
        
//        productCategotyTextFiled.clearButtonMode = UITextFieldViewMode.whileEditing
//        productTypeTextFiled.clearButtonMode = UITextFieldViewMode.whileEditing
//        productTextFiled.clearButtonMode = UITextFieldViewMode.whileEditing
//        productNameTextFiled.clearButtonMode = UITextFieldViewMode.whileEditing
        
        //print("MapID: \(self.selectedMapID)")
        getAllProductDetails()
        //productTypeTextFiled.isEnabled = false
        //productTextFiled.isEnabled = false
        
        //tap gesture so when tapped outside remove list view
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.onSingleTap))
        tap.delegate = self
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)

    }

    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        let badgeCount:Int = appDelegate.arrSelectedProductList.count
//        if addCartButton.badgeString != nil && addCartButton.badgeString!.characters.count > 0{
//            badgeCount =  Int(addCartButton.badgeString!)! + 1
//        }
        addCartButton.badgeString  = String(badgeCount)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if UserDefaults.standard.bool(forKey: "productOverlay") == false {
            
            UserDefaults.standard.set(true, forKey: "productOverlay")
            let newViewController = self.storyboard?.instantiateViewController(withIdentifier: "OverlayVC") as! OverlayVC
            newViewController.isProductOvrlay = true
            newViewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            self.present(newViewController, animated: false, completion: nil)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    //MARK:- Helper
    func addLineBelowAllTextfield() {
        productCategotyTextFiled.addLineAtBottom()
        productTypeTextFiled.addLineAtBottom()
        productTextFiled.addLineAtBottom()
        productNameTextFiled.addLineAtBottom()
    }
    
    // MARK: - Web Service Call
    func getAllProductDetails() {
        
        EZLoadingActivity.show("Please wait...", disableUI: true)
        
        print("http://storenavi-devapi.net/api/businessentity/GetEntityProducts?entityMappingId=" + selectedMapID)
        
        let objNetworkManager = NetworkManager(withRequestType:"http://storenavi-devapi.net/api/businessentity/GetEntityProducts?entityMappingId=" + selectedMapID)
        
        objNetworkManager.getRequestTask(completionHandler: { (response) -> (Void) in
            
            EZLoadingActivity.hide()
            let responseDict : NSDictionary = response as! NSDictionary
            
            if responseDict["IsError"] == nil {
                
                let findStoreViewcontroller:FindStoreVC = self.navigationController!.viewControllers.first as! FindStoreVC
                findStoreViewcontroller.isProductNotAvailable = true
                _ = self.navigationController?.popViewController(animated: true)
                
            } else {
                let isError = responseDict["IsError"] as? Bool
                
                if isError == false {
                    
                    let arrResponse = responseDict["Data"] as?  Array<Dictionary<String,AnyObject>>
                    if arrResponse?.count == 0   {
                        let findStoreViewcontroller:FindStoreVC = self.navigationController!.viewControllers.first as! FindStoreVC
                        findStoreViewcontroller.isProductNotAvailable = true
                        _ = self.navigationController?.popViewController(animated: true)
                    }
                    self.arrAllProductList = [ProductModel].from(jsonArray: arrResponse!)
                    
                } else {
                    print("error")
                }
            }
            
        }) { (error) -> (Void) in
            
            print(error.localizedDescription)
            EZLoadingActivity.hide()
        }
    }
    
    // MARK: - Memory Management
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - OnClick Navigation function
    
    func callAddCart() {
        
        let newViewController = self.storyboard?.instantiateViewController(withIdentifier: "CartVC") as! CartVC
        newViewController.delegate = self
        self.navigationController?.pushViewController(newViewController, animated: true)
    }
    
    func backPressed() {
        
        if appDelegate.arrSelectedProductList.count>0 {
            
            let alert = UIAlertController(title: Constants.alertTitle, message: "Your wishlist will be cleared. Do you want to continue ?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: alertHandler))
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: alertHandler))
            self.present(alert, animated: true, completion: nil)
            return
            
        }
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func alertHandler(alert: UIAlertAction) {
        
        if alert.title == "Yes" {
            appDelegate.arrSelectedProductList.removeAll()
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    func resetController() {
     
        selectedCategoty = nil
        productCategotyTextFiled.text = ""
        
        selectedType = nil
        productTypeTextFiled.text = ""
        
        selectedProduct = nil
        productTextFiled.text = ""
        
        selectedProductName = nil
        productNameTextFiled.text = ""
        productNameTextFiled.rightView = UIView()
    }
    
    // MARK: - Action Events
    
    @IBAction func selectProduct(sender: UIButton) {
        
        let selectedButton = sender
        if selectedButton.tag == LocateProductOption.ProductCategory.rawValue {
            print("Category Selected")
        } else if selectedButton.tag == LocateProductOption.ProductType.rawValue {
            print("Type Selected")
        } else {
            print("Name Selected")
        }
    }
    
    @IBAction func locateProduct(sender: UIButton) {
        
        if (currentTextField != nil) {
            currentTextField?.resignFirstResponder()
        }
        
        if selectedProduct != nil ||  selectedProductName != nil {
            
            if  appDelegate.arrSelectedProductList.count >= 10 {
                let alert = UIAlertController(title: Constants.alertTitle, message: "Your cart is full. You can add only 10 products at a time.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
                
            } else {
                
                if selectedProduct != nil {
                    
                    let arrFilteredResult = appDelegate.arrSelectedProductList.filter {
                        return $0.ProductId == selectedProduct!.ProductId
                    }
                    
                    if arrFilteredResult.count > 0 {
                        let alert = UIAlertController(title: Constants.alertTitle, message: "Product already exists in your cart.", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                    else {
                        appDelegate.arrSelectedProductList.append(selectedProduct!)
                        
                        var badgeCount:Int = 1
                        if addCartButton.badgeString != nil && addCartButton.badgeString!.characters.count > 0{
                            badgeCount =  Int(addCartButton.badgeString!)! + 1
                        }
                        addCartButton.badgeString  = String(badgeCount)
                    }
                    
                } else {
                    
                    let arrFilteredResult = appDelegate.arrSelectedProductList.filter {
                        return $0.ProductId == selectedProductName!.ProductId
                    }
                    
                    if arrFilteredResult.count > 0 {
                        let alert = UIAlertController(title: Constants.alertTitle, message: "Product already exists in your cart.", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                    else {
                        appDelegate.arrSelectedProductList.append(selectedProductName!)
                        
                        var badgeCount:Int = 1
                        if addCartButton.badgeString != nil && addCartButton.badgeString!.characters.count > 0{
                            badgeCount =  Int(addCartButton.badgeString!)! + 1
                        }
                        addCartButton.badgeString  = String(badgeCount)
                        
                    }
                }
            }  
        }
        
        if  appDelegate.arrSelectedProductList.count == 0 {
            let alert = UIAlertController(title: Constants.alertTitle, message: "Your cart is empty. Please add atleast one product.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        let mapViewController = self.storyboard?.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
        self.navigationController?.pushViewController(mapViewController, animated: true)
    }

    @IBAction func addToCart(sender: UIButton) {
        
        if (currentTextField != nil) {
            currentTextField?.resignFirstResponder()
        }
        
        if selectedProduct != nil ||  selectedProductName != nil{
    
            if  appDelegate.arrSelectedProductList.count >= 10 {
                let alert = UIAlertController(title: Constants.alertTitle, message: "Your cart is full. You can add only 10 products at a time.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
                
            } else {
             
                if selectedProduct != nil {
                    
                    let arrFilteredResult = appDelegate.arrSelectedProductList.filter {
                        return $0.ProductId == selectedProduct!.ProductId
                    }
                    
                    if arrFilteredResult.count > 0 {
                        let alert = UIAlertController(title: Constants.alertTitle, message: "Product already exists in your cart.", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    else {
                        appDelegate.arrSelectedProductList.append(selectedProduct!)
                        
                        var badgeCount:Int = 1
                        if addCartButton.badgeString != nil && addCartButton.badgeString!.characters.count > 0{
                            badgeCount =  Int(addCartButton.badgeString!)! + 1
                        }
                        addCartButton.badgeString  = String(badgeCount)
                        
                        let alert = UIAlertController(title: Constants.alertTitle, message: "Product successfully added to your cart.", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        resetController()
                    }
                    
                }
                else { //selectedProductName
                    
                    let arrFilteredResult = appDelegate.arrSelectedProductList.filter {
                        return $0.ProductId == selectedProductName!.ProductId
                    }
                    
                    if arrFilteredResult.count > 0 {
                        let alert = UIAlertController(title: Constants.alertTitle, message: "Product already exists in your cart.", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    else {
                        appDelegate.arrSelectedProductList.append(selectedProductName!)
                        
                        var badgeCount:Int = 1
                        if addCartButton.badgeString != nil && addCartButton.badgeString!.characters.count > 0{
                            badgeCount =  Int(addCartButton.badgeString!)! + 1
                        }
                        addCartButton.badgeString  = String(badgeCount)
                        
                        let alert = UIAlertController(title: Constants.alertTitle, message: "Product successfully added to your cart.", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        resetController()
                    }
                }
                
            }
    
        } else {
            
            let alert = UIAlertController(title: Constants.alertTitle, message: "Please select the product.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    //MARK:- UITapGesture
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        if self.view == touch.view {
            return true
        }
        else{
            return false
        }
    }
    
    func onSingleTap(_ tapGesture:UITapGestureRecognizer){
        
        self.view.endEditing(true)
        
        if autoCompleteTextFieldViewController?.view.isDescendant(of: self.view) == true {
            removeChildController(autoCompleteTextFieldViewController!)
        }
    }
    
    //MARK:- CartDelegate Method
    func selectProduct(_ selectedData: Any, _ selectedOption: Int) {
     
        print(selectedData)
    }
    
    //MARK:- AutoCompleteTextFieldViewControllerDelegate
    func didSelectRow(_ selectedData: Any, _ selectedOption: Int) {
    
        //productCategotyTextFiled.isEnabled = true
        productNameTextFiled.rightView = UIView()
        
        if let selectedData:ProductModel = selectedData as? ProductModel {
            
            if selectedOption == LocateProductOption.ProductFullName.rawValue {
                
                selectedProductName = selectedData
                productNameTextFiled.text = selectedProductName?.ProductName
                
                //add green tick on right side
                productNameTextFiled.rightViewMode = .always
                let rightView:UIView = UIView(frame: CGRect(x: (productNameTextFiled?.frame.width)!-30, y: 0, width: 30, height: 30))
                let rightImgView:UIImageView = UIImageView(frame: CGRect(x: 5, y: 5, width: 20, height: 20))
                rightImgView.image = UIImage(named: "correct_text")
                rightView.addSubview(rightImgView)
                productNameTextFiled.rightView = rightView
                
                //clear data
                selectedCategoty = nil
                productCategotyTextFiled.text = ""
                
                selectedType = nil
                productTypeTextFiled.text = ""
                
                selectedProduct = nil
                productTextFiled.text = ""

            } else {
                
                selectedProductName = nil
                productNameTextFiled.text = ""
                
                if selectedOption == LocateProductOption.ProductCategory.rawValue {
                    
                    selectedCategoty = selectedData
                    productCategotyTextFiled.text = selectedCategoty?.ProductCategory
                    
                    //clear data
                    selectedType = nil
                    //productTypeTextFiled.isEnabled = true
                    productTypeTextFiled.text = ""
                    
                    selectedProduct = nil
                    productTextFiled.text = ""
                    
                } else if selectedOption == LocateProductOption.ProductType.rawValue {
                    
                    selectedType = selectedData
                    productTypeTextFiled.text = selectedType?.ProductType
                    
                    //clear data
                    selectedProduct = nil
                    //productTextFiled.isEnabled = true
                    productTextFiled.text = ""
                    
                } else if selectedOption == LocateProductOption.Name.rawValue {
                    
                    selectedProduct = selectedData
                    productTextFiled.text = selectedProduct?.ProductName
                    
                }
            }
        }
        removeChildController(autoCompleteTextFieldViewController!)
    }
    
    
    //MARK: - UITextFieldDelegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool{
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField){

        currentTextField = textField
        
        if autoCompleteTextFieldViewController != nil{
            removeChildController(autoCompleteTextFieldViewController!)
        }
    
        autoCompleteTextFieldViewController = self.storyboard?.instantiateViewController(withIdentifier: "ProductAutoCompleteTextFieldVC") as? ProductAutoCompleteTextFieldVC
        autoCompleteTextFieldViewController?.delegate = self
        
        var frame:CGRect = autoCompleteTextFieldViewController!.view.frame
        frame.origin.x = textField.frame.origin.x
        frame.origin.y = textField.frame.origin.y + textField.frame.size.height
        frame.size.width = textField.frame.size.width
        autoCompleteTextFieldViewController!.view.frame = frame
        
        if textField.tag == LocateProductOption.ProductCategory.rawValue {
        
            let filteredContacts = self.arrAllProductList?.filterDuplicates { $0.ProductCategoryId == $1.ProductCategoryId }
            autoCompleteTextFieldViewController?.selectedFilterOption = LocateProductOption.ProductCategory.rawValue
            autoCompleteTextFieldViewController?.arrDataList = filteredContacts!
            
            self.addAutoComplete(textField: textField)
            
        } else if textField.tag == LocateProductOption.ProductType.rawValue {
            
            if (productCategotyTextFiled.text?.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty)! {
                
                let alert = UIAlertController(title: Constants.alertTitle, message: "Please select product categoty.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            let filteredArray = self.arrAllProductList?.filter { $0.ProductCategoryId == selectedCategoty?.ProductCategoryId }
            let filteredContacts = filteredArray?.filterDuplicates { $0.ProductTypeId == $1.ProductTypeId }
            autoCompleteTextFieldViewController?.selectedFilterOption = LocateProductOption.ProductType.rawValue
            autoCompleteTextFieldViewController?.arrDataList = filteredContacts!
            
            self.addAutoComplete(textField: textField)
        
        } else if textField.tag == LocateProductOption.Name.rawValue {
            
            if (productCategotyTextFiled.text?.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty)! {
                
                let alert = UIAlertController(title: Constants.alertTitle, message: "Please select product categoty.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            } else if (productTypeTextFiled.text?.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty)! {
                
                let alert = UIAlertController(title: Constants.alertTitle, message: "Please select product type.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            let filteredArray = self.arrAllProductList?.filter { $0.ProductTypeId == selectedType?.ProductTypeId }
            autoCompleteTextFieldViewController?.selectedFilterOption = LocateProductOption.Name.rawValue
            autoCompleteTextFieldViewController?.arrDataList = filteredArray!
            
            self.addAutoComplete(textField: textField)
        
        } else if textField.tag == LocateProductOption.ProductFullName.rawValue {
            
            autoCompleteTextFieldViewController?.arrDataList = self.arrAllProductList!
            autoCompleteTextFieldViewController?.selectedFilterOption = LocateProductOption.ProductFullName.rawValue
            autoCompleteTextFieldViewController?.isSearchWithAutoComplete = false
            autoCompleteTextFieldViewController?.isSimpleSearch = true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField){
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        
        var strSearchText:String = textField.text!
        
        if string.isEmpty == true { //deleted characters
            strSearchText = strSearchText.remove(ind: range.location)
        
        } else { //Adding characters
            strSearchText = strSearchText.insert(string: string, ind: range.location)
        }
        
        autoCompleteTextFieldViewController?.filterContentForSearchText(strSearchText)
        
        if autoCompleteTextFieldViewController?.arrFilteredList.count == 0 {
            if autoCompleteTextFieldViewController?.view.isDescendant(of: self.view) == true {
                removeChildController(autoCompleteTextFieldViewController!)
            }
        
        } else {
            
            if autoCompleteTextFieldViewController?.view.isDescendant(of: self.view) == false {
                self.configureChildViewController(childController: autoCompleteTextFieldViewController!, onView: self.view)
            }
        }
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        
        if textField.tag == LocateProductOption.ProductCategory.rawValue {
            
            selectedCategoty = nil
            selectedType = nil
            selectedProduct = nil
            
            //productTypeTextFiled.isEnabled = false
            //productTextFiled.isEnabled = false
            
        } else if textField.tag == LocateProductOption.ProductType.rawValue {
            
            selectedType = nil
            //productTextFiled.isEnabled = true
            
        } else {
            selectedProduct = nil
        }
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }

    
    func addAutoComplete(textField:UITextField) {
        textField.resignFirstResponder()
        //textField.isEnabled = false
        
        //is not simple search
        autoCompleteTextFieldViewController?.isSimpleSearch = false
        //add search bar
        autoCompleteTextFieldViewController?.addSearchBar()
        //this is search with auto complete
        autoCompleteTextFieldViewController?.isSearchWithAutoComplete = true
        // add as subview
        self.configureChildViewController(childController: autoCompleteTextFieldViewController!, onView: self.view)
    }
}
