//
//  ViewController.swift
//  Marvel
//
//  Created by abhilash on 26/01/19.
//  Copyright © 2019 Komara. All rights reserved.
//

import UIKit
import CoreLocation
import iOSDropDown


class ViewController: UIViewController {

    @IBOutlet weak var btn_rgrister: UIButton!
    @IBOutlet weak var btn_capture: UIButton!
    @IBOutlet weak var btn_Admin: UIButton!
    @IBOutlet weak var txt_DroapDown: DropDown!
    
    var domains : [Domains] = []
    var domainNameStr : [String] = []
    var selectedDomain : Int = 0
    let locationMgr = CLLocationManager()
    var isDisplaying = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
		self.txt_DroapDown.textColor = .black
        self.btn_rgrister.layer.cornerRadius = 3
        self.btn_rgrister.clipsToBounds = true
        self.btn_capture.layer.cornerRadius = 3
        self.btn_capture.clipsToBounds = true
        self.btn_Admin.layer.cornerRadius = 3
        self.btn_Admin.clipsToBounds = true
        self.txt_DroapDown.delegate = self
        self.txt_DroapDown.rowHeight = 50
        
        self.showSpinner(onView: self.view)
        ApiRequest.shared.getDomains { (domain) in
            self.removeSpinner()
            if let dom = domain {
                self.domains = dom
                for (index,obj) in self.domains.enumerated() {
                    if obj.DB.lowercased() == "ERP".lowercased() {
						self.selectedDomain = index
						DispatchQueue.main.async {
							print(obj.DB)
							self.txt_DroapDown.text = obj.DB
							self.txt_DroapDown.isUserInteractionEnabled = false
						}
                    }
//                    self.domainNameStr.append(obj.DB)
                }
                self.txt_DroapDown.optionArray = self.domainNameStr
            } else {
                // error
                self.alert(with: "Error", message: "Something went wrong. Please try again.")
            }
        }
        
        txt_DroapDown.didSelect{(selectedText , index ,id) in
            self.selectedDomain = index
            self.txt_DroapDown.text = self.domains[self.selectedDomain].DB
        }
        
        txt_DroapDown.listWillAppear {
            self.isDisplaying = true
        }
        txt_DroapDown.listDidAppear {
            self.isDisplaying = true
        }
        
        txt_DroapDown.listDidDisappear {
            self.isDisplaying = false
        }
        
        self.getLocation()
        
        if !isRegSuccess {
            EmpID = nil
            empName = nil
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if EmpID == nil {
            self.btn_rgrister.isUserInteractionEnabled = true
            self.btn_capture.isUserInteractionEnabled = false
            self.btn_Admin.isUserInteractionEnabled = false
            self.btn_capture.alpha = 0.5
            self.btn_Admin.alpha = 0.5
            self.btn_rgrister.alpha = 1
        } else {
            self.btn_rgrister.isUserInteractionEnabled = false
            self.btn_capture.isUserInteractionEnabled = true
            self.btn_Admin.isUserInteractionEnabled = true
            self.btn_capture.alpha = 1
            self.btn_Admin.alpha = 1
            self.btn_rgrister.alpha = 0.5
        }
        
        if let id = EmpID , let name = empName, isRegSuccess {
            self.btn_rgrister.setTitle("\(id) - \(name)", for: .normal)
        } else {
            self.btn_rgrister.setTitle("Registration", for: .normal)
        }
    }
    
    @IBAction func btn_registerAction(_ sender: UIButton) {
        if EmpID != nil {
            self.alert(with: "Warning", message: "Only one user can register with one device, so please deactivate your account and register with other employee")
        }
        if !self.txt_DroapDown.hasText || self.txt_DroapDown.text!.count <= 0 {
            self.alert(with: "Alert", message: "Please select company service")
            return
        }
        self.performSegue(withIdentifier: "loginsegue", sender: nil)
    }
    
    @IBAction func btn_captureAction(_ sender: UIButton) {
        let app = UIApplication.shared.delegate as! AppDelegate
        
        if app.lat == nil || app.lng == nil {
            self.getLocation()
            alert(with: "Location", message: "Loading locations...")
            return
        }
        if !self.txt_DroapDown.hasText || self.txt_DroapDown.text!.count <= 0 {
            self.alert(with: "Alert", message: "Please select company service")
            return
        }
        self.performSegue(withIdentifier: "attendanceSeg", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "loginsegue" {
            let vc = segue.destination as! RegisterVC
            vc.selectedDomain = self.domains[selectedDomain].Domain
        } else if segue.identifier == "attendanceSeg" {
            let vc = segue.destination as! CaptureAttendanceVC
            vc.selectedDomain = self.domains[selectedDomain].Domain
        } else if segue.identifier == "adminSeg" {
            let vc = segue.destination as! LoginVC
            vc.selectedDomain = self.domains[selectedDomain].Domain
        }
    }
    
    @IBAction func btn_admin(_ sender: UIButton) {
        if !self.txt_DroapDown.hasText || self.txt_DroapDown.text!.count <= 0 {
            self.alert(with: "Alert", message: "Please select company service")
            return
        }
        if EmpID == nil {
            return
        }
        self.performSegue(withIdentifier: "adminSeg", sender: nil)
    }
    
    
    func getLocation() {
        let status  = CLLocationManager.authorizationStatus()
        if status == .notDetermined {
            locationMgr.requestWhenInUseAuthorization()
            return
        }
        if status == .denied || status == .restricted {
            let alertController = UIAlertController (title: "Location Services", message: "Please enable Location Services in Settings", preferredStyle: .alert)
            let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                            print("Settings opened: \(success)") // Prints true
                        })
                    } else {
                        UIApplication.shared.openURL(settingsUrl)
                        // Fallback on earlier versions
                    }
                }
            }
            alertController.addAction(settingsAction)
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
            return
        }
        locationMgr.delegate = self
        locationMgr.startUpdatingLocation()
    }
}

extension ViewController : CLLocationManagerDelegate , UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if self.domains.count > 0 {
            self.isDisplaying = true
            self.txt_DroapDown.showList()
        }
        return false
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation = locations.last!
        print("Current location: \(currentLocation)")
        let app = UIApplication.shared.delegate as! AppDelegate
        app.lat = currentLocation.coordinate.latitude
        app.lng = currentLocation.coordinate.longitude
        self.locationMgr.stopUpdatingLocation()
    }
    
    // 2
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
        self.alert(with: "Location", message: error.localizedDescription)
    }
}

