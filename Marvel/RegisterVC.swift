//
//  LoginVC.swift
//  Marvel
//
//  Created by abhilash on 26/01/19.
//  Copyright © 2019 Komara. All rights reserved.
//

import UIKit
import iOSDropDown

class RegisterVC : UIViewController {
    
    @IBOutlet weak var btn_Submit : UIButton!
    @IBOutlet weak var txt_search: DropDown!
    @IBOutlet weak var lbl_Emp: UILabel!
    
    
    var selectedDomain : String?
    var employees : [Employee] = []
    var empNames : [String] = []
    var isShowing : Bool = false
    
    var selectedEmp : Employee?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.btn_Submit.layer.cornerRadius = 3
        self.btn_Submit.clipsToBounds = true
        self.txt_search.delegate = self
		self.txt_search.textColor = UIColor.black
		self.lbl_Emp.textColor = .black
        self.txt_search.rowHeight = 50
        self.txt_search.arrowSize = 0
        
        txt_search.didSelect{(selectedText , index ,id) in
            if self.employees.count > index {
                self.selectedEmp = self.employees[index]
                self.lbl_Emp.text = "EmpID : \(self.selectedEmp!.ID!)"
            }
        }
        
        txt_search.listWillAppear {
            self.isShowing = true
        }
        
        txt_search.listDidAppear {
            self.isShowing = true
        }
        
        txt_search.listDidDisappear {
            self.isShowing = false
        }
    }
    
    func searchServiceCall() {
        if self.txt_search.hasText && self.txt_search.text!.count > 0 {
            self.empNames.removeAll()
            self.showSpinner(onView: self.view)
            ApiRequest.shared.searchApi(with: self.selectedDomain!, keyWord: self.txt_search.text!) { (employees) in
                self.removeSpinner()
                if let emps = employees {
                    self.employees = emps
                } else {
                    self.employees.removeAll()
                }
                for obj in self.employees {
                    self.empNames.append("\(obj.ID!) - \(obj.Name!)")
                }
                self.txt_search.optionArray = self.empNames
                self.txt_search.showList()
            }
        }
    }
    
    @IBAction func btn_LoginAction(_ sender: UIButton) {
        
        if self.loginValidations() {
            EmpID = "\(self.selectedEmp!.ID!)"
            empName = self.selectedEmp!.Name!
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "reqAttendance", sender: nil)
            }
        }
    }
    
    func loginValidations() -> Bool {
        if !isConnectedToNetwork() {
            self.networkError()
            return false
        } else if !self.txt_search.hasText && self.txt_search.text!.count <= 0 {
            self.alert(with: "Alert", message: "Please select Employee")
            return false
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "reqAttendance" {
            let vc = segue.destination as! CaptureAttendanceVC
            vc.selectedDomain = self.selectedDomain
            vc.isRequested = true
        }
    }
}

extension RegisterVC : UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if self.isShowing {
            self.txt_search.hideList()
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.searchServiceCall()
    }
}
