//
//  FriendlistTableViewController.swift
//  MaPle
//
//  Created by 蘇曉彤 on 2018/11/18.
import StoreKit
import UIKit
import Starscream
import StoreKit
class FriendlistTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  , SKProductsRequestDelegate, SKPaymentTransactionObserver{
    
    
    @IBOutlet var friendView: UIView!
    @IBOutlet weak var backgroundimageview: UIImageView!
    @IBOutlet weak var friendlistTableView: UITableView!
    let memberID = UserDefaults.standard.integer(forKey: "MemberIDint")

    let refreshControl = UIRefreshControl()
    
    let communicator = FriendCommunicator.shared
    var friendlist : [Friend_profile] = []
    var socket: WebSocket!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        prepareForPayment()
        friendlistTableView.delegate = self
        friendlistTableView.dataSource = self
        getfriends(memberid: memberID)
        friendlistTableView.separatorInset = UIEdgeInsets.zero
        friendlistTableView.separatorColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        
        
        //refreshControl
        if #available(iOS 10.0, *) {
            self.friendlistTableView.refreshControl = refreshControl
        } else {
            self.friendlistTableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshPictureData(_:)), for: .valueChanged)
        
//        if friendlist.isEmpty {
//            friendlistTableView.separatorStyle = .none
//            let backgroundImage = UIImage.init(named: "background_friend")
//            friendView.layer.contents = backgroundImage?.cgImage
//        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if friendlist.isEmpty {
            backgroundimageview.isHidden = false
            backgroundimageview.image = UIImage(named: "background_friend.png")
            friendlistTableView.isHidden = true
        }
    }
    
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if friendlist.count == 0 {
//            backgroundimageview.isHidden = false
//            backgroundimageview.image = UIImage(named: "background_friend.png")
//            friendlistTableView.isHidden = true
//            friendlistTableView.backgroundView? = UIImageView(image: UIImage(named: "background_friend.png"))
        } else {
            backgroundimageview.isHidden = true
            friendlistTableView.isHidden = false
        }
        return friendlist.count

    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FriendlistTableViewCell
        let friend = friendlist[indexPath.row]
        
        cell.selectionStyle = .none
        cell.nameLB.text = friend.Username
        cell.nameLB.adjustsFontSizeToFitWidth = true
        cell.introLB.text = friend.selfIntroduction
        cell.chatBt.tag = friend.FriendID
        if self.vipStatus == 1 {
            cell.chatBt.isHidden = false
        } else {
            cell.chatBt.isHidden = true
        }
        print(self.vipStatus)
        if self.vipStatus == 1 {
            cell.chatBt.isHidden = false
        } else {
            cell.chatBt.isHidden = true
        }
        communicator.getPhoto(id: friend.FriendID) { (data, error) in
            if let error = error {
                print("Download fail: \(error)")
                return
            }
            guard let photodata = data else {
                print("photo data is nil.")
                return
            }
            cell.photoIV.image = UIImage(data: photodata)
            cell.photoIV.clipsToBounds = true
            cell.photoIV.layer.cornerRadius = 60
            
        }
        return cell
    }
    
    
    
    // MARK: - Navigation
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "friendProfile" {
            guard  let targetVC = segue.destination as? OthersPage2CollectionViewController else {
                assertionFailure("Faild to get destination")
                return
            }
            guard let selectedIndexPath = self.friendlistTableView.indexPathForSelectedRow else {
                assertionFailure("failed to get indexpath.")
                return
            }
            targetVC.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            targetVC.navigationItem.leftItemsSupplementBackButton = true
            targetVC.memberid = friendlist[selectedIndexPath.row].FriendID
            targetVC.userName = friendlist[selectedIndexPath.row].Username
        }
    }
    
    
    
    func getfriends(memberid: Int) {
//        guard let memberId =  memberid else {
//            assertionFailure("memberid is nil")
//            return
//        }
        communicator.getAllFriend(memberid: memberid) { (result,error) in
            if let error = error {
                print("getAllFriend error:\(error)")
                return
            }
            guard let result = result else {
                print("result is nil")
                return
            }
            guard let jsonObject = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
                else {
                    print("Fail to generate jsonData")
                    return
            }
            
           
            let decoder = JSONDecoder()
            guard let resultObject = try? decoder.decode([Friend_profile].self, from: jsonObject) else {
                print("Fail to decode jsonData.")
                return
            }
            
            for data in resultObject{
            
                let id = String(data.FriendID)
                Communicator.friendsListIndex[id] = data.Username
            }
            print("friend list index: \(Communicator.friendsListIndex)")
            
            
            self.friendlist = resultObject
//            print("\(self.friendlist)")
            self.friendlistTableView.reloadData()
        }
    }
    
    //MARK:-ButtonAction
    @objc
    func refreshPictureData(_ sender: Any) {
        getfriends(memberid: memberID)
        self.refreshControl.endRefreshing()
    }
    
    @IBAction func chatPressed(_ sender: UIButton) {
        print("sender.tag:\(sender.tag)")
        if let controller = storyboard?.instantiateViewController(withIdentifier: "chatRoom") as? ChatViewController {
            controller.friendId = sender.tag
            controller.title = Communicator.friendsListIndex[String(sender.tag)]
            controller.navigationItem.leftItemsSupplementBackButton = true
            self.parent?.view.addSubview(controller.view)
            self.view.addSubview(controller.view)
            show(controller, sender: self)
        }
        
    }
    
    
    // MARK - Payment
    
    var productIDs = Set<String>()
    var productsArray = [SKProduct]()
    var isProgress: Bool = false
    
    let TAG = "FriendPageViewController : "
    let messageTitle = "尊榮會員升等服務"
    let message = "現在升等VIP立即開啟聊天室功能~!"
    let product = "VipUpdate"
    var serverCommunicator = ServerCommunicator()
    var vipStatus: Int = 0 {
        didSet {
            barBtnSize()
        }
        
    }
    
   
   
    @IBOutlet weak var paymentBtn: UIButton!
    @IBOutlet weak var PaymentBtnView: UIView!
    func barBtnSize() {
        
        
        if vipStatus == 1{
            paymentBtn.isHidden = true
            PaymentBtnView.frame.size.height = 0
        } else {
            paymentBtn.isHidden = false
            PaymentBtnView.frame.size.height = 40
            paymentBtn.setTitle("▷▷▷ 現在開通聊天室服務只需$30!! ◁◁◁", for: .normal)
        }
        self.friendlistTableView.reloadData()
        
    }
    
    func prepareForPayment() {
        SKPaymentQueue.default().add(self as SKPaymentTransactionObserver)
        vipVerify()
        barBtnSize()
        
    }
    
    
    func vipVerify(){
        guard let memberId = UserDefaults.standard.object(forKey: "MemberIDint") as? Int else {
            return
        }
        
        serverCommunicator.loadUserVipStatus(memberId){ (results, error) in
            
            guard let result = results!["vipStatus"] as? Int else {
                assertionFailure("Json covertion fail")
                return
            }
            self.vipStatus = result
        }
    }
    
    @IBAction func IABbtn(_ sender: UIButton) {
        requestProductInfo()
    }
    
    func requestProductInfo() {
        
        if SKPaymentQueue.canMakePayments() {
            
            let identifiers: Set<String> = [product]
            
            let request = SKProductsRequest(productIdentifiers: identifiers)
            
            request.delegate = self
            request.start()
            
            
        } else {
            print("取不到任何內購的商品...")
            showActionSheet()
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
                
            }
            
            if self.productsArray.count != 0 {
                SKPaymentQueue.default().add(self)
                
                let payment = SKPayment(product: self.productsArray.first!)
                
                SKPaymentQueue.default().add(payment)
                
                self.isProgress = true
            } else {
                print("\(TAG)用戶無法購買")
            }
            
        } else {
            print("\(TAG)取不到任何商品...")
        }
        if response.invalidProductIdentifiers.count != 0 {
            print("\(TAG)交易失敗商品名稱 : \(response.invalidProductIdentifiers.description)")
            showActionSheet()
        }
    }
    
    func transcationPurchasing(_ transcation: SKPaymentTransaction) {
        
        print("交易中...")
    }
    
    fileprivate func transcationPurchased(_ transcation: SKPaymentTransaction) {
        
        print("交易成功...")
        
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for transaction in transactions {
            switch transaction.transactionState {
            case SKPaymentTransactionState.purchased:
                print("\(TAG)交易成功")
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
    
    func showActionSheet() {
        
        if self.isProgress {
            return
        }
        var buyAction: UIAlertAction?
        
        
        buyAction = UIAlertAction(title: "購買", style: UIAlertAction.Style.default) { (action) -> Void in
            if SKPaymentQueue.canMakePayments() {
                SKPaymentQueue.default().add(self)
                if self.productsArray.count != 0 {
                    let payment = SKPayment(product: self.productsArray[1])

                    SKPaymentQueue.default().add(payment)

                    self.isProgress = true
                } else {
                    print("productArray is empty.")
                }
            }
            self.showPaymentAlert()
//            if self.vipStatus == 1{
//                self.vipStatus = 0
//            } else {
//                self.vipStatus = 1
//            }
        }
        
        let actionSheetController = UIAlertController(title: self.messageTitle, message: self.message, preferredStyle: UIAlertController.Style.actionSheet)
        let cancelAction = UIAlertAction(title: "取消", style: UIAlertAction.Style.cancel, handler: nil)
        
        actionSheetController.addAction(buyAction!)
        actionSheetController.addAction(cancelAction)
        
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    func showPaymentAlert(){
        let title = "iTune Store"
        let message = "如果您有 Apple ID, 用此 Apple ID 在這\n裡登入。 如果您使用過 iTunes Store 或\n iCloud, 您已有 Apple ID。\n"
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let confirm = UIAlertAction(title: "使用現有 Apple ID", style: .default){ (action) in
            self.showPaymentSignInAlert()
        }
        
        let createNewAccount = UIAlertAction(title: "建立 Apple ID", style: .default, handler: nil)
        let cancal = UIAlertAction(title: "取消", style: .default, handler: nil)
        
        alertController.addAction(confirm)
        alertController.addAction(createNewAccount)
        alertController.addAction(cancal)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func showPaymentSignInAlert() {
        let title = "需要登入"
        let message = "如果您有 Apple ID, 用此 Apple ID 在這\n裡登入。 如果您使用過 iTunes Store 或\n iCloud, 您已有 Apple ID。\n"
        
        let label = UILabel(frame: CGRect(x: 100, y: 100, width: 50, height: 50))
        label.text = "Text"
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirm = UIAlertAction(title: "購買", style: .default){(action) in
            
            self.showLoadingAlert()
            
            //MARK- refresh
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                self.dismiss(animated: false, completion: nil)
                let title = "確認您的 App 內建購買功能"
                let message = "您要以 NT$ 30 的價格購買一個 VipMemberShip 嗎? \n\n [Environment: Sandbox]"
                let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                
                let confirm = UIAlertAction(title: "購買", style: .default){ (action) in
                    
                    self.showLoadingAlert()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
                        
                        self.dismiss(animated: false, completion: nil)
                        self.afterPaymentFinish()
                    })
                }
                let cancel = UIAlertAction(title: "取消", style: .default, handler: nil)
                alertController.addAction(cancel)
                alertController.addAction(confirm)
                
                
                self.present(alertController, animated: true, completion: nil)
            })
            
        }
        let cancal = UIAlertAction(title: "取消", style: .default, handler: nil)
        
        alertController.addAction(cancal)
        alertController.addAction(confirm)
        
        alertController.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "example@icloud.com"
        })
        alertController.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "密碼"
            
            textField.isSecureTextEntry = true
        })
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showLoadingAlert(){
        
        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        print("restoreCompletedTransactionsFailed.")
        print(error.localizedDescription)
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        print("paymentQueueRestoreCompletedTransactionsFinished.")
    }
    
    func afterPaymentFinish(){
        guard let memberId = UserDefaults.standard.object(forKey: "MemberIDint") as? Int else {
            return
        }
        
        serverCommunicator.updateUserVipStatus(memberId) { (results, error) in
            if error != nil {
                assertionFailure("failed to update Vip status error code : \(error!)")
                return
            }
            guard let result = results!["response"]as? Int else {
                assertionFailure("Json covertion fail")
                return
            }
            if result == 1 {
                self.vipVerify()
                let title = "設定成功"
                let message = "您的購買已經成功。 \n\n [Environment: Sandbox]"
                let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                
                let confirm = UIAlertAction(title: "好", style: .default){ (action) in
                    
                }
                alertController.addAction(confirm)
                
                self.present(alertController, animated: true, completion: nil)
                
                
            }
            
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        SKPaymentQueue.default().remove(self as SKPaymentTransactionObserver)
    }
}
    
    
    
    
    

