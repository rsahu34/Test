//
//  MapViewController.swift
//  DemoFbLogin
//
//  Created by Soumen on 12/02/20.
//  Copyright © 2020 Soumen. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    @IBOutlet weak var mapview: MKMapView!
    let locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        if CLLocationManager.locationServicesEnabled() {
           // continue to implement here
        } else {
           // Do something to let users know why they need to turn it on.
        }
    }
    func checkAuthorizationStatus() {
      switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapview.showsUserLocation = true
        case .denied: break
        case .notDetermined: break
            locationManager.requestWhenInUseAuthorization()
            mapview.showsUserLocation = true
        case .restricted: break
        case .authorizedAlways: break
      }
    }
}
