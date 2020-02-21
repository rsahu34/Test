
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
extension UIImage {
    func resized(withPercentage percentage: CGFloat, isOpaque: Bool = true) -> UIImage? {
        let canvas = CGSize(width: size.width * percentage, height: size.height * percentage)
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: canvas, format: format).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
    func resized(toWidth width: CGFloat, isOpaque: Bool = true) -> UIImage? {
        let canvas = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: canvas, format: format).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
    func resizeUI(size:CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, true, self.scale)
        self.draw(in: CGRect(origin: CGPoint(x: 0,y :0), size: size))
        
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
}
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
    private var image: UIImage?
    private var croppingStyle = CropViewCroppingStyle.default
    
    private var croppedRect = CGRect.zero
    private var croppedAngle = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ratingcontrol.ratingDeligate = self
        self.ratingcontrol.rating = 1
        self.ratingcontrol.isUserInteractionEnabled = true
        // Do any additional setup after loading the view.
        img.isUserInteractionEnabled = true
        img.contentMode = .scaleAspectFit
        if #available(iOS 11.0, *) {
            img.accessibilityIgnoresInvertColors = true
        }
        
        let tapRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(didTapImageView))
        img.addGestureRecognizer(tapRecognizer)
    }
    @objc public func didTapImageView() {
        // When tapping the image view, restore the image to the previous cropping state
        let cropViewController = CropViewController(croppingStyle: self.croppingStyle, image: self.image!)
        cropViewController.delegate = self
        let viewFrame = view.convert(img.frame, to: navigationController!.view)
        
        cropViewController.presentAnimatedFrom(self,
                                               fromImage: self.img.image,
                                               fromView: nil,
                                               fromFrame: viewFrame,
                                               angle: self.croppedAngle,
                                               toImageFrame: self.croppedRect,
                                               setup: { self.img.isHidden = true },
                                               completion: nil)
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
        let h2 = (700.0 * (img.image?.size.height)!) / (img.image?.size.width)!
        
        
        let imgRe = img.image?.resizeUI(size: CGSize.init(width: 700, height: h2))
        print("!!!!: \(imgRe?.size.width) X \(imgRe?.size.height)" )

        let imageData = imgRe!.jpegData(compressionQuality: 1)
        

        if(imageData==nil)  { return; }

        request.httpBody = createBodyWithParameters(filePathKey: "userfile", imageDataKey: imageData! as NSData, boundary: boundary) as Data

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
        var value = NSString()
        // let value = "{\"firstname\":\"kousik\",\"from\":\"ind\"}"
        let arrayjson:[String:String] = ["firstname":"kousik","from":"ind"]
        let dicData = arrayjson as? NSDictionary
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dicData, options: JSONSerialization.WritingOptions.prettyPrinted) as Data
            
            value = NSString(data: jsonData, encoding: String.Encoding.ascii.rawValue)!
            value = value.replacingOccurrences(of: "\n", with: "") as NSString
            print("Send verification code req: \(value)")

        } catch  let error as NSError {
            
        }
        

        
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
    public func layoutImageView() {
        guard img.image != nil else { return }
        
        let padding: CGFloat = 20.0
        
        var viewFrame = self.view.bounds
        viewFrame.size.width -= (padding * 2.0)
        viewFrame.size.height -= ((padding * 2.0))
        
        var imageFrame = CGRect.zero
        imageFrame.size = img.image!.size;
        
        if img.image!.size.width > viewFrame.size.width || img.image!.size.height > viewFrame.size.height {
            let scale = min(viewFrame.size.width / imageFrame.size.width, viewFrame.size.height / imageFrame.size.height)
            imageFrame.size.width *= scale
            imageFrame.size.height *= scale
            imageFrame.origin.x = (self.view.bounds.size.width - imageFrame.size.width) * 0.5
            imageFrame.origin.y = (self.view.bounds.size.height - imageFrame.size.height) * 0.5
            img.frame = imageFrame
        }
        else {
            self.img.frame = imageFrame;
            self.img.center = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
        }
        self.imageUploadRequest()
    }


    }
// extension for impage uploading

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
                
                var image : UIImage!

                if let img = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
               {
                   image = img

               }
                else if let img = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
               {
                   image = img
               }

//                self.img.image = image
//                self.imageUploadRequest()
                let cropController = CropViewController(croppingStyle: croppingStyle, image: image)
                      //cropController.modalPresentationStyle = .fullScreen
                      cropController.delegate = self
                  

                      self.image = image
                      
                      //If profile picture, push onto the same navigation stack
                      if croppingStyle == .circular {
                          if picker.sourceType == .camera {
                              picker.dismiss(animated: true, completion: {
                                  self.present(cropController, animated: true, completion: nil)
                              })
                          } else {
                              picker.pushViewController(cropController, animated: true)
                          }
                      }
                      else { //otherwise dismiss, and then present from the main controller
                          picker.dismiss(animated: true, completion: {
                              self.present(cropController, animated: true, completion: nil)
                              //self.navigationController!.pushViewController(cropController, animated: true)
                          })
                      }
            }
        }
        self.dismiss(animated: true, completion: nil)

    }
}


extension ScanVC: CropViewControllerDelegate{
    public func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
           self.croppedRect = cropRect
           self.croppedAngle = angle
           updateImageViewWithImage(image, fromCropViewController: cropViewController)
       }
       
       public func cropViewController(_ cropViewController: CropViewController, didCropToCircularImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
           self.croppedRect = cropRect
           self.croppedAngle = angle
           updateImageViewWithImage(image, fromCropViewController: cropViewController)
       }
       
       public func updateImageViewWithImage(_ image: UIImage, fromCropViewController cropViewController: CropViewController) {
           img.image = image
           layoutImageView()
           
           self.navigationItem.leftBarButtonItem?.isEnabled = true
           
           if cropViewController.croppingStyle != .circular {
               img.isHidden = true
               
               cropViewController.dismissAnimatedFrom(self, withCroppedImage: image,
                                                      toView: img,
                                                      toFrame: CGRect.zero,
                                                      setup: { self.layoutImageView() },
                                                      completion: {
                                                       self.img.isHidden = false })
           }
           else {
               self.img.isHidden = false
               cropViewController.dismiss(animated: true, completion: nil)
           }
       }
}


