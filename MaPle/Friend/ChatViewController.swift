//
//  ChatViewController.swift
//  MaPle
//
//  Created by 蘇曉彤 on 2018/12/6.
//

import UIKit
import Photos
import MobileCoreServices
import Starscream

class ChatViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, WebSocketDelegate {
    

    @IBOutlet weak var chatView: ChatView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendphotoButton: UIButton!
    @IBOutlet weak var sendTextButton: UIButton!
    @IBOutlet weak var inputTextField: UITextField!
    let communicator = FriendCommunicator.shared
    var socket : WebSocket!
    
    //上一頁帶入
    var friendName : String! //尚未使用
    var friendId : Int!
    
    //先key的假資料
    let userId = UserDefaults.standard.string(forKey: "MemberID")
    var userName: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        socketConnect()
        if userId != nil {
            userName = Communicator.friendsListIndex[userId!]
        }
        
        if friendId != nil {
            friendName = Communicator.friendsListIndex[String(friendId)]
        }
        self.navigationItem.leftItemsSupplementBackButton = true
        inputTextField.delegate = self
        
        //取得照片權限
        PHPhotoLibrary.requestAuthorization { (status) in
            print("PHPhotoLibrary.requestAuthorization: \(status.rawValue)")
        }
        
        //鍵盤上移
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillChangeFrame),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        hideKeyboardWhenTappedAround()
//        let Id = String(self.friendId)
//        getProfile(friendId: Id)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if socket.isConnected {}
        socket.disconnect()
    }
    
