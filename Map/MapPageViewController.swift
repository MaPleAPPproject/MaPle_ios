//
//  MapPageViewController.swift
//  MaPle
//
//  Created by Violet on 2018/10/23.
//
import MapKit
import UIKit
import CoreLocation

class MapPageViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UICollectionViewDelegate,UICollectionViewDataSource {
    
    
    @IBOutlet weak var myMapView: MKMapView!
    @IBOutlet weak var mypostCollectionView: UICollectionView!
    
    var memberId = ""
    var locationManager = CLLocationManager()
    let userDefaults = UserDefaults.standard
    let communicator = MapCommunicator.shared
    let mark = MKPointAnnotation()
    var spots: [Dictionary<String, Any>] = []
    var spots2: [Dictionary<String, Any>] = []
    var count:Int = 0
    var images = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        memberId = self.userDefaults.value(forKey: "MemberID") as! String
        locationManager.delegate = self
        myMapView.delegate = self
        
        guard CLLocationManager.locationServicesEnabled() else {
            return
        }
        
        self.myMapView.showsUserLocation = true
        locationManager.activityType = .automotiveNavigation
        locationManager.requestWhenInUseAuthorization()
        
        let myLocation = locationManager.location?.coordinate
        if (myLocation?.latitude != nil) && (myLocation?.longitude != nil) {
            locationManager.startUpdatingHeading()
            locationManager.startUpdatingLocation()
            self.myMapView.setCenter(myLocation!, animated: true)
        }else{
            let alert = UIAlertController(title: "警告!", message: "請允許APP使用定位資料", preferredStyle: .alert)
            let ok = UIAlertAction(title: "我知道了", style: .default, handler: {
                action in
            })
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        communicator.findById(MemberId: memberId) { (data, error) in
            let result = data!
            if let error = error {
                print("\(error)")
                let alert = UIAlertController(title: "警告!", message: "連線異常(3)", preferredStyle: .alert)
                let ok = UIAlertAction(title: "我知道了", style: .default, handler: {
                    action in
                })
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
                return
            }else {
                let Data = result.data(using: .utf8)!
                do {
                    if let jsonArray = try JSONSerialization.jsonObject(with: Data, options : .allowFragments) as? [Dictionary<String,Any>]
                    {
                        self.spots = jsonArray
                        self.spots2 = jsonArray
                        for spot in self.spots2 {
                            let point = MKPointAnnotation()
                            let postid = spot["PostId"] as! Int
                            let stringid = String(postid)
                            self.mark.subtitle = stringid
                            point.subtitle = stringid
                            let lat = spot["Lat"] as! Double
                            let lon = spot["Lon"] as! Double
                            point.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon )
                            point.title = spot["District"] as? String
                            self.myMapView.addAnnotation(point)
                        }
                        self.mypostCollectionView.reloadData()
                    }else {
                        print("bad json")
                    }
                } catch let error as NSError {
                    print(error)
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return spots.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! userCollectionViewCell
        for spot in spots{
            cell.titleUILabel.text = spot["District"] as? String
            let id = spot["PostId"] as! Int
            cell.tag = id
            self.communicator.findPhoto(PostId: id) { (data, error) in
                if let error = error{
                    print("\(error)")
                    return
                }else{
                    let image = UIImage(data:data!)
                    cell.photoImageView.image = image
                    self.images.append(image!)
                }
            }
            self.spots.remove(at: 0)
            break
        }
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        let id = cell!.tag
        myMapView.removeAnnotations(myMapView.annotations)
        for spot in spots2{
            let postid = spot["PostId"] as! Int
            let stringid = String(postid)
            mark.subtitle = stringid
            if id == postid {
                let lat = spot["Lat"] as! Double
                let lon = spot["Lon"] as! Double
                mark.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon )
                mark.title = spot["District"] as? String
                self.myMapView.addAnnotation(mark)
                self.myMapView.setCenter(mark.coordinate, animated: true)
                return
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation{
            return nil
        }
        
        var annView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin") as? MKPinAnnotationView
        if annView == nil{
            annView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        }
        
        annView!.pinTintColor = UIColor.blue
        let id = Int(annotation.subtitle!!)
        
        self.communicator.findPhoto(PostId: id!) { (data, error) in
            if let error = error{
                print("\(error)")
                return
            }else{
                let image = UIImage(data:data!)
                let button = UIButton(type: .detailDisclosure)
                button.addTarget(self, action: #selector(self.accessoryBtnPress(sender:)), for: .touchUpInside)
                let leftIconView = UIImageView(frame: CGRect.init(x: 0, y: 0, width: 53, height: 53))
                leftIconView.image = image
                annView!.leftCalloutAccessoryView = leftIconView
                //                annView!.rightCalloutAccessoryView = button
            }
        }
        annView!.canShowCallout = true
        return annView
    }
    
    //    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    //        let vc = self.storyboard?.instantiateViewController(withIdentifier: "loginView")
    //             self.show(vc!, sender: self)
    //    }
    
    //    private func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
    //                let vc = self.storyboard?.instantiateViewController(withIdentifier: "loginView")
    //                self.show(vc!, sender: self)
    //    }
    
    @objc
    func accessoryBtnPress(sender:Any){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "loginView")
        self.show(vc!, sender: self)
    }
    
    //    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    //        let tag = view.tag
    //    }
    
}
