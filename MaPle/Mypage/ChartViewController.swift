//
//  ChartViewController.swift
//  MaPle
//
//  Created by juiying chiu on 2018/12/10.
//

import UIKit
import FSInteractiveMap

class ChartViewController: UIViewController, UIScrollViewDelegate{
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var topView: UIView!
    let communicator = Communicator.shared
    let map: FSInteractiveMapView = FSInteractiveMapView()
    var oldClickedLayer = CAShapeLayer()
    var country = String()
     var memberId = UserDefaults.standard.integer(forKey: "MemberIDint")
    var countryCodeDict: [String : Int] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        colorGeoMap()
        scrollView.delegate = self
        scrollView.maximumZoomScale = 5.0
        scrollView.minimumZoomScale = 1.0
        scrollView.zoomScale = 1.0
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if map.superview == nil {
            colorGeoMap()
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return topView
    }
    
    
    func colorGeoMap() {
        
        communicator.getCountryCode(memberId: memberId) { (result, error) in
            if let error = error {
                print("getCountryCode error:\(error)")
                return
            }
            
            guard let result = result else {
                print("getCountryCode result is nil")
                return
            }
            let countryCodes = result as! Array<String>
            print(countryCodes)
            var value = 0
            
            if countryCodes.count == 1 {
                let code = countryCodes.first as! String
                self.countryCodeDict.updateValue(12, forKey: code)
                self.countryCodeDict.updateValue(15, forKey: code)
            } else {
                for countryCode in countryCodes {
                    self.countryCodeDict.updateValue(value, forKey: countryCode)
                    value += 1
                }
            }
           
            
            
            let insets = UIEdgeInsets(top: 32, left: 20, bottom: 0, right: 0)
            self.map.frame = self.topView.bounds.inset(by: insets)
            var colorAxis: [Any] = []
            for _ in 0...countryCodes.count {
                colorAxis.append(UIColor.green)
            }
            self.map.loadMap("world-low", withData: self.countryCodeDict, colorAxis: colorAxis)
            
            
            self.map.clickHandler = {(identifier: String? , _ layer: CAShapeLayer?) -> Void in
                if (self.oldClickedLayer != nil) {
                    self.oldClickedLayer.zPosition = 0
                    self.oldClickedLayer.shadowOpacity = 0
                }
                self.oldClickedLayer = layer!
                // We set a simple effect on the layer clicked to highlight it
                layer?.zPosition = 10
                layer?.shadowOpacity = 0.5
                layer?.shadowColor = UIColor.black.cgColor
                layer?.shadowRadius = 5
                layer?.shadowOffset = CGSize(width: 0, height: 0)
                print("\(String(describing: identifier)) clicked")
                self.country = identifier ?? ""
                let tableController = self.children.first as? WorldTableViewController
                tableController?.country = self.country
                tableController?.updateUI()
            }
        }
        topView.addSubview(map)
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
