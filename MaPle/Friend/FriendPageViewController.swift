//
//  FriendPageViewController.swift
//  MaPle
//
//  Created by Violet on 2018/10/23.
//

import UIKit

class FriendPageViewController: UIViewController {
    
    @IBOutlet weak var friendSegmentControl: UISegmentedControl!
    @IBOutlet weak var friendView: UIView!
    @IBOutlet weak var invitationView: UIView!
    @IBOutlet weak var matchView: UIView!
    
    //MARK: - change friend page segment
    @IBAction func indexChanged(_ sender: UISegmentedControl) {
        switch friendSegmentControl.selectedSegmentIndex
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
        
        friendView.isHidden = false
        invitationView.isHidden = true
        matchView.isHidden = true
    }
    
    // MARK: - Payment Alert
    func paymentAlert() {
        let paymentAlert = UIAlertController(title: "內購尊榮會員升等服務", message: "尊榮會員升等服務 \n 1.享有每日配段次數10次", preferredStyle: .alert)
        let conform = UIAlertAction(title: "同意", style: .default) { (action) in
            self.paymentProcess()
        }
        let cancel = UIAlertAction(title: "取消", style: .cancel)
        paymentAlert.addAction(conform)
        paymentAlert.addAction(cancel)
        present(paymentAlert, animated: true)
    }
    func paymentProcess() {
        
    }
    

}
