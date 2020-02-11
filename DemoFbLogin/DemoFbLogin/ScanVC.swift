
//
//  ScanVC.swift
//  DemoFbLogin
//
//  Created by Soumen on 27/01/20.
//  Copyright © 2020 Soumen. All rights reserved.
//

import UIKit
import BarcodeScanner
import MobileCoreServices
import FacebookCore
import FacebookLogin
import GoogleSignIn

extension Data {

    /// Append string to Data
    ///
    /// Rather than littering my code with calls to `data(using: .utf8)` to convert `String` values to `Data`, this wraps it in a nice convenient little extension to Data. This defaults to converting using UTF-8.
    ///
    /// - parameter string:       The string to be added to the `Data`.

    mutating func append(_ string: String, using encoding: String.Encoding = .utf8) {
        if let data = string.data(using: encoding) {
            append(data)
        }
    }
}

class ScanVC: UIViewController, RatingDelegate {
    @IBOutlet weak var ratingcontrol: RatingControl!
    
    @IBOutlet weak var img: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ratingcontrol.ratingDeligate = self
        self.ratingcontrol.rating = 1
        self.ratingcontrol.isUserInteractionEnabled = true
        // Do any additional setup after loading the view.
    }
    
    @IBAction func handleScannerPresent(_ sender: Any, forEvent event: UIEvent) {
       let viewController = makeBarcodeScannerViewController()
       viewController.title = "Barcode Scanner"
       present(viewController, animated: true, completion: nil)
     }
    private func makeBarcodeScannerViewController() -> BarcodeScannerViewController {
      let viewController = BarcodeScannerViewController()
      viewController.codeDelegate = self
      viewController.errorDelegate = self
      viewController.dismissalDelegate = self
      return viewController
    }
    
    @IBAction func capturePhoto(_ sender: Any) {
        let imgPick = UIImagePickerController()
        imgPick.delegate = self
        imgPick.sourceType = .camera
        imgPick.allowsEditing = false
        imgPick.mediaTypes = [kUTTypeImage as String]
        self.present(imgPick, animated: true, completion: nil)
        
    }
    
    
    @IBAction func logout(_ sender: Any) {
        GIDSignIn.sharedInstance()?.signOut()
        
        let deletepermission = GraphRequest(graphPath: "me/permissions/", parameters:  ["fields": "id, name, email, age_range, locale, timezone"], httpMethod: HTTPMethod(rawValue: "DELETE"))
        deletepermission.start(completionHandler: {(connection,result,error)-> Void in
            print("the delete permission is \(String(describing: result))")

        })
        let loginManager = LoginManager()
        loginManager.logOut()
        
        let next:ViewController = storyboard?.instantiateViewController(withIdentifier: "first") as! ViewController
        let navController = UINavigationController.init(rootViewController: next)

        SceneDelegate.shared?.window?.rootViewController = navController
    }
    
     func imageUploadRequest() {
        
        let myUrl = NSURL(string: "http://192.168.0.1/kousik/q.php");

        let request = NSMutableURLRequest(url:myUrl as! URL);
        request.httpMethod = "POST"

            let boundary = generateBoundaryString()

            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        let imageData = img.image!.jpegData(compressionQuality: 1)

            if(imageData==nil)  { return; }

        request.httpBody = createBodyWithParameters(filePathKey: "userfile", imageDataKey: imageData! as NSData, boundary: boundary) as Data

            //myActivityIndicator.startAnimating();

        let task =  URLSession.shared.dataTask(with: request as URLRequest,
                completionHandler: {
                    (data, response, error) -> Void in
                    if let data = data {

                        // You can print out response object
                        print("******* response = \(String(describing: response))")

                        print(data.count)
                        // you can use data here

                        // Print out reponse body
                        let responseString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                        print("****** response data = \(responseString!)")

                        let json =  try!JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary

                        print("json value \(String(describing: json))")

                        //var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers, error: &err)
                        DispatchQueue.main.async(execute: {
                            
                        })
                        

                    } else if let error = error {
                       // print(error.description)
                    }
            })
            task.resume()


        }


        func createBodyWithParameters(filePathKey: String?, imageDataKey: NSData, boundary: String) -> NSData {
            let body = NSMutableData();
            //["name":"kd"]
            /*if parameters != nil {
                for (key, value) in parameters! {
                    body.appendString("--\(boundary)\r\n")
                    body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                    body.appendString("\(value)\r\n")
                }
            }*/
            let value = "{\"firstname\":\"kousik\",\"from\":\"ind\"}"
            body.appendString(string: "--\(boundary)\r\n")
            body.appendString(string: "Content-Disposition: form-data; name=\"name\"\r\n\r\n")
            body.appendString(string: "\(value)\r\n")
            let filename = "user-profile.jpg"

            let mimetype = "image/jpg"

            body.appendString(string: "--\(boundary)\r\n")
            body.appendString(string: "Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
            body.appendString(string: "Content-Type: \(mimetype)\r\n\r\n")
            body.append(imageDataKey as Data)
            body.appendString(string: "\r\n")

            body.appendString(string: "--\(boundary)--\r\n")

            return body
        }

        func generateBoundaryString() -> String {
            return "Boundary-\(NSUUID().uuidString)"
        }

    }// extension for impage uploading

    extension NSMutableData {

        func appendString(string: String) {
            let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
            append(data!)
        }
    }

// MARK: - BarcodeScannerCodeDelegate

extension ScanVC: BarcodeScannerCodeDelegate {
  func scanner(_ controller: BarcodeScannerViewController, didCaptureCode code: String, type: String) {
    print("Barcode Data: \(code)")
    print("Symbology Type: \(type)")

    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
      controller.reset()
      controller.dismiss(animated: true, completion: nil)
    }
  }
}

// MARK: - BarcodeScannerErrorDelegate

extension ScanVC: BarcodeScannerErrorDelegate {
  func scanner(_ controller: BarcodeScannerViewController, didReceiveError error: Error) {
    print(error)
  }
}

// MARK: - BarcodeScannerDismissalDelegate

extension ScanVC: BarcodeScannerDismissalDelegate {
  func scannerDidDismiss(_ controller: BarcodeScannerViewController) {
    controller.dismiss(animated: true, completion: nil)
  }
}
//MARK: - ImagePickerDelegate

extension ScanVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let mediaData = info[UIImagePickerController.InfoKey.mediaType] as? NSString{
            if mediaData.isEqual(to: kUTTypeImage as! String){
                if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
                    self.img.image = image
                    self.imageUploadRequest()
                }
            }
        }
        self.dismiss(animated: true, completion: nil)

    }
}





