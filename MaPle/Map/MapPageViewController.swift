//
//  MapPageViewController.swift
//  MaPle
//
//  Created by Violet on 2018/10/23.
//
import MapKit
import UIKit
import CoreLocation

class MapPageViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var myMapView: MKMapView!
    @IBOutlet weak var mypostCollectionView: UICollectionView!
    
    var postList:[PostList] = []
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
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! userCollectionViewCell
        //        cell.photoImageView.image =
                cell.titleUITextField.text = postList[indexPath.row].District
        return  cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  postList.count
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
}
extension UIViewController: MKMapViewDelegate,CLLocationManagerDelegate{
    
}
    struct PostList: Codable {
        var MemberId:Int
        var PostId:String
        var District:String
        var Lat:Double
        var Lon:Double
        
        enum CodingKeys:String ,CodingKey{
            case MemberId = "MemberId"
            case PostId = "PostId"
            case District = "District"
            case Lat = "Lat"
            case Lon = "Lon"
        }
    }

