//
//  ApiRequest.swift
//  Marvel
//
//  Created by abhilash on 26/01/19.
//  Copyright © 2019 Komara. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ApiRequest: NSObject {
    
    static let shared = ApiRequest()
    
    
    func getDomains(_ callback : @escaping (_ domains : [Domains]?) -> Void) {
        Alamofire.request(BaseURLDomains).responseJSON { (response) in
            print(response)
            if let code = response.response?.statusCode , code <= 300 || code >= 200 {
                let domains = Domains.domains(with: response.data)
                callback(domains)
            } else {
                callback(nil)
            }
        }
    }
    
    func login(with domain : String, name : String , password : String , callback : @escaping (_ state : Bool) -> Void) {
        let url = "http://\(domain)/Login/api/bio/admin?"
        Alamofire.request(url,method: .get, parameters: ["userName" : name , "password" :password], encoding: URLEncoding.default, headers: [:]).response { (response) in
            if let code = response.response?.statusCode , code <= 300 || code >= 200 {
                callback(true)
            } else {
                callback(false)
            }
        }
    }
    
    func searchApi(with domain : String , keyWord : String , callback : @escaping (_ employees : [Employee]?) -> Void) {
        //http://adc.6dproptech.com/Login/api/bio/fetchID?EmployeeNameSearchString=reddy%20kumar
        let url = "http://\(domain)/Login/api/bio/fetchID?"
        Alamofire.request(url,method: .get, parameters: ["EmployeeNameSearchString" : keyWord], encoding: URLEncoding.default, headers: [:]).response { (response) in
            if let code = response.response?.statusCode , code <= 300 || code >= 200 {
                callback(Employee.employees(with: response.data))
            } else {
                callback(nil)
            }
        }
    }
    
    func registerRequest(with domain : String , empId : Int , deviceID : String , callback : @escaping (_ status : Bool) -> Void) {
        let url = "http://\(domain)/Login/api/bio/register?"
        Alamofire.request(url,method: .get, parameters: ["fingerprintvalue" : deviceID , "empID" : empId], encoding: URLEncoding.default, headers: [:]).response { (response) in
            if let code = response.response?.statusCode , code <= 300 || code >= 200 {
                if let data = response.data, let json = try? JSON(data: data) , let codeStr = json["Status"].string , let codeInt = Int(codeStr) , codeInt <= 300 || codeInt >= 200 {
                    callback(true)
                } else {
                    callback(false)
                }
            } else {
                callback(false)
            }
        }
    }
    
    func registrationApproval(with domain : String, empId : String , deviceId : String , callback : @escaping (_ status : Bool) -> Void ) {
        let url = "http://\(domain)/Login/api/bio/registrationApproval?"
        Alamofire.request(url,method: .get, parameters: ["fingerprintvalue" : deviceId , "empID" : empId], encoding: URLEncoding.default, headers: [:]).response { (response) in
            if let code = response.response?.statusCode , code <= 300 || code >= 200 {
                callback(true)
            } else {
                callback(false)
            }
        }
    }
    
    func deregister(with domain : String , empId : String , callback : @escaping (_ status : Bool) -> Void) {
        let url = "http://\(domain)/Login/api/bio/deregister?"
        Alamofire.request(url,method: .get, parameters: ["empID" : empId], encoding: URLEncoding.default, headers: [:]).response { (response) in
            if let code = response.response?.statusCode , code <= 300 || code >= 200 {
                callback(true)
            } else {
                callback(false)
            }
        }
        //http:// adc.6dproptech.com /Login/api/bio/deregister?empID=12
    }
    
    func attendance(with domain : String , empId : String , deviceId : String , lat : Double , lng : Double , callback :@escaping (_ status : Bool) -> ()) {
        let url = "http://\(domain)/Login/api/bio/check?"
        let parameters = ["empID" : empId,
                          "fingerprintvalue" : deviceId,
                          "lat" : lat,
                          "lng" : lng
            ] as [String : Any]
        Alamofire.request(url,method: .get, parameters: parameters, encoding: URLEncoding.default, headers: [:]).response { (response) in
            if let code = response.response?.statusCode , code <= 300 || code >= 200 {
                callback(true)
            } else {
                callback(false)
            }
        }
    }

}
