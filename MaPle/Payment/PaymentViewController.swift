//
//  PaymentViewController.swift
//  MaPle
//
//  Created by Paul Chen on 2018/11/27.
//
import StoreKit
import UIKit

class PaymentViewController:UIViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver{
    
    var productIDs: [String] = [String]()
    var productsArray: [SKProduct] = [SKProduct]()
    var selectedProductIndex: Int!
    var isProgress: Bool = false
    var lodingView: LodingView?
    
    let messageTitle = "尊榮會員升等服務"
    let message = "現在升等VIP立即開啟聊天室功能~!"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lodingView = LodingView(frame: UIScreen.main.bounds)
        self.view.addSubview(self.lodingView!)
        
        self.productIDs.append("Not_Consumable_Product")
        self.requestProductInfo()
        
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        SKPaymentQueue.default().remove(self)
    }
    
    @IBAction func IABbtn(_ sender: UIButton) {
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
    
    
    func showMessage(_ product: Product) {
        var message: String!
        
        switch product {
        case .nonConsumable:
            message = "升等成功！"
        }
        
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
        // 購買後執行
        
    }
    
}
enum Product {
    case nonConsumable
}
