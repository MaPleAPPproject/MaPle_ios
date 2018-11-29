//
//  FriendPageViewController.swift
//  MaPle
//
//  Created by Violet on 2018/10/23.
//

import UIKit
import Alamofire

class FriendPageViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
       

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
//    func vipStatusUpdate(memberId: String) -> Bool {
//
//    }
    
    

}
