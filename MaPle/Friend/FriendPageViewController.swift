//
//  FriendPageViewController.swift
//  MaPle
//
//  Created by Violet on 2018/10/23.
//

import StoreKit
import UIKit

class FriendPageViewController: UIViewController
, SKProductsRequestDelegate, SKPaymentTransactionObserver
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
        
        prepareForPayment()
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
    
    
    // MARK - Payment
    
    var productIDs = Set<String>()
    var productsArray = [SKProduct]()
    
    var isProgress: Bool = false
    var lodingView: LodingView?
    
    
    let TAG = "FriendPageViewController : "
    let messageTitle = "尊榮會員升等服務"
    let message = "現在升等VIP立即開啟聊天室功能~!"
    
    var serverCommunicator : ServerCommunicator?
    var vipStatus : Int?
    
    
    func prepareForPayment() {
        
       
        guard let memberId = UserDefaults.standard.object(forKey: "IntMemberID") as? Int else {
            return
        }
        print(TAG, memberId)
        self.serverCommunicator = ServerCommunicator(memberId)
        
//        self.lodingView = LodingView(frame: UIScreen.main.bounds)
//        self.view.addSubview(self.lodingView!)
//        
        productIDs.insert("Vip") // Todo add the productId
        self.requestProductInfo()
        
        serverCommunicator!.loadUserVipStatus { (results, error) in
            
            guard let result = results!["vipStatus"]as? Int else {
                assertionFailure("Json covertion fail")
                return
            }
            self.vipStatus = result
            
        }
        
    }

    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        SKPaymentQueue.default().remove(self)
    }
    
    @IBAction func IABbtn(_ sender: UIBarButtonItem) {
        showActionSheet(Product.nonConsumable)
    }
    
    func requestProductInfo() {
        
        if SKPaymentQueue.canMakePayments() {
            print("ProductId : \(productIDs)")
            let productRequest = SKProductsRequest(productIdentifiers: productIDs)
            
            productRequest.delegate = self
            productRequest.start()
        } else {
            print("取不到任何內購的商品...")
        }
    }
    
    
    func showMessage(_ message: String) {
    
        let alertController = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
        let confirm = UIAlertAction(title: "是", style: .default, handler: nil)
    
        alertController.addAction(confirm)
    
        self.present(alertController, animated: true, completion: nil)
    }




    // MARK: - Delegate

    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        
        if response.products.count != 0 {
            
            for product in response.products {
                self.productsArray.append(product)
                print(product)
            }
            
        } else {
            print("取不到任何商品...")
        }
        if response.invalidProductIdentifiers.count != 0 {
            print(response.invalidProductIdentifiers.description)
        }
    }


    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for transaction in transactions {
            switch transaction.transactionState {
            case SKPaymentTransactionState.purchased:
                print("交易成功")
                SKPaymentQueue.default().finishTransaction(transaction)
                
                self.isProgress = false
                
                SKPaymentQueue.default().remove(self)
                
                afterPaymentFinish()
                
                self.dismiss(animated: true, completion: nil)
            case SKPaymentTransactionState.failed:
                print("SKPaymentTransactionState.failed")
                
                if let error = transaction.error as? SKError {
                    switch error.code {
                    case .paymentCancelled:
                        print("Transaction Cancelled: \(error.localizedDescription)")
                    case .paymentInvalid:
                        print("Transaction paymentInvalid: \(error.localizedDescription)")
                    case .paymentNotAllowed:
                        print("Transaction paymentNotAllowed: \(error.localizedDescription)")
                    default:
                        print("Transaction: \(error.localizedDescription)")
                    }
                }
                
                SKPaymentQueue.default().finishTransaction(transaction)
                self.isProgress = false
            case SKPaymentTransactionState.restored:
                print("SKPaymentTransactionState.restore")
                
                SKPaymentQueue.default().finishTransaction(transaction)
                self.isProgress = false
                
            default:
                print(transaction.transactionState.rawValue)
            }
        }
    }

    func showActionSheet(_ product: Product) {
        
        if self.isProgress {
            return
        }
        var buyAction: UIAlertAction?
        
        switch product {
        case .nonConsumable:
            
            buyAction = UIAlertAction(title: "購買", style: UIAlertAction.Style.default) { (action) -> Void in
                if SKPaymentQueue.canMakePayments() {
                    SKPaymentQueue.default().add(self)
                    
                    let payment = SKPayment(product: self.productsArray[1])
                    
                    SKPaymentQueue.default().add(payment)
                    
                    self.isProgress = true
                }
            }
            
        }
        
        let actionSheetController = UIAlertController(title: self.messageTitle, message: self.message, preferredStyle: UIAlertController.Style.actionSheet)
        let cancelAction = UIAlertAction(title: "取消", style: UIAlertAction.Style.cancel, handler: nil)
        
        actionSheetController.addAction(buyAction!)
        actionSheetController.addAction(cancelAction)
        
        self.present(actionSheetController, animated: true, completion: nil)
    }

    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        print("restoreCompletedTransactionsFailed.")
        print(error.localizedDescription)
    }

    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        print("paymentQueueRestoreCompletedTransactionsFinished.")
    }

    func afterPaymentFinish(){
        guard let memberId = UserDefaults.standard.object(forKey: "IntMemberID") as? Int else {
            return
        }
        serverCommunicator!.updateUserVipStatus(memberId) { (results, error) in
            if let error = error {
                assertionFailure("failed to update Vip status error code : \(error)")
                return
            }
            guard let result = results!["response"]as? Int else {
                assertionFailure("Json covertion fail")
                return
            }
            if result == 1 {
                self.view.setNeedsDisplay()
            } else {
                self.showMessage("操作錯誤, 請重新來過~!")
            }
        }
    }
    enum Product {
        case nonConsumable
    }
} // view controller
