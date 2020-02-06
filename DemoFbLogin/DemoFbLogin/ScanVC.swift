
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
                }
            }
        }
    }
}
