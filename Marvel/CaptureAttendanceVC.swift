//
//  CaptureAttendanceVC.swift
//  Marvel
//
//  Created by abhilash on 27/01/19.
//  Copyright © 2019 Komara. All rights reserved.
//

import UIKit
import LocalAuthentication


class CaptureAttendanceVC: UIViewController {

    @IBOutlet weak var txt_empID: UITextField!
    @IBOutlet weak var lbl_ErrorDisplay: UILabel!
    
    var selectedDomain : String?
    var isRequested : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.txt_empID.text = "Emp ID - \(EmpID!)"
        self.txt_empID.isUserInteractionEnabled = false
        self.lbl_ErrorDisplay.text = "Please place your Bio-Metric Authentication"
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // authentication
        BiometricAuthenticate.shared.allowableReuseDuration = 60
        
        if BiometricAuthenticate.shared.touchIDAvailable() || BiometricAuthenticate.shared.faceIDAvailable() {
            
            BiometricAuthenticate.authenticateWithBioMetrics(reason: "To capture attendance", fallbackTitle: "", cancelTitle: "Cancel", success: {
                // authentication success
                if self.isRequested == true {
                    // request for registration
                    self.requestForReg()
                } else {
                    // capture attendance
                    self.successAuthentication()
                }
                
            }) { [weak self] (error) in
                // do nothing on canceled
                if error == .canceledByUser || error == .canceledBySystem {
                    return
                }
                // device does not support biometric (face id or touch id) authentication
                else if error == .biometryNotAvailable {
                    self?.alert(with: "Error", message: error.message())//self?.showErrorAlert(message: error.message())
                }
                    
                    // show alternatives on fallback button clicked
                else if error == .fallback {
                    // here we're entering username and password
                    self?.alert(with: "Error", message: "Something went wrong. Please try again.")
                }
                    
                    // No biometry enrolled in this device, ask user to register fingerprint or face
                else if error == .biometryNotEnrolled {
                    self?.alert(with: "Error", message: error.message())
                }
                    // Biometry is locked out now, because there were too many failed attempts.
                    // Need to enter device passcode to unlock.
                else if error == .biometryLockedout {
                    self?.alert(with: "Error", message: error.message())
                } else {
                    self?.alert(with: "Error", message: error.message())
                }
            }
        } else {
            self.alert(with: "Error", message: "Device doesn't support biometric")
        }
    }
    
    
    func successAuthentication() {
        
        let app = UIApplication.shared.delegate as! AppDelegate
        ApiRequest.shared.attendance(with: self.selectedDomain!, empId: EmpID!, deviceId: identifierForAdvertising, lat: app.lat!, lng: app.lng!) { (status) in
            if status {
                self.alert(with: "Success", message: "Successfully captured attendance")
            } else {
                self.alert(with: "Error", message: "Something went wrong. Please try again.")
            }
        }
    }
    
    func requestForReg() {
        self.showSpinner(onView: self.view)
        ApiRequest.shared.registerRequest(with: self.selectedDomain!, empId: Int(EmpID!)!, deviceID: identifierForAdvertising) { (status) in
            self.removeSpinner()
            if status {
                DispatchQueue.main.async {
                    self.navigationController?.popToRootViewController(animated: true)
                }
                isRegSuccess = true
                self.alert(with: "SUCCESS", message: "Registration success")
            } else {
                isRegSuccess = false
                self.alert(with: "Error", message: "Something went wrong. Please try again.")
            }
        }
    }
}
