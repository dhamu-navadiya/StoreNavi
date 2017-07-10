//
//  ProductAutoCompleteTextFieldVC.swift
//  AutoCompleteTextfieldDemo
//
//  Created by Gaurang Makawana on 31/01/17.
//  Copyright © 2017 Gaurang Makawana. All rights reserved.
//


import UIKit

protocol ProductAutoCompleteTextFieldVCDelegate {
    func didSelectRow(_ selectedData: Any, _ selectedOption: Int)
}

class ProductAutoCompleteTextFieldVC: UITableViewController, UITextFieldDelegate {
  
    // MARK: - Properties
    var delegate:ProductAutoCompleteTextFieldVCDelegate?
    var arrDataList = [ProductModel]()
    var arrFilteredList = [ProductModel]()
  
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let productModel: ProductModel
        
        if isSearchWithAutoComplete {
            if arrFilteredList.count == 0 && self.currentSearchText?.characters.count == 0 {
                productModel = arrDataList[indexPath.row]
            }
            else{
                productModel = arrFilteredList[indexPath.row]
            }
        }
        else if isSimpleSearch {
            productModel = arrFilteredList[indexPath.row]
        }
        else {
            productModel = arrDataList[indexPath.row]
        }
        
        if selectedFilterOption == LocateProductOption.ProductCategory.rawValue {
            cell.textLabel!.text = productModel.ProductCategory
        } else if selectedFilterOption == LocateProductOption.ProductType.rawValue {
            cell.textLabel!.text = productModel.ProductType
        } else if selectedFilterOption == LocateProductOption.Name.rawValue {
            cell.textLabel!.text = productModel.ProductName
        } else {
            cell.textLabel!.text = productModel.ProductName
        }
        //cell.detailTextLabel!.text = productModel.category
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let productModel: ProductModel
        if isSearchWithAutoComplete {
            if arrFilteredList.count == 0 && self.currentSearchText?.characters.count == 0 {
                productModel = arrDataList[indexPath.row]
            }
            else{
                productModel = arrFilteredList[indexPath.row]
            }
        }
        else if isSimpleSearch {
            productModel = arrFilteredList[indexPath.row]
        }
        else {
            productModel = arrDataList[indexPath.row]
        }
        delegate?.didSelectRow(productModel, selectedFilterOption)
    }
  
    func filterContentForSearchText(_ searchText: String) {
        
        if selectedFilterOption == LocateProductOption.ProductCategory.rawValue {
            arrFilteredList = arrDataList.filter({( productModel : ProductModel) -> Bool in
                return (productModel.ProductCategory?.lowercased().contains(searchText.lowercased()))!
            })
        } else if selectedFilterOption == LocateProductOption.ProductType.rawValue {
            
            arrFilteredList = arrDataList.filter({( productModel : ProductModel) -> Bool in
                return (productModel.ProductType?.lowercased().contains(searchText.lowercased()))!
            })

        } else if selectedFilterOption == LocateProductOption.ProductType.rawValue {
            arrFilteredList = arrDataList.filter({( productModel : ProductModel) -> Bool in
                return (productModel.ProductName?.lowercased().contains(searchText.lowercased()))!
            })
        } else {
            arrFilteredList = arrDataList.filter({( productModel : ProductModel) -> Bool in
                return (productModel.ProductName?.lowercased().contains(searchText.lowercased()))!
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