//    func getProfile(friendId: String) {
//        communicator.getfriendName(friendid: friendId) { (result, error) in
//            if let error = error {
//                print("getAllFriend error:\(error)")
//                return
//            }
//            guard let result = result else {
//                print("result is nil")
//                return
//            }
//            self.friendName = result as? String
//            print("get friend: \(self.friendName)")
//        }
//    }
    
    @IBAction func sendPhotoPressed(_ sender: UIButton) {
        
        //選擇照片來源
        let alert = UIAlertController(title: "請選擇傳送照片的方式：", message: nil, preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: "相機", style: .default) { (action) in
            self.launchPicker(source: .camera)
        }
        let library = UIAlertAction(title: "相片膠卷", style: .default) { (action) in
            self.launchPicker(source: .photoLibrary)
        }
        let cancel = UIAlertAction(title: "取消", style: .destructive)
        alert.addAction(camera)
        alert.addAction(library)
        alert.addAction(cancel)
        present(alert, animated: true)
        
    }
    
    func launchPicker(source: UIImagePickerController.SourceType) {
        //Check if the source is valid or not?
        guard UIImagePickerController.isSourceTypeAvailable(source) else {
            print("Invalid source type")
            return
        }
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.mediaTypes = [kUTTypeImage, kUTTypeMovie] as [String]
        picker.sourceType = source
        picker.allowsEditing = true //裁切！1.只提供照片正方形的裁切 2.提供影片的時段裁切，會出現在影片的上方列
        present(picker, animated: true)
    }
    
    
    // MARK: - UIImagePickerControllerDelegate Protocol Methods.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("info: \(info)")
        //mediaType指照片或影片
        //info[UIImagePickerController.InfoKey.mediaType]可精簡成[.mediaType]
        guard let type = info[.mediaType] as? String
            else {
                assertionFailure("Invalid type")
                return
        }
        if type == (kUTTypeImage as String) {
            guard let originalImage = info[.originalImage] as? UIImage else {
                assertionFailure("originalImage is nil")
                return
            }
            //resizedImage是設定圖檔的最大邊長
            let resizedImage = originalImage.resize(maxEdge: 400)!
            //compressionQuality壓縮率
            //數字越小檔案越小，數字越大檔案越大（0.8/0.7 大小較剛好）
            //let jpgData = resizedImage.jpegData(compressionQuality: 0.8)
            let pngData = resizedImage.pngData()
            print("pngData: \(pngData!.count)")
            //            print("pngData: \(pngData!.count)")
            let base64Data = pngData!.base64EncodedData(options: NSData.Base64EncodingOptions(rawValue: 0))
            let imageBase64String = String(data: base64Data, encoding: .utf8)
//            let imageBase64String = jpgData?.base64EncodedString()
//            let imageBase64String = jpgData?.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
            guard let userid = userId else {
                assertionFailure("userid is nil")
                return
            }
            let socket_PhotoItem = ChatMessage(type: "chat", sender: userid, senderName: userName!, receiver: String(friendId) , content: imageBase64String!, messageType: "image")
            let socketData = try! JSONEncoder().encode(socket_PhotoItem)
            let socketString = String(data: socketData, encoding: .utf8)!
            socket.write(string: socketString)

            let image = UIImage(data: pngData!)
            let textDetail = "\(userName!)"
            let type: ChatSenderType = .fromMe
            var chatItem = ChatItem(text: textDetail, image: nil, senderType: type)
            chatItem.image = image
            chatView.add(chatItem: chatItem)
            
            
        } else if type == (kUTTypeMovie as String) {
            //...
        }
        picker.dismiss(animated: true) //收起picker
    }
    
    
    @IBAction func sendTextPressed(_ sender: UIButton) {
        
        guard let text = inputTextField.text, !text.isEmpty else {
            return
        }
        guard let userid = userId else {
            assertionFailure("userid is nil")
            return
        }
        //需更改成登入的使用者
        let socket_TextItem = ChatMessage(type: "chat", sender: userid, senderName: userName!, receiver: String(friendId) , content: text, messageType: "text")
        let socketData = try! JSONEncoder().encode(socket_TextItem)
        let socketString = String(data: socketData, encoding: .utf8)!
        socket.write(string: socketString)
        
        let textDetail = "\(userName!) : \(text)"
        let type: ChatSenderType = .fromMe
        var chatItem = ChatItem(text: textDetail, image: nil, senderType: type)
        chatView.add(chatItem: chatItem)

        inputTextField.resignFirstResponder()
    }
    
    // 鍵盤上移
    @objc func keyboardWillChangeFrame(_ notification: Notification) {
        let info = notification.userInfo
        let kbRect = (info?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let offsetY = kbRect.origin.y - UIScreen.main.bounds.height
        UIView.animate(withDuration: 0.1) {
            if offsetY == 0 {
                self.view.transform = CGAffineTransform(translationX: 0, y: 0)
            }else{
                self.view.transform = CGAffineTransform(translationX: 0, y: offsetY)
            }
        }
    }
    //關閉鍵盤
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    //點擊空白處可收起鍵盤
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        //tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        socket.disconnect()
    }
    
    
    
    func socketConnect() {
        guard let userId = userId else {
            assertionFailure("userid is nil")
            return
        }
        let url = URL(string: FriendCommunicator.SOCKET_URL + userId)
        print("socket user : \(userId)")
        socket = WebSocket(url: url!)
        socket.delegate = self
        socket.connect()
    }
    
    public func websocketDidConnect(socket: WebSocketClient) {
        print("websocket is connected")
    }
    
    public func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("websocket is disconnected: \(error?.localizedDescription)")
        socket.disconnect()
        socket.connect()
    }
    
    //IOS text+pic & Android text
    public func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print("got some text: \(text)")
        
        let decoder = JSONDecoder()
        let jsonData = text.data(using: String.Encoding.utf8, allowLossyConversion: true)!
        guard let message = try? decoder.decode(ChatMessage.self, from: jsonData) else {
            print("state Message")
            return
        }
       
        
        print("ChatViewController receiver: \(message.senderName)")
        
        if message.messageType == "text" {
            let textDetail = "\(message.senderName): \(message.content)"
            let type: ChatSenderType = .fromOthers
            let chatItem = ChatItem(text: textDetail, image: nil, senderType: type)
            chatView.add(chatItem: chatItem)
        } else {
            let textDetail = "\(message.senderName): \(message.content)"
            let type: ChatSenderType = .fromOthers
            let base64String = message.content
            let decodeData = Data(base64Encoded: base64String, options: NSData.Base64DecodingOptions(rawValue: 0))
            let image = UIImage(data: decodeData!)
            var chatItem = ChatItem(text: textDetail, image: nil, senderType: type)
            chatItem.image = image
            chatView.add(chatItem: chatItem)
        }
        
        
    }
    
    //Android pic
    public func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("got some data: \(data.count)")
        
        
        let decoder = JSONDecoder()
        guard let resultObject = try? decoder.decode(ChatMessage.self, from: data) else {
            return
        }
        print("resultObject-----> \(resultObject)")
        let textDetail = "\(resultObject.senderName):"
        let type : ChatSenderType = .fromOthers
        let base64String = resultObject.content
        
        guard let decodeData = Data(base64Encoded: base64String, options: Data.Base64DecodingOptions.ignoreUnknownCharacters) else {
            assertionFailure("decodeData fail.")
            return
        }
        let image = UIImage(data: decodeData)
        var chatItem = ChatItem(text: textDetail, image: nil, senderType: type)
        chatItem.image = image
        chatView.add(chatItem: chatItem)
    }

}


