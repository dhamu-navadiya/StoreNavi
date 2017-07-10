//
//  FindStoreVC.swift
//  StoreNavi
//
//  Created by Gaurang Makawana on 16/01/17.
//  Copyright © 2017 Gaurang Makawana. All rights reserved.
//

import Foundation
import UIKit

extension String {
    var isAlphanumeric: Bool {
        return !isEmpty && range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
    }
    
    var isAlphabetic: Bool {
        return !isEmpty && range(of: "[^a-zA-Z ]", options: .regularExpression) == nil
    }
    
    var isNumeric: Bool {
        return !isEmpty && range(of: "[^0-9]", options: .regularExpression) == nil
    }
}

class FindStoreVC: UIViewController, UITextFieldDelegate,UIGestureRecognizerDelegate, StoreAutoCompleteTextFieldVCDelegate {
    
    // MARK: - Variable Declaration
    @IBOutlet weak var navigateStoreButton: UIButton?
    
    @IBOutlet weak var storeTextFiled: UITextField!
    @IBOutlet weak var zipcodeTextFiled: UITextField!
    @IBOutlet weak var areaTextFiled: UITextField!
    
    var selectedStore: StoreModel?
    var selectedZip: StoreModel?
    var selectedArea: StoreModel?
    
    var currentTextField: UITextField?
    var arrAllStoreList:Array<StoreModel>?
    var autoCompleteTextFieldViewController:StoreAutoCompleteTextFieldVC?
    var isProductNotAvailable:Bool = false
    
    var itShouldBeNumeric:Bool? = false
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.setHidesBackButton(true, animated:true);
        
        self.navigationController?.isNavigationBarHidden = false
        navigateStoreButton?.backgroundColor = UIColor(red: 29.0/255.0, green: 135.0/255.0, blue: 187.0/255.0, alpha: 1.0)
        //navigateStoreButton?.backgroundColor = UIColor.gray
        
        navigateStoreButton?.layer.cornerRadius = 4
        navigateStoreButton?.layer.borderWidth = 1
        navigateStoreButton?.layer.borderColor = UIColor.clear.cgColor
        
        let fm = FileManager.default
        let fileURL:URL = try! fm.url(for:.libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let strFileURL = fileURL.appendingPathComponent("file.plist").path
        if let responseDict:Dictionary<String,AnyObject> = NSDictionary(contentsOfFile: strFileURL) as? Dictionary<String,AnyObject> {
            print(responseDict)
            if let arrData:Array<Dictionary<String,AnyObject>> = responseDict["Data"] as?  Array<Dictionary<String,AnyObject>> {
                arrAllStoreList = [StoreModel].from(jsonArray: arrData)
            }
        }
        
        //print("arrAllStoreList : \(arrAllStoreList)")
        
        //need to updatestatus bar light content
        self.setNeedsStatusBarAppearanceUpdate()
        
        //add right view in textfield
        storeTextFiled.rightViewMode = .always
        let rightView:UIImageView = UIImageView(frame: CGRect(x: (storeTextFiled?.frame.width)!-30, y: 0, width: 30, height: 30))
        rightView.image = UIImage(named: "downarrow")
        storeTextFiled.rightView = rightView
        
        areaTextFiled.rightViewMode = .always
        let rightView1:UIImageView = UIImageView(frame: CGRect(x: (areaTextFiled?.frame.width)!-30, y: 0, width: 30, height: 30))
        rightView1.image = UIImage(named: "downarrow")
        areaTextFiled.rightView = rightView1
        
        //add line below
        self.perform(#selector(self.addLineBelowAllTextfield), with: nil, afterDelay: 0.3)
        
        storeTextFiled?.autocorrectionType = .no
        zipcodeTextFiled?.autocorrectionType = .no
        areaTextFiled?.autocorrectionType = .no
        
//        storeTextFiled.clearButtonMode = UITextFieldViewMode.always
//        zipcodeTextFiled.clearButtonMode = UITextFieldViewMode.always
//        areaTextFiled.clearButtonMode = UITextFieldViewMode.always
        
        //intially untill and unless value of store is not selected then disable zipcode and area textfield
        //storeTextFiled.isEnabled = true
        //zipcodeTextFiled.isEnabled = false
        //areaTextFiled.isEnabled = false
        
        //tap gesture so when tapped outside remove list view
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.onSingleTap))
        tap.delegate = self
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        if (currentTextField != nil) {
            currentTextField?.resignFirstResponder()
        }
        self.navigationItem.title = Constants.alertTitle
        
