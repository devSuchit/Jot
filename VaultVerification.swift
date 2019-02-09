//
//  VaultVerification.swift
//  Jot.
//
//  Created by Suchit on 17/07/17.
//  Copyright © 2017 Suchit. All rights reserved.
//

import UIKit
import LocalAuthentication

class VaultVerification: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let hasLogin = UserDefaults.standard.bool(forKey: "hasLoginKey")
        
        // 2.
        if hasLogin {
            loginButton.setTitle("LOGIN", for: UIControlState.normal)
            loginButton.tag = loginButtonTag
        } else {
            loginButton.setTitle("CREATE", for: UIControlState.normal)
            loginButton.tag = createLoginButtonTag
        }
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func touchIdBtnPressed(_ sender: Any) {
        
        let  authenticationContext = LAContext()
        var error: NSError?
        
        if authenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error:
            &error){
            authenticationContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Please Authenticate With Fingerprint To Continue", reply: { (success, error) in
                if success{
                    self.navigateToAuthenticatedVC()
                }else{
                    if let error = error as NSError?{
                        let message = self.errorMessageForLAErrorCode(errorCode: error.code)
                        self.showAlertViewAfterEvaluatingPolicyWithMessage(message: message)
                    }
                }
            })
            
        }
        else{
            showAlertViewForNoBiometrics()
            return
        }
        
    }
    
    func errorMessageForLAErrorCode(errorCode: Int)  -> String{
        var message = ""
        
        switch errorCode {
        case LAError.appCancel.rawValue:
            message = "Authentication was cancelled by the application"
        case LAError.authenticationFailed.rawValue:
            message = "The user failed to provide valid credentials"
        case LAError.invalidContext.rawValue:
            message = "The context is invalid"
        case LAError.passcodeNotSet.rawValue:
            message = "Passcode not set on the device"
        case LAError.systemCancel.rawValue:
            message = "Authentication was cancelled by the system"
        case LAError.touchIDLockout.rawValue:
            message = "Too many failed attempts"
        case LAError.touchIDNotAvailable.rawValue:
            message = "Touch ID is not available on this device"
        case LAError.userFallback.rawValue:
            message = "User chose to fallback"
        default:
            message = "Error Not Available"
        }
        return message
    }
    
    func showAlertViewAfterEvaluatingPolicyWithMessage(message: String){
        if message != "Error Not Available"
        {
           showAlertWithTitle(title: "Error", message: message)
        }
    }
    
    func navigateToAuthenticatedVC()
    {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "VaultVCVerified", sender: AnyObject.self)
        }
    }
    
    func showAlertViewForNoBiometrics()
    {
        showAlertWithTitle(title: "Touch ID Not Available", message: "This device does not support Touch ID Authentication")
    }
    
    func showAlertWithTitle(title: String , message: String){
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alertVC.addAction(okAction)
        DispatchQueue.main.async {
            self.present(alertVC, animated: true, completion: nil)
        }
    }
    
    func checkLogin(password: String ) -> Bool {
        if password == MyKeychainWrapper.myObject(forKey: "v_Data") as? String{
            return true
        } else {
            return false
        }
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    let MyKeychainWrapper = KeychainWrapper()
    let createLoginButtonTag = 0
    let loginButtonTag = 1
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func loginAction(sender: AnyObject) {
        
        // 1.
        if (passwordTextField.text == "") {
            let alertView = UIAlertController(title: "Login Issue",
                                              message: "Please Enter Password" as String, preferredStyle:.alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertView.addAction(okAction)
            self.present(alertView, animated: true, completion: nil)
            return
        }
        
        // 2.
        passwordTextField.resignFirstResponder()
        
        // 3.
        if sender.tag == createLoginButtonTag {
            
            
            // 5.
            MyKeychainWrapper.mySetObject(passwordTextField.text, forKey:kSecValueData)
            MyKeychainWrapper.writeToKeychain()
            UserDefaults.standard.set(true, forKey: "hasLoginKey")
            UserDefaults.standard.synchronize()
            loginButton.tag = loginButtonTag
            passwordTextField.text = ""
            performSegue(withIdentifier: "VaultVCVerified", sender: self)
        } else if sender.tag == loginButtonTag {
            // 6.
            if checkLogin(password: passwordTextField.text!) {
                performSegue(withIdentifier: "VaultVCVerified", sender: self)
                passwordTextField.text = ""

            } else {
                // 7.
                let alertView = UIAlertController(title: "Login Issue",
                                            message: "Wrong Password" as String, preferredStyle:.alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertView.addAction(okAction)
                self.present(alertView, animated: true, completion: nil)
            }
        }
    }    


}
