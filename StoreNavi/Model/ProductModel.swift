//
//  ProductModel.swift
//  StoreNavi
//
//  Created by Gaurang Makawana on 31/01/17.
//  Copyright © 2017 Gaurang Makawana. All rights reserved.
//

import Foundation
import Gloss

class ProductModel:Glossy {
    
    var BusinessEntityId: NSNumber?
    var EntityName: String?
    var EntityProductId: NSNumber?
    var ProductCategory: String?
    var ProductCategoryId: NSNumber?
    var ProductId: NSNumber?
    var ProductLat: NSNumber?
    var ProductLong: NSNumber?
    var ProductName: String?
    var ProductType: String?
    var ProductTypeId: NSNumber?
    
    required init?(json: JSON) {
        
        self.BusinessEntityId = "BusinessEntityId" <~~ json
        self.EntityName = "EntityName" <~~ json
        self.EntityProductId = "EntityProductId" <~~ json
        self.ProductCategory = "ProductCategory" <~~ json
        self.ProductCategoryId = "ProductCategoryId" <~~ json
        self.ProductId = "ProductId" <~~ json
        self.ProductLat = "ProductLat" <~~ json
        self.ProductLong = "ProductLong" <~~ json
        self.ProductName = "ProductName" <~~ json
        self.ProductType = "ProductType" <~~ json
        self.ProductTypeId = "ProductTypeId" <~~ json
    }
    
    
    func toJSON() -> JSON? {
        return jsonify([
            "BusinessEntityId" ~~>  self.BusinessEntityId,
            "EntityName" ~~>  self.EntityName,
            "EntityProductId" ~~>  self.EntityProductId,
            "ProductCategory" ~~>  self.ProductCategory,
            "ProductCategoryId" ~~>  self.ProductCategoryId,
            "ProductId" ~~>  self.ProductId,
            "ProductLat" ~~>  self.ProductLat,
            "ProductLong" ~~>  self.ProductLong,
            "ProductName" ~~>  self.ProductName,
            "ProductType" ~~>  self.ProductType,
            "ProductTypeId" ~~>  self.ProductTypeId,
            ])
    }
    
    
}
