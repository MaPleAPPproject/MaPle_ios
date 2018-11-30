//
//  OthersPageUICollectionReusableView.swift
//  MaPle
//
//  Created by Violet on 2018/11/20.
//

import UIKit

class OthersPageUICollectionReusableView: UICollectionReusableView {
    
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var selfintroLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var vipLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var collectCountLabel: UILabel!
    @IBOutlet weak var postCountLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    var segmentPosition = 0
    let notificationName = Notification.Name("GetSegmentPosition")
    @IBAction func segmentControl(_ sender: UISegmentedControl) {
        
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
