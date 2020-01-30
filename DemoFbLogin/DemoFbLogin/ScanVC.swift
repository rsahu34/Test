
//
//  ScanVC.swift
//  DemoFbLogin
//
//  Created by Soumen on 27/01/20.
//  Copyright © 2020 Soumen. All rights reserved.
//

import UIKit
import BarcodeScanner

class ScanVC: UIViewController, RatingDelegate {
    @IBOutlet weak var ratingcontrol: RatingControl!

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
