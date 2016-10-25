//
//  YelpClient.swift
//  Yelp
//
//  Created by Duc Dinh on 10/23/16.
//  Copyright © 2016 Duc Dinh. All rights reserved.
//


import UIKit
import AFNetworking
import BDBOAuth1Manager

// You can register for Yelp API keys here: http://www.yelp.com/developers/manage_api_keys
let yelpConsumerKey = "vxKwwcR_NMQ7WaEiQBK_CA"
let yelpConsumerSecret = "33QCvh5bIF5jIHR5klQr7RtBDhQ"
let yelpToken = "uRcRswHFYa1VkDrGV6LAW2F8clGh5JHV"
let yelpTokenSecret = "mqtKIxMIR4iBtBPZCmCLEb-Dz3Y"

enum YelpSortMode: Int {
  case bestMatched = 0, distance, highestRated
}

class YelpClient: BDBOAuth1RequestOperationManager {
  var accessToken: String!
  var accessSecret: String!
  
  static var _shared: YelpClient?
  static func shared() -> YelpClient! {
    if _shared == nil {
      _shared = YelpClient(consumerKey: yelpConsumerKey, consumerSecret: yelpConsumerSecret, accessToken: yelpToken, accessSecret: yelpTokenSecret)
    }
    return _shared
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  init(consumerKey key: String!, consumerSecret secret: String!, accessToken: String!, accessSecret: String!) {
    self.accessToken = accessToken
    self.accessSecret = accessSecret
    let baseUrl = URL(string: "https://api.yelp.com/v2/")
    super.init(baseURL: baseUrl, consumerKey: key, consumerSecret: secret);
    
    let token = BDBOAuth1Credential(token: accessToken, secret: accessSecret, expiration: nil)
    self.requestSerializer.saveAccessToken(token)
  }
  
  func search(with term: String, completion: @escaping ([Business]?, Error?) -> Void) -> AFHTTPRequestOperation {
    return search(with: term, sort: nil, categories: nil, deals: nil, distance: nil, completion: completion)
  }
  
  func search(with term: String, sort: YelpSortMode?, categories: [String]?, deals: Bool?, distance: Int?, completion: @escaping ([Business]?, Error?) -> Void) -> AFHTTPRequestOperation {
    // For additional parameters, see http://www.yelp.com/developers/documentation/v2/search_api
    
    // Default the location to San Francisco
    var parameters: [String : AnyObject] = ["term": term as AnyObject, "ll": "37.785771,-122.406165" as AnyObject]
    
    print("deals: ", deals)
    
    if sort != nil {
      parameters["sort"] = sort!.rawValue as AnyObject?
    }
    
    if categories != nil && categories!.count > 0 {
      parameters["category_filter"] = (categories!).joined(separator: ",") as AnyObject?
    }
    
    if deals != nil {
      parameters["deals_filter"] = deals! as AnyObject?
    }
    
    if distance != nil {
      parameters["radius_filter"] = distance! as AnyObject?
    }
    
    print("params: ", parameters)
    
    return self.get("search", parameters: parameters, success: { (operation: AFHTTPRequestOperation, response: Any) in
      if let response = response as? NSDictionary {
        let dictionaries = response["businesses"] as? [NSDictionary]
        if dictionaries != nil {
          completion(Business.businesses(array: dictionaries!), nil)
        }
      }
      }, failure: { (operation: AFHTTPRequestOperation?, error: Error) in
        completion(nil, error)
    })!
  }
}

