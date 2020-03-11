//
//  UtilitiClass.swift
//  Marvel
//
//  Created by abhilash on 26/01/19.
//  Copyright © 2019 Komara. All rights reserved.
//

import UIKit
import SystemConfiguration
import AdSupport

let BaseURLDomains = "http://erp.dmiagrp.com/login/api/bio/domains"
var vSpinner : UIView?
let defaults = UserDefaults.standard


/// success block
public typealias AuthenticationSuccess = (() -> ())

/// failure block
public typealias AuthenticationFailure = ((AuthenticationError) -> ())

let kBiometryNotAvailableReason = "Biometric authentication is not available for this device."

/// ****************  Touch ID  ****************** ///

let kTouchIdAuthenticationReason = "Confirm your fingerprint to authenticate."
let kTouchIdPasscodeAuthenticationReason = "Touch ID is locked now, because of too many failed attempts. Enter passcode to unlock Touch ID."

/// Error Messages Touch ID
let kSetPasscodeToUseTouchID = "Please set device passcode to use Touch ID for authentication."
let kNoFingerprintEnrolled = "There are no fingerprints enrolled in the device. Please go to Device Settings -> Touch ID & Passcode and enroll your fingerprints."
let kDefaultTouchIDAuthenticationFailedReason = "Touch ID does not recognize your fingerprint. Please try again with your enrolled fingerprint."

/// ****************  Face ID  ****************** ///

let kFaceIdAuthenticationReason = "Confirm your face to authenticate."
let kFaceIdPasscodeAuthenticationReason = "Face ID is locked now, because of too many failed attempts. Enter passcode to unlock Face ID."

/// Error Messages Face ID
let kSetPasscodeToUseFaceID = "Please set device passcode to use Face ID for authentication."
let kNoFaceIdentityEnrolled = "There is no face enrolled in the device. Please go to Device Settings -> Face ID & Passcode and enroll your face."
let kDefaultFaceIDAuthenticationFailedReason = "Face ID does not recognize your face. Please try again with your enrolled face."



var EmpID : String? {
    set(newValue) {
        defaults.set(newValue, forKey: "employeeID")
        defaults.synchronize()
    } get {
        return defaults.value(forKey: "employeeID") as? String
    }
}

var empName : String? {
    set(newValue) {
        defaults.set(newValue, forKey: "employeeName")
        defaults.synchronize()
    } get {
        return defaults.value(forKey: "employeeName") as? String
    }
}

var isRegSuccess : Bool {
    set(newValue) {
        defaults.set(newValue, forKey: "regState")
        defaults.synchronize()
    } get {
        return defaults.bool(forKey: "regState")// value(forKey: "regState") as? String
    }
}

var identifierForAdvertising : String {
    return ASIdentifierManager.shared().advertisingIdentifier.uuidString
}

extension UIViewController {
    
    func alert(with title : String , message : String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func networkError() {
        self.alert(with: "Network", message: "you appear to be offline")
    }
    
    func showSpinner(onView : UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        vSpinner = spinnerView
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
            vSpinner?.removeFromSuperview()
            vSpinner = nil
        }
    }
}

func isConnectedToNetwork() -> Bool {
    
    var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
    zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
    zeroAddress.sin_family = sa_family_t(AF_INET)
    
    let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
            SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
        }
    }
    
    var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
    if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
        return false
    }
    
    /* Only Working for WIFI
     let isReachable = flags == .reachable
     let needsConnection = flags == .connectionRequired
     
     return isReachable && !needsConnection
     */
    
    // Working for Cellular and WIFI
    let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
    let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
    let ret = (isReachable && !needsConnection)
    
    return ret
    
}
