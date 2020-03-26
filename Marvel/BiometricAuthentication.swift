//
//  BiometricAuthentication.swift
//  Marvel
//
//  Created by abhilash on 02/02/19.
//  Copyright © 2019 Komara. All rights reserved.
//

import UIKit
import Foundation
import LocalAuthentication

class BiometricAuthenticate: NSObject {

    // MARK: - Singleton
    public static let shared = BiometricAuthenticate()
    
    // MARK: - Private
    private override init() {}
    private lazy var context: LAContext? = {
        return LAContext()
    }()
    
    // MARK: - Public
    public var allowableReuseDuration: TimeInterval? = nil {
        didSet {
            guard let duration = allowableReuseDuration else {
                return
            }
            if #available(iOS 9.0, *) {
                self.context?.touchIDAuthenticationAllowableReuseDuration = duration
            }
        }
    }
}

extension BiometricAuthenticate {
    
    /// checks if biometric authentication can be performed currently on the device.
    class func canAuthenticate() -> Bool {
        
        var isBiometricAuthenticationAvailable = false
        var error: NSError? = nil
        
        if LAContext().canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            isBiometricAuthenticationAvailable = (error == nil)
        }
        return isBiometricAuthenticationAvailable
    }
    
    /// Check for biometric authentication
    class func authenticateWithBioMetrics(reason: String, fallbackTitle: String? = "", cancelTitle: String? = "", success successBlock:@escaping AuthenticationSuccess, failure failureBlock:@escaping AuthenticationFailure) {
        
        // reason
        let reasonString = reason.isEmpty ? BiometricAuthenticate.shared.defaultBiometricAuthenticationReason() : reason
        
        // context
        var context: LAContext!
        if BiometricAuthenticate.shared.isReuseDurationSet() {
            context = BiometricAuthenticate.shared.context
        }else {
            context = LAContext()
        }
        context.localizedFallbackTitle = fallbackTitle
        
        // cancel button title
        if #available(iOS 10.0, *) {
            context.localizedCancelTitle = cancelTitle
        }
        
        // authenticate
        BiometricAuthenticate.shared.evaluate(policy: LAPolicy.deviceOwnerAuthenticationWithBiometrics, with: context, reason: reasonString, success: successBlock, failure: failureBlock)
    }
    
    /// Check for device passcode authentication
    class func authenticateWithPasscode(reason: String, cancelTitle: String? = "", success successBlock:@escaping AuthenticationSuccess, failure failureBlock:@escaping AuthenticationFailure) {
        
        // reason
        let reasonString = reason.isEmpty ? BiometricAuthenticate.shared.defaultPasscodeAuthenticationReason() : reason
        
        let context = LAContext()
        
        // cancel button title
        if #available(iOS 10.0, *) {
            context.localizedCancelTitle = cancelTitle
        }
        
        // authenticate
        if #available(iOS 9.0, *) {
            BiometricAuthenticate.shared.evaluate(policy: LAPolicy.deviceOwnerAuthentication, with: context, reason: reasonString, success: successBlock, failure: failureBlock)
        } else {
            // Fallback on earlier versions
            BiometricAuthenticate.shared.evaluate(policy: LAPolicy.deviceOwnerAuthenticationWithBiometrics, with: context, reason: reasonString, success: successBlock, failure: failureBlock)
        }
    }
    
    /// checks if device supports face id authentication
    public func faceIDAvailable() -> Bool {
        if #available(iOS 11.0, *) {
            let context = LAContext()
            return (context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: nil) && context.biometryType == .faceID)
        }
        return false
    }
    
    /// checks if device supports touch id authentication
    public func touchIDAvailable() -> Bool {
        let context = LAContext()
        var error: NSError?
        
        let canEvaluate = context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error)
        if #available(iOS 11.0, *) {
            return canEvaluate && context.biometryType == .touchID
        }
        return canEvaluate
    }
	
	public func passcodeIsAvailable() -> Bool {
		return LAContext().canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
	}
}

// MARK:- Private
extension BiometricAuthenticate {
    
    /// get authentication reason to show while authentication
    private func defaultBiometricAuthenticationReason() -> String {
        return faceIDAvailable() ? kFaceIdAuthenticationReason : kTouchIdAuthenticationReason
    }
    
    /// get passcode authentication reason to show while entering device passcode after multiple failed attempts.
    private func defaultPasscodeAuthenticationReason() -> String {
        return faceIDAvailable() ? kFaceIdPasscodeAuthenticationReason : kTouchIdPasscodeAuthenticationReason
    }
    
    /// checks if allowableReuseDuration is set
    private func isReuseDurationSet() -> Bool {
        guard allowableReuseDuration != nil else {
            return false
        }
        return true
    }
    
    /// evaluate policy
    private func evaluate(policy: LAPolicy, with context: LAContext, reason: String, success successBlock:@escaping AuthenticationSuccess, failure failureBlock:@escaping AuthenticationFailure) {
        
        context.evaluatePolicy(policy, localizedReason: reason) { (success, err) in
            DispatchQueue.main.async {
                if success { successBlock() }
                else {
                    let errorType = AuthenticationError.initWithError(err as! LAError)
                    failureBlock(errorType)
                }
            }
        }
    }
}


/// Authentication Errors
public enum AuthenticationError: Error {
    
    case failed, canceledByUser, fallback, canceledBySystem, passcodeNotSet, biometryNotAvailable, biometryNotEnrolled, biometryLockedout, other
    
    public static func initWithError(_ error: LAError) -> AuthenticationError {
        switch Int32(error.errorCode) {
            
        case kLAErrorAuthenticationFailed:
            return failed
        case kLAErrorUserCancel:
            return canceledByUser
        case kLAErrorUserFallback:
            return fallback
        case kLAErrorSystemCancel:
            return canceledBySystem
        case kLAErrorPasscodeNotSet:
            return passcodeNotSet
        case kLAErrorBiometryNotAvailable:
            return biometryNotAvailable
        case kLAErrorBiometryNotEnrolled:
            return biometryNotEnrolled
        case kLAErrorBiometryLockout:
            return biometryLockedout
        default:
            return other
        }
    }
    
    // get error message based on type
    public func message() -> String {
        let authentication = BiometricAuthenticate.shared
        
        switch self {
        case .canceledByUser, .fallback, .canceledBySystem:
            return ""
        case .passcodeNotSet:
            return authentication.faceIDAvailable() ? kSetPasscodeToUseFaceID : kSetPasscodeToUseTouchID
        case .biometryNotAvailable:
            return kBiometryNotAvailableReason
        case .biometryNotEnrolled:
            return authentication.faceIDAvailable() ? kNoFaceIdentityEnrolled : kNoFingerprintEnrolled
        case .biometryLockedout:
            return authentication.faceIDAvailable() ? kFaceIdPasscodeAuthenticationReason : kTouchIdPasscodeAuthenticationReason
        default:
            return authentication.faceIDAvailable() ? kDefaultFaceIDAuthenticationFailedReason : kDefaultTouchIDAuthenticationFailedReason
        }
    }
}
