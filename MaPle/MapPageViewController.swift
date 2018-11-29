//
//  MapPageViewController.swift
//  MaPle
//
//  Created by Violet on 2018/10/23.
//
import MapKit
import UIKit
import CoreLocation

class MapPageViewController: UIViewController {
    
    @IBOutlet weak var myMapView: MKMapView!
    @IBOutlet weak var mypostCollectionView: UICollectionView!
    
    var memberId = ""
    var locationManager = CLLocationManager()
    let userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        memberId = self.userDefaults.value(forKey: "MemberID") as! String
        
        locationManager.delegate = self
        myMapView.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        
        let myLocation = locationManager.location?.coordinate
        if (myLocation?.latitude != nil) && (myLocation?.longitude != nil) {
            locationManager.startUpdatingHeading()
            locationManager.startUpdatingLocation()
            // 取得資料
        }else{
            let alert = UIAlertController(title: "警告!", message: "請允許APP使用定位資料", preferredStyle: .alert)
            let ok = UIAlertAction(title: "我知道了", style: .default, handler: {
                action in
            })
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
        
        // Do any additional setup after loading the view.
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
extension UIViewController: MKMapViewDelegate,CLLocationManagerDelegate{
    
}

//extension UIViewController:UICollectionViewDelegate,UICollectionViewDataSource{
//    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return 1
//    }
//
//    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        return
//    }
//
//}
