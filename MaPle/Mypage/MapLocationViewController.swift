//
//  MapLocationViewController.swift
//  MaPle
//
//  Created by juiying chiu on 2018/11/29.
//

import UIKit
import CoreLocation
import MapKit

class MapLocationViewController: UIViewController {
    
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    var selectedLocation : [String : String] = [:]
    var lat = Double ()
    var lon = Double ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        RequestAuthoriztion()
        locationManager.delegate = self
        mapView.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(mapViewLongPressed(longGesture:)))
        mapView.addGestureRecognizer(tapGesture)
        locationManager.requestLocation()
        
    }
    
    @IBAction func navigationBtnPressed(_ sender: UIButton) {
        locationManager.requestLocation()
    }
    
    @objc
    func mapViewLongPressed(longGesture: UILongPressGestureRecognizer){
        
        let point = longGesture.location(in: mapView)
        let coor = mapView.convert(point, toCoordinateFrom: mapView)
        print("coor:lat:\(coor.latitude)\tlon:\(coor.longitude)")
        geoCoderConvert(lat: coor.latitude, lon: coor.longitude, centerMoved: false)
        
    }
    
    @IBAction func searchBtnPressed(_ sender: UIButton) {
        
        guard let address = addressTextField.text else {
            print("address is nil")
            return
        }
        
        if !address.isEmpty {
            addressToCoordinate(address: address)
            addressTextField.resignFirstResponder()
            addressTextField.text = ""
        } else {
            let alert = UIAlertController(title: nil, message: "沒有相符的地點", preferredStyle: .alert
            )
            let ok = UIAlertAction(title: "OK", style: .default)
            alert.addAction(ok)
            present(alert, animated: true)
        }
        
    }
    
    func addressToCoordinate(address: String){
        
        
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            //            guard let error = error else {
            //                return
            //            }
            
            guard let placemarks = placemarks else {
                print("placemarks is nil")
                
                let alert = UIAlertController(title: nil, message: "沒有相符的地點", preferredStyle: .alert
                )
                let ok = UIAlertAction(title: "OK", style: .default)
                alert.addAction(ok)
                self.present(alert, animated: true)
                return
            }
            let  placemark = placemarks.first!
            self.showAnnotationByPlaceMark(placemark: placemark, centerMove: true)
            
        }
        
    }
    
    
    func showAnnotationByPlaceMark(placemark: CLPlacemark, centerMove: Bool){
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
        // let annotation = MKPointAnnotation()
        let annotation = AttractionAnnotation()
        var addressString = ""
        defer {
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) {
                self.mapView.addAnnotation(annotation)
                self.mapView.showAnnotations(self.mapView.annotations, animated: true)
                self.mapView.selectAnnotation(annotation, animated: true)
                
            }
            if !centerMove {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) {
                    self.mapView.setCenter(annotation.coordinate, animated: true)
                }
            }
        }
        
        let country = placemark.country
        let adminarea = placemark.administrativeArea
        let countryCode = placemark.isoCountryCode
        let location = placemark.location
        let address = placemark.name
        
        print("country:\(country)")
        print("adminarea:\(adminarea)")
        print("countryCode:\(countryCode)")
        print("address:\(address)")
        
        selectedLocation.updateValue(country ?? "", forKey: "country")
        selectedLocation.updateValue(adminarea ?? "", forKey: "adminarea")
        selectedLocation.updateValue(countryCode ?? "", forKey: "countryCode")
        selectedLocation.updateValue(address ?? "", forKey: "address")
        selectedLocation.updateValue(address ?? "", forKey: "district")
        guard let place  = location else {
            print("location is nil")
            return}
        lat = place.coordinate.latitude
        lon = place.coordinate.longitude
        
        
        annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        annotation.title = country ?? ""
        annotation.subtitle = adminarea ?? ""
        
        guard
            let locality = placemark.locality,
            let subAdmin = placemark.subAdministrativeArea else {
                print("locality or subAdmin is nil ")
                return
        }
        
        
        
        addressString = locality + ", " + subAdmin
        annotation.subtitle = addressString
        selectedLocation.updateValue( addressString, forKey: "district" )
        
    }
    
    
    
    func RequestAuthoriztion() {
        let state = CLLocationManager.authorizationStatus()
        guard CLLocationManager.locationServicesEnabled() else {
            return
        }
        
        if state == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        
        if state == .denied || state == .restricted {
            let alert = UIAlertController(title: "Location services disabled.", message: "Please enable location " , preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true)
        }
        
    }
    
    func geoCoderConvert(lat:Double, lon: Double, centerMoved: Bool){
        let location = CLLocation(latitude: lat, longitude: lon)
        let geocoder = CLGeocoder()
        
        
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
                        if let error = error  {
                            print("geocoder error:\(String(describing: error))")
                            return
                        }
            
            guard let placemark = placemarks?.first else {
                print("placemarks is nil")
                return
                
            }
            
          
            self.showAnnotationByPlaceMark(placemark: placemark, centerMove: centerMoved)
            
        }
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
    }
    
}

extension MapLocationViewController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        guard let annotation = annotation as? AttractionAnnotation else {
            assertionFailure("Fail to cast as AttractionAnnotation.")
            return nil
        }
        
        let identifier = "attraction"
        var result = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
        if result == nil {
            result = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        } else {
            result?.annotation = annotation
        }
        
        result?.pinTintColor = UIColor.red
        result?.canShowCallout = true
        let image = #imageLiteral(resourceName: "star-1")
        let pinView = #imageLiteral(resourceName: "pin")
        result?.image = pinView
        let imageView = UIImageView(image: image)
        result?.leftCalloutAccessoryView = imageView
        
        let button = UIButton(type:.detailDisclosure)
        
        result?.rightCalloutAccessoryView = button
        
        return result
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let annotation = mapView.annotations
        mapView.removeAnnotations(annotation)
        let alert = UIAlertController(title: "確定地點", message: nil, preferredStyle: .alert)
        let ok = UIAlertAction(title: "確定", style: .default) { (action) in
            
            self.performSegue(withIdentifier: "unwind", sender: self)
        }
        let cancel = UIAlertAction(title: "取消", style: .default)
        alert.addAction(ok)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    
}

extension MapLocationViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard  let location = locations.first else {
            return
        }
        
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        let region = MKCoordinateRegion(center: location.coordinate, span: span)
        mapView.setRegion(region, animated: true)
        geoCoderConvert(lat: location.coordinate.latitude, lon: location.coordinate.longitude, centerMoved: true)
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let error = error
        print("didFailWithError :\(error)")
    }
    
}

class AttractionAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0)
    var title: String?
    var subtitle: String?
    
    override init(){
        super.init()
    }
    
    
}
