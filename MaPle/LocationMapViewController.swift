//
//  LocationMapViewController.swift
//  MaPle
//
//  Created by Violet on 2018/11/15.
//

import UIKit
import MapKit

class LocationMapViewController: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate {

    @IBOutlet weak var mapview: MKMapView!
    var postdetail:PostDetail?
    let locationManager = CLLocationManager()
    let communicatior = ExploreCommunicator.shared
    var locationList:LocationList?
    let annotation = LocationAnnotation()
    var imagedata:Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        mapview.delegate = self
        if CLLocationManager.locationServicesEnabled() {
            
            locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters // 距離篩選器 用來設置移動多遠距離才觸發委任方法更新位置
            //        locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.activityType = .fitness
            self.mapview.showsUserLocation = true
            locationManager.startUpdatingLocation()
            
        } else {
            showAlert(message: "請前往「設定」開啟APP取用位置權限")
        }
        guard let postdetail = self.postdetail else {
            print("postdetail is nil")
            return
        }
        communicatior.getLocationList(postId: String(postdetail.postid)) { (result, error) in
            if let error = error {
                print("error:\(error)")
                return
            }
            guard let result = result else {
                print("result is nil")
                return
            }
            guard let jsondata = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted) else {
                print("decode failed")
                return
            }
            guard let finaldata = try? JSONDecoder().decode(LocationList.self, from: jsondata) else {
                print("decde failed")
                return
            }
            self.locationList = finaldata
            self.annotation.coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(finaldata.lat), CLLocationDegrees(finaldata.lon))
            self.annotation.title = finaldata.district
            self.annotation.subtitle = finaldata.address
        }
    }
    
    func showAlert(title: String? = nil, message: String){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default)
        alert.addAction(ok)
        present(alert,animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //      execure moveAndZoomMap() after 3.0 seconds
        //      Grand Central Dispatch 筆記
        //       main ==>工作內容和ＵＩ有關,需使用main Queue
        guard let postdetail = self.postdetail else {
            print("postdetail is nil")
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0){
            self.movieAndZoomMap(postdetail: postdetail)
        }
    }
    
    func movieAndZoomMap(postdetail: PostDetail) {

        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: annotation.coordinate, span: span)
        mapview.setRegion(region, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
            self.mapview.addAnnotation(self.annotation)
        }
    }
    
    @IBAction func mapStylechange(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            mapview.mapType = .standard
        case 1:
            mapview.mapType = .satellite
        case 2:
            mapview.mapType = .hybrid
        case 3:
            mapview.mapType = .hybridFlyover
        default:
            mapview.mapType = .standard
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
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        //      此方法會呼叫兩次 一次為自身的定位藍點 另一次為store
        //      如果現在要畫MKUserLocation回傳nil 繼續做MKUserLocation
        if annotation is MKUserLocation{
            return nil
        }
        
        //       cast to storeAnnotation
        guard let annotation = annotation as? LocationAnnotation else{
            //          如果圖標有bug 會show出assertionFailure
            assertionFailure("Failed to cast as StoreAnnotation")
            return nil//做出預設方法
        }
        
        let identifier = "location"
        //      找出可以回收的view元件（dequeueReusableAnnotationView）
        //      配對是否為需要的view-> as? MKPinAnnotationView 識別/長相已以為主（identifier）
        var result = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) //as? MKPinAnnotationView
        if result == nil{
            //           如果沒有可回收元件 創造出新的
                      result = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
//            result = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }else{
            //          有可回收物件時 置換資料物件
            result?.annotation = annotation
        }
        result?.canShowCallout = true//可點擊
        //        result?.animatesDrop = true//插入動畫用於focus用
        let figure = UIImage(data: imagedata!)
        let picture = UIImageView(image: figure)
        result?.leftCalloutAccessoryView = picture
        result?.leftCalloutAccessoryView?.sizeToFit()
        let button = UIButton(type: .detailDisclosure)
        
        //      動態加入按鈕,程式和IbAction做的是一樣 selector is a objective c code
        button.addTarget(self, action: #selector(accessoryBtnPress(sender:)), for: .touchUpInside)
        result?.rightCalloutAccessoryView = button
        return result
    }
    
    @objc //this method still need to be a objective c code
    func accessoryBtnPress(sender: Any){
        let alert = UIAlertController(title: locationList?.address, message: "是否要導航前往？", preferredStyle: .actionSheet)
        //        let ok = UIAlertAction(title: "ok", style: .default, handler: nil)
        let ok = UIAlertAction(title: "是", style: .default) {
            (action) in
            self.navigateToLocation()
        }
        let no = UIAlertAction(title: "否", style: .cancel, handler: nil)
        alert.addAction(ok)
        alert.addAction(no)
        //      全螢幕呈現的方式 可以為直接跳出或由下跳出
        present(alert, animated: true, completion: nil)
    }
    
    func navigateToLocation() {
        
        guard  let locationList = self.locationList else {
            print("locationlist is nil")
            return
        }
        
        let targetCoordinate = CLLocationCoordinate2DMake(CLLocationDegrees(locationList.lat), CLLocationDegrees(locationList.lon))
        let targetplacemark = MKPlacemark(coordinate: targetCoordinate)
        let targetMapItem = MKMapItem(placemark: targetplacemark)
        let options = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
        
        guard let currentlocation = self.locationManager.location else {
            print("currentlocation is nil")
            return
        }
        
        let currentLat = currentlocation.coordinate.latitude
        let currentLon = currentlocation.coordinate.longitude
        
        let sourceCoordinate = CLLocationCoordinate2DMake(currentLat,currentLon)
        let sourcePlaceMark = MKPlacemark(coordinate: sourceCoordinate)
        let sourceMapItem = MKMapItem(placemark: sourcePlaceMark)
        
        MKMapItem.openMaps(with: [sourceMapItem,targetMapItem], launchOptions: options)
        }
}

class LocationAnnotation :NSObject, MKAnnotation{
    //    Basic properties
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0)
    var title: String?
    var subtitle: String?
}
