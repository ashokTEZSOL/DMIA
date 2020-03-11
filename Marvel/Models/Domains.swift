//
//  Domains.swift
//  Marvel
//
//  Created by abhilash on 28/01/19.
//  Copyright © 2019 Komara. All rights reserved.
//

import UIKit
import SwiftyJSON

class Domains: NSObject {
    
    var DB : String!
    var Domain : String!
    
    class func domains(with data : Data?) -> [Domains]? {
        
        if let jsonData = data , let jsonArr = try? JSON(data: jsonData).array , jsonArr != nil , jsonArr!.count > 0 {
            var domains : [Domains] = []
            for obj in jsonArr! {
                let dom = Domains()
                dom.DB = obj["db"].string ?? ""
                dom.Domain = obj["domain"].string ?? ""
                domains.append(dom)
            }
            return domains
        }
        return nil
    }

}
