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
    var friendName : String!
    var friendId : Int!
    
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
    }
    
    
    @IBAction func sendPhotoPressed(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "請選擇傳送照片的方式：", message: nil, preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: "相機\t📷", style: .default) { (action) in
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
        guard UIImagePickerController.isSourceTypeAvailable(source) else {
            print("Invalid source type")
            return
        }
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.mediaTypes = [kUTTypeImage, kUTTypeMovie] as [String]
        picker.sourceType = source
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    
    // MARK: - UIImagePickerControllerDelegate Protocol Methods.
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("info: \(info)")
        guard let type = info[.mediaType] as? String
            else {
                assertionFailure("Invalid type")
                return
        }
        if type == (kUTTypeImage as String) {
            guard let originalImage = info[.editedImage] as? UIImage else {
                assertionFailure("originalImage is nil")
                return
            }
            let resizedImage = originalImage.resize(maxEdge: 400)!
            let pngData = resizedImage.pngData()
            print("pngData: \(pngData!.count)")
            let base64Data = pngData!.base64EncodedData(options: NSData.Base64EncodingOptions(rawValue: 0))
            let imageBase64String = String(data: base64Data, encoding: .utf8)
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
            showToast(message: "請輸入文字訊息唷\t✏️")
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
    //toast
    func showToast(message : String) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 200, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
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
        if socket.isConnected{
        socket.disconnect()
    }
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
//        socket.disconnect()
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
