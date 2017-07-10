//
//  NetworkManager.swift
//  SwiftBookUpdated
//
//  Created by Gaurang Makawana on 17/01/17.
//  Copyright © 2017 Gaurang Makawana. All rights reserved.
//


import Foundation
import Alamofire

// MARK: Request Type

enum WebServiceType {
    case GET
    case POST
    case DELETE
    case PUT
}

// MARK: Content Type

enum ContentType : String {
    case JSON,XML,RSS,HTML,TEXT,FORM
    
    func getContentType() -> String {
        switch self {
        case .XML:
            return "application/xml"
        case .RSS:
            return "application/rss+xml"
        case .HTML:
            return "text/html"
        case .TEXT:
            return "text/plain"
        case .FORM:
           return "application/x-www-form-urlencoded"
        default:
            return "application/json"
        }
    }
}

// MARK: Request Type

enum RequestType : String {
    
    case getEntities = "/GetEntitiesLocationMapping"
    case getProducts = "/GetEntityProducts?entityMappingId="
    
    func serviceUrl() -> String {
        switch self {
        case .getEntities:
            return String(API.stagingUrl + "/GetEntitiesLocationMapping")
            //return "https://api.github.com/users/hadley/orgs"
        case .getProducts:
            return String(API.stagingUrl + "/GetEntityProducts?entityMappingId=")
            //return "https://api.github.com/users/hadley/orgs"
        
        }
    }
}

protocol NetworkProtocol {
    
    func getRequestTask(completionHandler: ((_ response: Any) -> (Void))?, errorHandler: ((_ error: NSError) -> (Void))?)
    
    func postRequestTask(contentType : ContentType, parameters:Dictionary<String,Any>?, completionHandler: ((_ response: Any) -> (Void))?, errorHandler: ((_ error: NSError) -> (Void))?)
}

extension Request {
    public func debugLog() -> Self {
        // #if DEBUG
            debugPrint(self)
        // #endif
        return self
    }
}

struct NetworkManager {
    
    var requestType : String
    
    init(withRequestType requestType: String) {
        self.requestType = requestType
    }
}

extension NetworkManager : NetworkProtocol {
    
    func getRequestTask(completionHandler: ((Any) -> (Void))?, errorHandler: ((NSError) -> (Void))?){
        
        
        Alamofire.request(self.requestType).responseJSON { response in
            
            //print(response.request)  // original URL request
            //print(response.response) // HTTP URL response
            //print(response.data)     // server data
            //print(response.result)   // result of response serialization
            
            switch response.result {
                
                case .success(let data) :
                    if completionHandler != nil {
                        completionHandler!(response:data)
                    }
                case .failure(let error) :
                    if errorHandler != nil {
                        errorHandler!(error as NSError)
                    }
            }
        }
        
//        Alamofire.request(self.requestType.serviceUrl()).validate().responseJSON { (response) in
//         
//            switch response.result {
//            case .success(let data) :
//                if completionHandler != nil {
//                    completionHandler!(response:data)
//                }
//            case .failure(let error) :
//                if errorHandler != nil {
//                    errorHandler!(error as NSError)
//                }
//            }
//        }
    }
    
    func postRequestTask(contentType: ContentType, parameters: Dictionary<String, Any>?, completionHandler: ((Any) -> (Void))?, errorHandler: ((NSError) -> (Void))?) {
        
        // Add default headers if needed.
        let headers: HTTPHeaders = [
            "Accept": "text/html",
            "Content-Type" : "application/x-www-form-urlencoded"
        ]

        Alamofire.request(self.requestType, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).validate().responseJSON { (response) in
        
            debugPrint(response)

            switch response.result {
            case .success(let data) :
            
                if completionHandler != nil {
                    completionHandler!(response: data)
                }
            case .failure(let error):
                
                if errorHandler != nil {
                    errorHandler!(error as NSError)
                }
            }
        }
    }
}


