//
//  FriendPageViewController.swift
//  MaPle
//
//  Created by Violet on 2018/10/23.
//

import StoreKit
import UIKit

class FriendPageViewController: UIViewController
    
{
    
    @IBOutlet weak var friendSegmentControl: UISegmentedControl!
    @IBOutlet weak var friendView: UIView!
    @IBOutlet weak var invitationView: UIView!
    @IBOutlet weak var matchView: UIView!
//    let buttonBar = UIView()
    let memberid = UserDefaults.standard.string(forKey: "MemberID")
    
    //MARK: - change friend page segment
    @IBAction func indexChanged(_ sender: UISegmentedControl) {
//        segmentLineChange(index: sender.selectedSegmentIndex)
        switch sender.selectedSegmentIndex
        {
        case 0:
            friendView.isHidden = false
            invitationView.isHidden = true
            matchView.isHidden = true
        case 1:
            friendView.isHidden = true
            invitationView.isHidden = false
            matchView.isHidden = true
        case 2:
            friendView.isHidden = true
            invitationView.isHidden = true
            matchView.isHidden = false
        default:
            break;
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.segmentstylechange()
        friendView.isHidden = false
        invitationView.isHidden = true
        matchView.isHidden = true
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        print("self.friendSegmentControl:\(self.friendSegmentControl.selectedSegmentIndex)")
//        self.segmentLineChange(index: self.friendSegmentControl.selectedSegmentIndex)
    }
    
//    func segmentLineChange(index: Int) {
//        DispatchQueue.main.async {
//            UIView.animate(withDuration: 0.3) {
//                self.buttonBar.frame.origin.x = (self.friendSegmentControl.frame.width / CGFloat(3)) * CGFloat(index)
//            }
//        }
//
//    }
    
    func segmentstylechange() {
        self.friendSegmentControl.frame.size.height = 50
        self.friendSegmentControl.backgroundColor = .clear
        self.friendSegmentControl.tintColor = .clear
        self.friendSegmentControl.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont(name: "DINCondensed-Bold", size: 18)!,
            NSAttributedString.Key.foregroundColor: UIColor.lightGray
            ], for: .normal)
        
        self.friendSegmentControl.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont(name: "DINCondensed-Bold", size: 18)!,
            NSAttributedString.Key.foregroundColor: UIColor(red: 30/255, green: 163/255, blue: 163/255, alpha: 1.0)
            ], for: .selected)
        
        //add underline
        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = .gray
        view.addSubview(line)
        line.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        // Constrain the button bar to the left side of the segmented control
        line.leftAnchor.constraint(equalTo: friendSegmentControl.leftAnchor).isActive = true
        // Constrain the button bar to the width of the segmented control divided by the number of segments
        line.widthAnchor.constraint(equalTo: friendSegmentControl.widthAnchor).isActive = true
        line.topAnchor.constraint(equalTo: friendSegmentControl.bottomAnchor).isActive = true
        
        // This needs to be false since we are using auto layout constraints
//        buttonBar.translatesAutoresizingMaskIntoConstraints = false
//        buttonBar.backgroundColor = UIColor(red: 30/255, green: 163/255, blue: 163/255, alpha: 1.0)
//        view.addSubview(buttonBar)
//        // Constrain the top of the button bar to the bottom of the segmented control
//        buttonBar.bottomAnchor.constraint(equalTo: line.topAnchor).isActive = true
//        buttonBar.heightAnchor.constraint(equalToConstant: 5).isActive = true
//        // Constrain the button bar to the left side of the segmented control
//        buttonBar.leftAnchor.constraint(equalTo: friendSegmentControl.leftAnchor).isActive = true
//        // Constrain the button bar to the width of the segmented control divided by the number of segments
//        buttonBar.widthAnchor.constraint(equalTo: friendSegmentControl.widthAnchor, multiplier: 1 / CGFloat(friendSegmentControl.numberOfSegments)).isActive = true
        friendSegmentControl.addTarget(self, action: #selector(self.indexChanged(_:)), for: UIControl.Event.valueChanged)
    }
    
   
    
   
    
} // view controller
