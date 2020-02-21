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
    
    @IBOutlet weak var tblRtng: UITableView!
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
extension MapViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "rtcell"
        var cell: RtTblCell! = tableView.dequeueReusableCell(withIdentifier: identifier) as? RtTblCell
        if cell == nil {
            tableView.register(UINib(nibName: "RtTblCell", bundle: nil), forCellReuseIdentifier: identifier)
            cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? RtTblCell
        }
        return cell
    }
    
    
}
