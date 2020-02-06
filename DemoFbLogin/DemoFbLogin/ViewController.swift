//
//  ViewController.swift
//  DemoFbLogin
//
//  Created by Soumen on 23/01/20.
//  Copyright © 2020 Soumen. All rights reserved.
//

import UIKit
import FacebookLogin
import FacebookCore
import GoogleSignIn

class ViewController: UIViewController, GIDSignInDelegate {
    @IBOutlet weak var signInButton: GIDSignInButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().delegate = self

        GIDSignIn.sharedInstance()?.presentingViewController = self

        // Automatically sign in the user.
        GIDSignIn.sharedInstance()?.restorePreviousSignIn()

    }
    func loginManagerDidComplete(_ result: LoginResult) {
        let alertController: UIAlertController
        switch result {
        case .cancelled:
            alertController = UIAlertController(title: "Login Cancelled", message: "User cancelled login.", preferredStyle: .alert)
        case .failed(let error):
            alertController = UIAlertController(title: "Login Fail", message: "Login failed with error \(error)", preferredStyle: .alert)

        case .success(let grantedPermissions, let declinedPermission , let accesstoken):
            alertController = UIAlertController(title: "Login Success", message: "Login succeeded with granted permissions: \(grantedPermissions), \(declinedPermission), \(accesstoken)", preferredStyle: .alert)
            print("Fb login :\(grantedPermissions.debugDescription), \(declinedPermission), \(accesstoken)")
            self.getFacebookProfileInfo()
        }
       // self.present(alertController, animated: true, completion: nil)
    }

    @IBAction private func loginWithReadPermissions() {
        let loginManager = LoginManager()
        loginManager.logIn(
            permissions: [.publicProfile, .userFriends],
            viewController: self
        ) { result in
            self.loginManagerDidComplete(result)
        }
    }

    @IBAction private func logOut() {
        let loginManager = LoginManager()
        loginManager.logOut()
        let alertController = UIAlertController(title: "Logout", message: "Logged out.", preferredStyle: .alert)
        present(alertController, animated: true, completion: nil)
    }

    func getFacebookProfileInfo() {
       // self.av.startAnimating()
       // let parameters = ["fields": "id, email, name, first_name, last_name, age_range, link, gender, locale, timezone, picture, updated_time, verified"]
        GraphRequest.init(graphPath: "me", parameters: ["fields": "id, name, email, age_range, locale, timezone"]).start { (connection, result, error) in
            if((error == nil)){
                print("Facebook login resp: \(String(describing: result))")
                //FB Login
                let dicResult = result as? NSDictionary
                var strFBUserID = ""
                if let uId = dicResult?["id"]{
                    strFBUserID = "\(uId)"
                }
                var strFBEMail = ""
                if let email = dicResult?["email"] as? String{
                    strFBEMail = email
                }
                var strFBName = ""
                if let fbname = dicResult?["name"] as? String{
                    strFBName = fbname
                }
                var strFBageRange = ""
                if let dicAgeRange = dicResult?["age_range"] as? NSDictionary{
                    if let age = dicAgeRange["min"]{
                        strFBageRange = "\(age)"
                    }
                }

                var strFBLocale = ""
                if let strLocal = dicResult?["locale"] as? String{
                    strFBLocale = strLocal
                }
                var strFBtimezone = ""
                if let tmZone = dicResult?["timezone"] as? String{
                    strFBtimezone = tmZone
                }

                self.performSegue(withIdentifier: "home", sender: self)
            }else{
                //self.av.stopAnimating()
                let controller = UIAlertController(title: "", message: "Facebook login can't be completed right now. Please try after some time.", preferredStyle: .alert)
                self.present(controller, animated: true) {}
                
            }
            
        }
        
    }
    
    
     func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
               withError error: Error!) {
       if let error = error {
         if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
           print("The user has not signed in before or they have since signed out.")
         } else {
           print("\(error.localizedDescription)")
         }
         return
       }
         func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
                   withError error: Error!) {
           // Perform any operations when the user disconnects from app here.
           // ...
         }
       // Perform any operations on signed in user here.
       let userId = user.userID                  // For client-side use only!
       let idToken = user.authentication.idToken // Safe to send to the server
       let fullName = user.profile.name
       let givenName = user.profile.givenName
       let familyName = user.profile.familyName
       let email = user.profile.email
       // ...
        self.performSegue(withIdentifier: "home", sender: self)

     }
}

