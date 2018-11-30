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

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        mapView.delegate = self
       
        
        RequestAuthoriztion()
        searchBar.placeholder = "請輸入地址"
        let inputString = searchBar.text
        showAnnotation()

        // Do any additional setup after loading the view.
    }
    
    
    func showAnnotation(){
        let annotation = MKPointAnnotation()
//        guard let coordinate = locationManager.location?.coordinate else {return}
        annotation.coordinate = CLLocationCoordinate2D(latitude: 24.2013, longitude: 120.5810)
        annotation.title = "title"
        annotation.subtitle = "subTitle"
        mapView.addAnnotation(annotation)
        mapView.setCenter(annotation.coordinate, animated: true)
        
    }
    
    func addressToCoordinate(){
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchBar.text
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
           guard  error == nil  else {
                return
            }
            
            guard response != nil else {
                return
            }
            
            for item in (response?.mapItems)! {
                self.mapView.addAnnotation(item.placemark)
            }
        }
        
        
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
        
        
         locationManager.requestLocation()
    }
    
    func geoCoderConvert(lat:Double, lon: Double){
        let location = CLLocation(latitude: lat, longitude: lon)
        let geocoder = CLGeocoder()
        
        
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if error != nil  {
                
                print("geocoder error:\(String(describing: error))")
                return
            }
            
            guard let placesmarks = placemarks else {
                assertionFailure("placemarks is nil")
                return
                
            }
            
            for placemark in placesmarks  {
                
                guard let name = placemark.name else {
                    print("fail to get data from placemark")
                    return
                }
                
//                self.address = name
                
            }
            
        }
        
    }
    
    
    
    
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MapLocationViewController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        var annView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin")
        if annView != nil {
            annView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        }
        return annView
        
    }
}

extension MapLocationViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard  let location = locations.first else {
            return
        }
        
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: location.coordinate, span: span)
        mapView.setRegion(region, animated: true)
        
    }
    
}
