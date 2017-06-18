//
//  SignInVC.swift
//  devslopes-social
//
//  Created by Hung Nguyen on 6/13/17.
//  Copyright © 2017 Luvdub Nation. All rights reserved.
//

import UIKit
import FacebookLogin
import FacebookCore
import Firebase
import SwiftKeychainWrapper

class SignInVC: UIViewController, LoginButtonDelegate {
    
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var pwdField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID) {
            performSegue(withIdentifier: "goToFeed", sender: nil)
        }
        
        emailField.clearButtonMode = .whileEditing
        pwdField.clearButtonMode = .whileEditing

        
        
    }
    
    
    
//    override func viewDidAppear(_ animated: Bool) {
//        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID) {
//            
//            performSegue(withIdentifier: "goToFeed", sender: nil)
//        }
//    }

    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        print("Did log out of facebook")
    }
    
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        if result != nil {
            print("Yay")
        
        }
    }

    @IBAction func fbButton(_ sender: Any) {
        
        
        loginButtonClicked()
        
        
        
    }


    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func dissmissKeyboard() {
        view.endEditing(true)
    }

  
    @objc func loginButtonClicked() {
        let loginManager = LoginManager()
        let loginButton = LoginButton(readPermissions: [.publicProfile])
        loginButton.delegate = self
        
        if AccessToken.current?.authenticationToken != nil {
            loginManager.logOut()
        }
        
        loginManager.logIn([ .email ], viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                print("Logged in! \(grantedPermissions)")
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: (AccessToken.current!.authenticationToken))
                firebaseAuth(credential)
            }
        }
        
    
        func firebaseAuth(_ credential: FIRAuthCredential) {
            FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
                if error != nil {
                    print("Unable to authenticate with Firebase = \(error)")
                } else {
                    print("Successfully authenticated with Firebase")
                    if let user = user {
                        let userData = ["provider": credential.provider]
                    self.completeSignIn(id: user.uid, userData: userData)
                    }
                }
            })
        }
    
    

    }

    @IBAction func signInTapped(_ sender: Any) {
        if let email = emailField.text, let pwd = pwdField.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: pwd, completion: { (user, error) in
                if error == nil {
                    print("Email user authenticated with Firebase")
                    if let user = user {
                        let userData = ["provider": user.providerID]
                        self.completeSignIn(id: user.uid, userData: userData)
                    }
                } else {
                    FIRAuth.auth()?.createUser(withEmail: email, password: pwd, completion: { (user, error) in
                        if error != nil {
                            print("Unable to authenticate with Firebase using email")
                        } else {
                            print("Successfully authenticated with Firebase")
                            if let user = user {
                                let userData = ["provider": user.providerID]
                                self.completeSignIn(id: user.uid, userData: userData)
                            }
                        }
                    })
                    
                }
            })
        }
        
    }
    
    func completeSignIn(id: String, userData: Dictionary<String, String>) {
        DataService.ds.createFirbaseDBUser(uid: id, userData: userData)
        let keychainResult = KeychainWrapper.standard.set(id, forKey: KEY_UID)
        print("Data saved to keychain \(keychainResult)")
        performSegue(withIdentifier: "goToFeed", sender: nil)
    }
    
}

extension UITextField {
    func animateViewMoving (up: Bool, moveValue: CGFloat, view: UIView) {
        let movementDuration: TimeInterval = 0.3
        let movement: CGFloat = (up ? -moveValue : moveValue)
        UIView.beginAnimations("animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        view.frame = view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
}
    
    
}


