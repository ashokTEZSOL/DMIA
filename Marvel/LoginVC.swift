//
//  LoginVC.swift
//  Marvel
//
//  Created by abhilash on 03/02/19.
//  Copyright © 2019 Komara. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {

    
    @IBOutlet weak var txt_userName: UITextField!
    @IBOutlet weak var txt_Password: UITextField!
    @IBOutlet weak var btn_login: UIButton!
    
    var selectedDomain : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.btn_login.layer.cornerRadius = 3
        self.btn_login.clipsToBounds = true
        
    }
    
    @IBAction func btnLogin_Action(_ sender: UIButton) {
        if self.loginValidations() {
            ApiRequest.shared.login(with: self.selectedDomain!, name: self.txt_userName.text!, password: self.txt_Password.text!) { (status) in
                if status {
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "adminPageSeg", sender: nil)
                    }
                } else {
                    self.alert(with: "Error", message: "Something went wrong. Please try again.")
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "adminPageSeg" {
            let vc = segue.destination as! AdminVC
            vc.selectedDomain = self.selectedDomain
        }
    }
    func loginValidations() -> Bool{
        if !self.txt_userName.hasText || self.txt_userName.text!.count <= 0 {
            self.alert(with: "Error", message: "Please enter UserName/Email")
            return false
        } else if !self.txt_Password.hasText || self.txt_Password.text!.count <= 0 {
            self.alert(with: "Error", message: "Please enter Password")
            return false
        }
        return true
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
