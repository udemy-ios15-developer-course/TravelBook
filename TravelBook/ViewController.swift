//
//  ViewController.swift
//  TravelBook
//
//  Created by Chris Hand on 8/28/22.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }


}

