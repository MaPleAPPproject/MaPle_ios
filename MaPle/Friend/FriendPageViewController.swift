//
//  FriendPageViewController.swift
//  MaPle
//
//  Created by Violet on 2018/10/23.
//

import StoreKit
import UIKit

class FriendPageViewController: UIViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
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
    // MARK - Payment
    
    var productIDs: [String] = [String]()
    var productsArray: [SKProduct] = [SKProduct]()
    var selectedProductIndex: Int!
    var isProgress: Bool = false
    var lodingView: LodingView?
    
    
    let messageTitle = "尊榮會員升等服務"
    let message = "現在升等VIP立即開啟聊天室功能~!"
    var memberId = 1 // Todo
    var serverCommunicator : ServerCommunicator?
    
    
    func prepareForPayment() {
        
        
        super.viewDidLoad()
        self.serverCommunicator = ServerCommunicator(memberId)
        
        //        self.lodingView = LodingView(frame: UIScreen.main.bounds)
        //        self.view.addSubview(self.lodingView!)
        //
        //        self.productIDs.append("Not_Consumable_Product")
        //        self.requestProductInfo()
        
        serverCommunicator!.loadUserVipStatus { (results, error) in
            
            guard let result = results!["vipStatus"]as? Int else {
                assertionFailure("Json covertion fail")
                return
            }
            self.memberId = result
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
            
            let productIdentifiers: Set<String> = NSSet(array: self.productIDs) as! Set<String>
            let productRequest: SKProductsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
            
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
        
        print("invalidProductIdentifiers： \(response.invalidProductIdentifiers.description)")
        
        if response.products.count != 0 {
            
            for product in response.products {
                self.productsArray.append(product)
            }
        }
        else {
            print("取不到任何商品...")
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
                    
                    let payment = SKPayment(product: self.productsArray[self.selectedProductIndex])
                    
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
}
