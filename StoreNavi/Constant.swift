//
//  Constant.swift
//  
//
//  Created by Gaurang Makawana on 16/01/17.
//
//

import Foundation
import UIKit

let appDelegate = UIApplication.shared.delegate as! AppDelegate

struct API {
    static let stagingUrl = "http://storenavi-devapi.net/api/businessentity"
    //static let stagingUrl = "http://storenavi-devapi.net/api/businessentity/"
}

struct Constants {
    
    static let alertTitle = "StoreNavi"
}

enum FindStoreOption: Int {
    case Store = 1, ZipCode, Area
}

enum LocateProductOption: Int {
    case ProductCategory = 1, ProductType, Name, ProductFullName
}


struct Placeholder {
    
}
