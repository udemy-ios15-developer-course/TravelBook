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
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
            request.returnsObjectsAsFaults = false
            request.predicate = NSPredicate(format: "id = %@", selectedId!.uuidString)
                                            
            do {
                let results = try context.fetch(request)
                for result in results as! [NSManagedObject] {
                    let name = result.value(forKey: "name") as? String
                    let comment = result.value(forKey: "comment") as? String
                    let longitude = result.value(forKey: "longitude") as! Double
                    let latitude = result.value(forKey: "latitude") as! Double
                    // let id = result.value(forKey: "name") as? UUID

                    nameText.text = name
                    commentText.text = comment
                    let annotation = MKPointAnnotation()
                    annotation.title = name
                    annotation.subtitle = comment
                    let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    annotation.coordinate = coordinate
                    mapView.addAnnotation(annotation)
                    
                    locationManager.stopUpdatingLocation()
                    let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    let region = MKCoordinateRegion(center: coordinate, span: span)
                    mapView.setRegion(region, animated: true)
                }
                
            } catch {
                fatalError(error.localizedDescription)
            }
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
        if selectedName != "" {
            return
        }
        
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        let identifier = "myAnnotation"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            pinView?.canShowCallout = true
            
            let button = UIButton(type: UIButton.ButtonType.detailDisclosure)
            pinView?.rightCalloutAccessoryView = button
            
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if selectedName == "" {
            return
        }
        
        let requestedLocation = CLLocation(latitude: latitude, longitude: longitude)
        CLGeocoder().reverseGeocodeLocation(requestedLocation) { placemarks, error in
            if placemarks?.count == 0 {
                return
            }
            
            let newPlacemark = MKPlacemark(placemark: placemarks![0])
            let item = MKMapItem(placemark: newPlacemark)
            item.name = self.title
            let launchOptions = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
            item.openInMaps(launchOptions: launchOptions)
        }
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
        
        NotificationCenter.default.post(name: NSNotification.Name("newPlace"), object: nil)
        navigationController?.popViewController(animated: true)
    }
}

/*
 Need to give privacy - Location When in Use Usage Description in the info.plist
 a value to make this work
 */
