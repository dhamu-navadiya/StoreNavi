//
//  StoreAutoCompleteTextFieldVC.swift
//  AutoCompleteTextfieldDemo
//
//  Created by Gaurang Makawana on 18/01/17.
//  Copyright © 2017 Gaurang Makawana. All rights reserved.
//


import UIKit

protocol StoreAutoCompleteTextFieldVCDelegate {
    func didSelectRow(_ selectedData: Any, _ selectedOption: Int)
}

class StoreAutoCompleteTextFieldVC: UITableViewController, UITextFieldDelegate {
  
    // MARK: - Properties
    var delegate:StoreAutoCompleteTextFieldVCDelegate?
    var arrDataList = [StoreModel]()
    var arrFilteredList = [StoreModel]()
  
    var isSimpleSearch = false
    var isSearchWithAutoComplete = false
    var selectedFilterOption = 1
    
    var searchTextField:UITextField?
    var currentSearchText:String? = ""
    
    // MARK: - View Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.layer.borderWidth = 0.5
        self.view.layer.borderColor = UIColor.lightGray.cgColor
        
        self.definesPresentationContext = true
        self.edgesForExtendedLayout = []
        self.extendedLayoutIncludesOpaqueBars = true;
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        //KVO
        //KVO for keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        /*
        //sample data
        arrDataList = [
            Candy(category:"Chocolate", name:"Chocolate Bar"),
            Candy(category:"Chocolate", name:"Chocolate Chip"),
            Candy(category:"Chocolate", name:"Dark Chocolate"),
            Candy(category:"Hard", name:"Lollipop"),
            Candy(category:"Hard", name:"Candy Cane"),
            Candy(category:"Hard", name:"Jaw Breaker"),
            Candy(category:"Other", name:"Caramel"),
            Candy(category:"Other", name:"Sour Chew"),
            Candy(category:"Other", name:"Gummi Bear")]
         */
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK:- KVO
    func keyboardWillShow(_ notification: Notification) {
        // Step 1: Get the size of the keyboard.
        var userInfo = notification.userInfo!
        // 2
        let value = userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue
        let keyboardSize:CGSize =  value.cgRectValue.size
        // 3
        
        var contentInsets = UIEdgeInsets()
        if UIInterfaceOrientationIsPortrait(UIApplication.shared.statusBarOrientation) {
            contentInsets = UIEdgeInsetsMake(0.0, 0.0, (keyboardSize.height), 0.0)
        }
        else {
            contentInsets = UIEdgeInsetsMake(0.0, 0.0, (keyboardSize.width), 0.0)
        }
        self.tableView.contentInset = contentInsets
//        self.tableView.scrollIndicatorInsets = contentInsets
//        
//        let firstIndexPath:IndexPath = IndexPath(row: 0, section: 0)
//        self.tableView.scrollToRow(at: firstIndexPath, at: .top, animated: true)
        
        self.tableView.scrollRectToVisible(CGRect(x:0,y:0,width:0,height:0), animated: true)

    }
    
    func keyboardWillHide(_ notification: Notification) {
        let contentInsets: UIEdgeInsets = UIEdgeInsets.zero
        self.tableView.contentInset = contentInsets
        self.tableView.scrollIndicatorInsets = contentInsets
    }
    