        if self.isProductNotAvailable {
            
            self.isProductNotAvailable = false
            let alert = UIAlertController(title: Constants.alertTitle, message: "No products available for the selected options.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if UserDefaults.standard.bool(forKey: "storeOverlay") == false {
            
            UserDefaults.standard.set(true, forKey: "storeOverlay")
            let newViewController = self.storyboard?.instantiateViewController(withIdentifier: "OverlayVC") as! OverlayVC
            newViewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            self.present(newViewController, animated: false, completion: nil)
        }
    }
    
    //MARK:- Helper 
    func addLineBelowAllTextfield() {
        storeTextFiled.addLineAtBottom()
        zipcodeTextFiled.addLineAtBottom()
        areaTextFiled.addLineAtBottom()
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
    
    // MARK: - Action Events
    @IBAction func navigateStore(sender: UIButton) {
        
        if (storeTextFiled.text?.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty)! {
            
            let alert = UIAlertController(title: Constants.alertTitle, message: "Please select store.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)

            
            
        } else if (zipcodeTextFiled.text?.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty)! {
            
            let alert = UIAlertController(title: Constants.alertTitle, message: "Please enter zipcode or city and state.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        } else if(areaTextFiled.text?.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty)! {
            
            let alert = UIAlertController(title: Constants.alertTitle, message: "Please select area.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        } else {
         
            let newViewController = self.storyboard?.instantiateViewController(withIdentifier: "LocateProductVC") as! LocateProductVC
            newViewController.selectedMapID = (selectedArea?.EntityMappingId?.stringValue)!
            self.navigationController?.pushViewController(newViewController, animated: true)
        }
    }
    
    @IBAction func selectStore(sender: UIButton) {
        
        let selectedButton = sender
        if selectedButton.tag == FindStoreOption.Store.rawValue {
            print("Store Selected")
        } else if selectedButton.tag == FindStoreOption.ZipCode.rawValue {
            print("Zipcode Selected")
        } else {
            print("Area Selected")
        }
    }
    
    // MARK: - Memory Management
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        autoCompleteTextFieldViewController = self.storyboard?.instantiateViewController(withIdentifier: "StoreAutoCompleteTextFieldVC") as? StoreAutoCompleteTextFieldVC
        autoCompleteTextFieldViewController?.delegate = self
        
        var frame:CGRect = autoCompleteTextFieldViewController!.view.frame
        frame.origin.x = textField.frame.origin.x
        frame.origin.y = textField.frame.origin.y + textField.frame.size.height
        frame.size.width = textField.frame.size.width
        autoCompleteTextFieldViewController!.view.frame = frame
        
        if textField.tag == FindStoreOption.Store.rawValue {
            
            let filteredContacts = arrAllStoreList?.filterDuplicates { $0.EntityId == $1.EntityId }
            autoCompleteTextFieldViewController?.selectedFilterOption = FindStoreOption.Store.rawValue
            autoCompleteTextFieldViewController?.arrDataList = filteredContacts!
            
            self.addAutoComplete(textField: textField)
            
        } else if textField.tag == FindStoreOption.ZipCode.rawValue {
    
            if (storeTextFiled.text?.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty)! {
                
                let alert = UIAlertController(title: Constants.alertTitle, message: "Please select store.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            let filteredArray = arrAllStoreList?.filter { $0.EntityId == selectedStore?.EntityId }
            autoCompleteTextFieldViewController?.selectedFilterOption = FindStoreOption.ZipCode.rawValue
            autoCompleteTextFieldViewController?.arrDataList = filteredArray!
            
            autoCompleteTextFieldViewController?.isSearchWithAutoComplete = false
            autoCompleteTextFieldViewController?.isSimpleSearch = true

        } else {
            
            if (storeTextFiled.text?.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty)! {
                
                let alert = UIAlertController(title: Constants.alertTitle, message: "Please select store.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            } else if (zipcodeTextFiled.text?.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty)! {
                
                let alert = UIAlertController(title: Constants.alertTitle, message: "Please enter zipcode or city and state.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            let filteredArray = arrAllStoreList?.filter { $0.CityStateId == selectedZip?.CityStateId }
            autoCompleteTextFieldViewController?.selectedFilterOption = FindStoreOption.Area.rawValue
            autoCompleteTextFieldViewController?.arrDataList = filteredArray!
            
            self.addAutoComplete(textField: textField)
        }
    }
    
    func addAutoComplete(textField:UITextField) {
        
        textField.resignFirstResponder()
        
        //is not simple search
        autoCompleteTextFieldViewController?.isSimpleSearch = false
        //add search bar
        autoCompleteTextFieldViewController?.addSearchBar()
        //this is search with auto complete
        autoCompleteTextFieldViewController?.isSearchWithAutoComplete = true
        // add as subview
        self.configureChildViewController(childController: autoCompleteTextFieldViewController!, onView: self.view)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        print("End")
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        
        var strSearchText:String = textField.text!
        
        if string.isEmpty == true { //deleted characters
            strSearchText = strSearchText.remove(ind: range.location)
        }
        else{ //Adding characters
            strSearchText = strSearchText.insert(string: string, ind: range.location)
        }
        
        if strSearchText.characters.count > 0 { //have search string
            
            if textField.tag == FindStoreOption.ZipCode.rawValue {
                if strSearchText.characters.count == 1 {
                    
                    if let _:Int = Int(strSearchText) {
                        self.itShouldBeNumeric = true
                    }
                    else{
                        self.itShouldBeNumeric = false
                    }
                    
                    if self.itShouldBeNumeric! == true {
                        if strSearchText.isNumeric == false {
                            return false
                        }
                    }
                    else{
                        if strSearchText.isAlphabetic == false {
                            return false
                        }
                    }
                }
                else{
                    if self.itShouldBeNumeric! == true {
                        if strSearchText.isNumeric == false {
                            return false
                        }
                    }
                    else{
                        if strSearchText.isAlphabetic == false {
                            return false
                        }
                    }
                }
            }
            
            
            autoCompleteTextFieldViewController?.filterContentForSearchText(strSearchText)
            
            if autoCompleteTextFieldViewController?.arrFilteredList.count == 0{
                if autoCompleteTextFieldViewController?.view.isDescendant(of: self.view) == true {
                    removeChildController(autoCompleteTextFieldViewController!)
                }
            }
            else {
                if autoCompleteTextFieldViewController?.view.isDescendant(of: self.view) == false {
                    self.configureChildViewController(childController: autoCompleteTextFieldViewController!, onView: self.view)
                }
            }
        }
        else{ //no search string
            
            self.itShouldBeNumeric = nil
            if autoCompleteTextFieldViewController?.view.isDescendant(of: self.view) == true {
                removeChildController(autoCompleteTextFieldViewController!)
            }
        }
        

        
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool{
        textField.text = ""
        
        if textField.tag == FindStoreOption.Store.rawValue {
            
            selectedStore = nil
            selectedZip = nil
            selectedArea = nil
            
            //zipcodeTextFiled.isEnabled = false
            //.isEnabled = false
            
        } else if textField.tag == FindStoreOption.ZipCode.rawValue {
            
            selectedZip = nil
            //areaTextFiled.isEnabled = true
            
        } else { //Area
             selectedArea = nil
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
    
    //MARK:- AutoCompleteTextFieldViewControllerDelegate
    func didSelectRow(_ selectedData: Any, _ selectedOption: Int) {
        
        if (currentTextField != nil) {
            currentTextField?.resignFirstResponder()
        }
        //storeTextFiled.isEnabled = true
        
        if let selectedData:StoreModel = selectedData as? StoreModel {
            
            //let selOption:StoreModel = selectedData as! StoreModel
            if selectedOption == FindStoreOption.Store.rawValue {
                
                selectedStore = selectedData
                storeTextFiled.text = selectedStore?.EntityName
                
                //enable textfield and clear data
                selectedZip = nil
                zipcodeTextFiled.text = ""
                //zipcodeTextFiled.isEnabled = true
                zipcodeTextFiled.rightView = UIView()
                
                //clear data
                selectedArea = nil
                areaTextFiled.text = ""
                
            } else if selectedOption == FindStoreOption.ZipCode.rawValue {
                
                selectedZip = selectedData
                zipcodeTextFiled.text = selectedZip?.CityState
                
                //enable textfield
                //areaTextFiled.isEnabled = true
                
                //add green tick on right side
                zipcodeTextFiled.rightViewMode = .always
                let rightView:UIView = UIView(frame: CGRect(x: (zipcodeTextFiled?.frame.width)!-30, y: 0, width: 30, height: 30))
                let rightImgView:UIImageView = UIImageView(frame: CGRect(x: 5, y: 5, width: 20, height: 20))
                rightImgView.image = UIImage(named: "correct_text")
                rightView.addSubview(rightImgView)
                zipcodeTextFiled.rightView = rightView
                
                //clear data
                selectedArea = nil
                areaTextFiled.text = ""
                
            } else {
                
                selectedArea = selectedData
                areaTextFiled.text = selectedArea?.Area
            }
        }
        removeChildController(autoCompleteTextFieldViewController!)
        //autoCompleteTextFieldViewController = nil
    }
}

//MARK:- Extension : UITextField
extension UITextField {
    func addLineAtBottom(_ lineHeight:CGFloat = 1,lineColor:CGColor = UIColor.lightGray.cgColor) {
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x: 0.0, y: self.frame.size.height - lineHeight, width: UIScreen.main.bounds.width-(self.frame.origin.x*2), height: lineHeight);
        //bottomBorder.frame = CGRect(x: 0.0, y: self.frame.size.height - lineHeight, width: self.frame.width, height: lineHeight);
        bottomBorder.backgroundColor = lineColor
        self.layer.addSublayer(bottomBorder)
    }
}

//MARK:- Extension : UIViewController
extension UIViewController {
    
    func configureChildViewController(childController: UIViewController, onView: UIView?) {
        var holderView = self.view
        if let onView = onView {
            holderView = onView
        }
        
        addChildViewController(childController)
        holderView!.addSubview(childController.view)
        //constrainViewEqual(holderView: holderView!, view: childController.view)
        childController.didMove(toParentViewController: self)
    }
    
    func constrainViewEqual(holderView: UIView, view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        //pin 100 points from the top of the super
        let pinTop = NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal,
                                        toItem: holderView, attribute: .top, multiplier: 1.0, constant: 0)
        let pinBottom = NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal,
                                           toItem: holderView, attribute: .bottom, multiplier: 1.0, constant: 0)
        let pinLeft = NSLayoutConstraint(item: view, attribute: .left, relatedBy: .equal,
                                         toItem: holderView, attribute: .left, multiplier: 1.0, constant: 0)
        let pinRight = NSLayoutConstraint(item: view, attribute: .right, relatedBy: .equal,
                                          toItem: holderView, attribute: .right, multiplier: 1.0, constant: 0)
        holderView.addConstraints([pinTop, pinBottom, pinLeft, pinRight])
    }
    
    func removeChildController(_ viewController: UIViewController) {
        
        viewController.willMove(toParentViewController: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParentViewController()
    }
}

//MARK:- Extension : Array
extension Array {
    
    func filterDuplicates( includeElement: (_ lhs:Element, _ rhs:Element) -> Bool) -> [Element]{
        var results = [Element]()
        
        forEach { (element) in
            let existingElements = results.filter {
                return includeElement(element, $0)
            }
            if existingElements.count == 0 {
                results.append(element)
            }
        }
        
        return results
    }
}

//MARK:- Extension : String
extension String {
    func insert(string:String,ind:Int) -> String {
        return  String(self.characters.prefix(ind)) + string + String(self.characters.suffix(self.characters.count-ind))
    }
    
    func remove(ind:Int) -> String {
        return  String(self.characters.prefix(ind))
    }
}
