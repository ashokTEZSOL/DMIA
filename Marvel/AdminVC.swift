//
//  AdminVC.swift
//  Marvel
//
//  Created by abhilash on 02/02/19.
//  Copyright © 2019 Komara. All rights reserved.
//

import UIKit

class AdminVC: UIViewController {

    @IBOutlet weak var btn_regEmp: UIButton!
    @IBOutlet weak var btn_dereg: UIButton!
    
    var selectedDomain : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.btn_regEmp.layer.cornerRadius = 3
        self.btn_regEmp.clipsToBounds = true
        self.btn_dereg.layer.cornerRadius = 3
        self.btn_dereg.clipsToBounds = true
    }
    

    @IBAction func btn_reg_Action(_ sender: UIButton) {
        //coming soon
        ApiRequest.shared.registrationApproval(with: self.selectedDomain!, empId: EmpID!, deviceId: identifierForAdvertising) { (status) in
            if status {
                DispatchQueue.main.async {
                    self.navigationController?.popToRootViewController(animated: true)
                }
                self.alert(with: "Success", message: "Successfully approved")
            } else {
                self.alert(with: "Error", message: "something went wrong. Please try again.")
            }
        }
    }
    
    @IBAction func btn_deactive_Action(_ sender: UIButton) {
        self.showSpinner(onView: self.view)
        ApiRequest.shared.deregister(with: self.selectedDomain!, empId: EmpID!) { (status) in
            self.removeSpinner()
            if status {
                EmpID = nil
                empName = nil
                DispatchQueue.main.async {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            } else {
                self.alert(with: "Error", message: "something went wrong. Please try again.")
            }
        }
    }
    
}