    //MARK:- Helpers
    func addSearchBar() {
        // Setup the Search Controller
//        searchController.delegate = self
//        searchController.searchResultsUpdater = self
//        searchController.searchBar.delegate = self
//        definesPresentationContext = true
//        searchController.dimsBackgroundDuringPresentation = false
//        searchController.hidesNavigationBarDuringPresentation = false
//        
//        // Add the SearchBar
//        searchController.searchBar.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: 44.0)
//        tableView.tableHeaderView = searchController.searchBar
//        
//        searchController.searchBar.becomeFirstResponder()
        
        let searchView:UIView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: 56.0))
        
        var searchViewFrame:CGRect = searchView.frame
        searchViewFrame.origin.x = 20
        searchViewFrame.origin.y = (searchView.frame.height - 30)/2
        searchViewFrame.size.width -= 40
        searchViewFrame.size.height = 30
        
        searchTextField = UITextField(frame: searchViewFrame)
        searchTextField?.delegate = self
        searchTextField?.placeholder = "Search"
        searchTextField?.isUserInteractionEnabled = true
        searchTextField?.autocorrectionType = .no
        
        searchView.addSubview(searchTextField!)
        
        searchTextField?.layer.borderWidth = 0.5
        searchTextField?.layer.borderColor = UIColor.lightGray.cgColor
        searchTextField?.layer.cornerRadius = 6.0
        
        //add padding in left
        searchTextField?.leftViewMode = .always
        searchTextField?.leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 20, height: searchTextField!.frame.size.height))
        
        tableView.tableHeaderView = searchView
        
        //searchTextField?.becomeFirstResponder()
    }
    
    // MARK: - Table View
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        if isSearchWithAutoComplete {
            if arrFilteredList.count == 0 && self.currentSearchText?.characters.count == 0 {
                return arrDataList.count
            }
            else{
                return arrFilteredList.count
            }
        }
        else if isSimpleSearch {
            return arrFilteredList.count
        }
        return arrDataList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let storeModel: StoreModel
        if isSearchWithAutoComplete {
            if arrFilteredList.count == 0 && self.currentSearchText?.characters.count == 0 {
                storeModel = arrDataList[indexPath.row]
            }
            else{
                storeModel = arrFilteredList[indexPath.row]
            }
        }
        else if isSimpleSearch {
            storeModel = arrFilteredList[indexPath.row]
        }
        else {
            storeModel = arrDataList[indexPath.row]
        }
        
        
        let cellIdentifier = "Cell"
        
        var cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: cellIdentifier)
        }
        
        if selectedFilterOption == FindStoreOption.ZipCode.rawValue { //Zipcode
            cell?.textLabel!.text = storeModel.CityState! + " (\(storeModel.ZipCode!))"
            cell?.textLabel!.numberOfLines = 2
            cell?.detailTextLabel?.text = "\(storeModel.ZipCode)"
        }
        else{ //Other
            
            cell?.textLabel!.numberOfLines = 2
            if selectedFilterOption == FindStoreOption.Store.rawValue {
                cell?.textLabel!.text = storeModel.EntityName
            } else if selectedFilterOption == FindStoreOption.ZipCode.rawValue {
                cell?.textLabel!.text = storeModel.CityState
            } else {
                cell?.textLabel!.text = storeModel.Area
            }
        }
        
        //cell.detailTextLabel!.text = storeModel.category
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storeModel: StoreModel
        if isSearchWithAutoComplete {
            if arrFilteredList.count == 0 && self.currentSearchText?.characters.count == 0 {
                storeModel = arrDataList[indexPath.row]
            }
            else{
                storeModel = arrFilteredList[indexPath.row]
            }
        }
        else if isSimpleSearch {
            storeModel = arrFilteredList[indexPath.row]
        }
        else {
            storeModel = arrDataList[indexPath.row]
        }
        
        delegate?.didSelectRow(storeModel, selectedFilterOption)
    }
  
    func filterContentForSearchText(_ searchText: String) {
        
        if selectedFilterOption == FindStoreOption.Store.rawValue {
            arrFilteredList = arrDataList.filter({( storeModel : StoreModel) -> Bool in
                return (storeModel.EntityName?.lowercased().contains(searchText.lowercased()))!
            })
        } else if selectedFilterOption == FindStoreOption.ZipCode.rawValue {
            
            if let curSearchInt = Int(searchText) {
                arrFilteredList = arrDataList.filter({( storeModel : StoreModel) -> Bool in
                    
//                    let curSearchNum = NSNumber(value:curSearchInt)
//                    return (storeModel.ZipCode! == curSearchNum)
                    print("curSearchInt : \(curSearchInt)")
                    return (String(describing: storeModel.ZipCode!).lowercased().contains(searchText.lowercased()))
                })
            }
            else {
                arrFilteredList = arrDataList.filter({( storeModel : StoreModel) -> Bool in
                    return (storeModel.CityState?.lowercased().contains(searchText.lowercased()))!
                })
            }
        } else {
            arrFilteredList = arrDataList.filter({( storeModel : StoreModel) -> Bool in
                return (storeModel.Area?.lowercased().contains(searchText.lowercased()))!
            })
        }
       
        tableView.reloadData()
    }
    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            
        }
    }
    
    //MARK: - 
    //MARK: - UITextFieldDelegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField){
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        
        var strSearchText:String = textField.text!
        
        if string.isEmpty == true { //deleted characters
            strSearchText = strSearchText.remove(ind: range.location)
        }
        else{ //Adding characters
            strSearchText = strSearchText.insert(string: string, ind: range.location)
        }
        
        self.currentSearchText = strSearchText
        self.filterContentForSearchText(strSearchText)
        
        return true
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool{
        textField.text = ""
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
}
