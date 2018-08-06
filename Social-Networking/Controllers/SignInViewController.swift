//
//  ViewController.swift
//  Social-Networking
//
//  Created by macos on 8/1/18.
//  Copyright © 2018 macos. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import FirebaseAuth

class SignInViewController: UIViewController {

    @IBOutlet weak var emailText: FancyFieldView!
    @IBOutlet weak var passwordText: FancyFieldView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func facebookBtn(_ sender: AnyObject) {
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if error != nil {
                print("Jess: Unable to authentication with Facebook - \(String(describing: error))")
            } else if result?.isCancelled == true {
                print("Jess: Unable cancelled Facebook authentication")
            } else {
                print("Jess: Successfully authenticated with Facebook")
                let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.firebaseAuth(credential)
            }
        }
    }
    
    func firebaseAuth(_ credential: AuthCredential) {
        Auth.auth().signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print("Jess: Unable to authenticate with Firebase - \(String(describing: error))")
            } else {
                print("Jess: Successfully authenticated with Firebase")
                if let user = user {
                    let userData = ["provider": credential.provider]
                    self.completeSignIn(id: user.uid, userData: userData)
                }
            }
        })
    }
    
    @IBAction func signInBtn(_ sender: Any) {
        if let email = emailText.text, let pass = passwordText.text {
            Auth.auth().signIn(withEmail: email, password: pass, completion: { (user, error) in
                if error == nil {
                    print("Jess: Email user authenticate with Firebase")
//                    if let user = user {
//                        let userData = ["provider": user.user]
//                        self.completeSignIn(id: , userData: userData)
//                    }
                } else {
                    Auth.auth().createUser(withEmail: email, password: pass, completion: { (user, error) in
                        if error != nil {
                            print("Jess: Unable to authenticate with Firebase using email")
                        } else {
                            print("Jess: Successfully authenticated with Firebase")
//                            if let user = user {
//                                let userData = ["provider": user.user]
//                                self.completeSignIn(id: user.uid, userData: userData)
//                            }
                        }
                    })
                }
            })
        }
        
    }
    
    func completeSignIn(id: String, userData: Dictionary<String, String>) {
        DataService.db.createFirebaseDBUser(uid: id, userData: userData)
        performSegue(withIdentifier: "goToFeed", sender: nil)
    }
}

