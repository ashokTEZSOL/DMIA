//
//  Employee.swift
//  Marvel
//
//  Created by abhilash on 02/02/19.
//  Copyright © 2019 Komara. All rights reserved.
//

import UIKit
import SwiftyJSON

class Employee: NSObject {

    var ID : Int!
    var Name : String!
    
    class func employees(with data : Data?) -> [Employee]? {
        
        if let jsonData = data , let jsonArr = try? JSON(data: jsonData).array , jsonArr != nil , jsonArr!.count > 0 {
            var employees : [Employee] = []
            for obj in jsonArr! {
                let emp = Employee()
                emp.ID = obj["ID"].int ?? 0
                emp.Name = obj["Name"].string ?? ""
                employees.append(emp)
            }
            return employees
        }
        return nil
    }
}
