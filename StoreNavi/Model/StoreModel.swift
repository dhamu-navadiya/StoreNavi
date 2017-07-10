//
//  StoreModel.swift
//  StoreNavi
//
//  Created by Gaurang Makawana on 27/01/17.
//  Copyright © 2017 Gaurang Makawana. All rights reserved.
//

import Foundation
import Gloss


class StoreModel:Glossy {
    
    var Area: String?
    var CityState: String?
    var CityStateId: NSNumber?
    var EntityId: NSNumber?
    var EntityLatFirst: NSNumber?
    var EntityLatFourth: NSNumber?
    var EntityLatSecond: NSNumber?
    var EntityLatThird: NSNumber?
    var EntityLongFirst: NSNumber?
    var EntityLongFourth: NSNumber?
    var EntityLongSecond: NSNumber?
    var EntityLongThird: NSNumber?
    var EntityMapUrl: String?
    var EntityMappingId: NSNumber?
    var EntityName: String?
    var ZipCode: NSNumber?
    var ZipCodeId: NSNumber?
    
     required init?(json: JSON) {
        
        self.Area = "Area" <~~ json
        self.CityState = "CityState" <~~ json
        self.CityStateId = "CityStateId" <~~ json
        self.EntityId = "EntityId" <~~ json
        self.EntityLatFirst = "EntityLatFirst" <~~ json
        self.EntityLatFourth = "EntityLatFourth" <~~ json
        self.EntityLatSecond = "EntityLatSecond" <~~ json
        self.EntityLatThird = "EntityLatThird" <~~ json
        self.EntityLongFirst = "EntityLongFirst" <~~ json
        self.EntityLongFourth = "EntityLongFourth" <~~ json
        self.EntityLongSecond = "EntityLongSecond" <~~ json
        self.EntityLongThird = "EntityLongThird" <~~ json
        self.EntityMapUrl = "EntityMapUrl" <~~ json
        self.EntityMappingId = "EntityMappingId" <~~ json
        self.EntityName = "EntityName" <~~ json
        self.ZipCode = "ZipCode" <~~ json
        self.ZipCodeId = "ZipCodeId" <~~ json
    }
    
    
    func toJSON() -> JSON? {
        return jsonify([
            "Area" ~~>  self.Area,
            "CityState" ~~>  self.CityState,
            "CityStateId" ~~>  self.CityStateId,
            "EntityId" ~~>  self.EntityId,
            "EntityLatFirst" ~~>  self.EntityLatFirst,
            "EntityLatFourth" ~~>  self.EntityLatFourth,
            "EntityLatSecond" ~~>  self.EntityLatSecond,
            "EntityLatThird" ~~>  self.EntityLatThird,
            "EntityLongFirst" ~~>  self.EntityLongFirst,
            "EntityLongFourth" ~~>  self.EntityLongFourth,
            "EntityLongSecond" ~~>  self.EntityLongSecond,
            "EntityLongThird" ~~>  self.EntityLongThird,
            "EntityMapUrl" ~~>  self.EntityMapUrl,
            "EntityMappingId" ~~>  self.EntityMappingId,
            "EntityName" ~~>  self.EntityName,
            "ZipCode" ~~>  self.ZipCode,
            "ZipCodeId" ~~>  self.ZipCodeId
            ])
    }


}
