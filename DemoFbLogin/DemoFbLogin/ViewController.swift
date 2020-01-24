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

class ViewController: UIViewController {
   
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        let loginButton = FBLoginButton(permissions: [ .publicProfile ])
//        loginButton.center = view.center
//
//        view.addSubview(loginButton)

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
        self.present(alertController, animated: true, completion: nil)
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
//                var strFBAccessToken = ""
//                if let strAT = FBSDKAccessToken.current().tokenString{
//                    strFBAccessToken = strAT
//                }
//                guard strFBAccessToken.count > 0 else{
//                    self.av.stopAnimating()
//                    let controller = UIAlertController.alertControllerWithTitle("", message: "Facebook login can't be completed right now. Please try after some time.")
//                    self.present(controller, animated: true) {}
//                    return
//                }
//                var strFBExpireIn = Double()
//                if let expireDate =  FBSDKAccessToken.current().expirationDate{
//                    strFBExpireIn = (expireDate.timeIntervalSince1970) * 1000
//                }
//
//                var fcmtoken = ""
//                if let refreshedToken = InstanceID.instanceID().token() {
//                    print("InstanceID token: \(refreshedToken)")
//                    fcmtoken = refreshedToken
//                }
//
//
//                let strParams:[String:String] = ["fb_id": strFBUserID, "invitation_code": "", "timezone":strFBtimezone, "email": strFBEMail, "locale": strFBLocale, "name":strFBName, "apns_token": fcmtoken,"expires_in": "\(strFBExpireIn)", "age_range": strFBageRange, "access_token": strFBAccessToken]
//                let dicFbLoginParm:NSDictionary = NSDictionary.init(dictionary: strParams)
//                self.callFBLoginWithParam(dicFbLoginParm)

            }else{
                //self.av.stopAnimating()
                let controller = UIAlertController(title: "", message: "Facebook login can't be completed right now. Please try after some time.", preferredStyle: .alert)
                self.present(controller, animated: true) {}
                
            }
            
        }
        
    }
}

