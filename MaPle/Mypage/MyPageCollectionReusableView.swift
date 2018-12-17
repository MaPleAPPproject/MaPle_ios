//
//  MyPageCollectionReusableView.swift
//  MaPle
//
//  Created by Violet on 2018/12/14.
//

import UIKit

class MyPageCollectionReusableView: UICollectionReusableView {
        
    @IBOutlet weak var collectLabel: UILabel!
    @IBOutlet weak var postCountLabel: UILabel!
    @IBOutlet weak var selfintroLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    var segmentPosition = 0
    let notificationName = Notification.Name("GetSegmentPosition")
    
    @IBAction func segmentValue(_ sender: UISegmentedControl) {
        NotificationCenter.default.post(name: notificationName, object: sender.selectedSegmentIndex)
        
        if sender.selectedSegmentIndex == 0 {
            print("segmentPosition = 0")
            segmentPosition = 0
            
        } else {
            print("segmentPosition = 1")
            segmentPosition = 1
        }
    }
}
