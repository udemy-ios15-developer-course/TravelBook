//
//  ViewController.swift
//  TravelBook
//
//  Created by Chris Hand on 8/28/22.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate{

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var commentText: UITextField!
    
    var selectedName = ""
    var selectedId : UUID?
    
    var locationManager = CLLocationManager()
    var longitude = Double()
    var latitude = Double()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation(gestureRecognizer:)))
        gestureRecognizer.minimumPressDuration = 3
        mapView.addGestureRecognizer(gestureRecognizer)
        
        if selectedName != "" {
            
        }
    }
    
    @objc
    func chooseLocation(gestureRecognizer: UILongPressGestureRecognizer) {
        print("touchpoint")
        if gestureRecognizer.state == .began {
            let touchPoint = gestureRecognizer.location(in: self.mapView)
            let touchCoordinates = self.mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchCoordinates
            annotation.title = nameText.text
            annotation.subtitle = commentText.text
            self.mapView.addAnnotation(annotation)
            longitude = touchCoordinates.longitude
            latitude = touchCoordinates.latitude
        }
    }

    

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPlace = NSEntityDescription.insertNewObject(forEntityName: "Places", into: context)
        newPlace.setValue(nameText.text, forKey: "name")
        newPlace.setValue(commentText.text, forKey: "comment")
        newPlace.setValue(longitude, forKey: "longitude")
        newPlace.setValue(latitude, forKey: "latitude")
        newPlace.setValue(UUID(), forKey: "id")
        
        do {
            try context.save()
            print("success")
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}

/*
 Need to give privacy - Location When in Use Usage Description in the info.plist
 a value to make this work
 */
