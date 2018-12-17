//
//  UserprofileViewController.swift
//  MaPle
//
//  Created by juiying chiu on 2018/11/27.
//

import UIKit
import Photos


class UserprofileViewController: UIViewController {
    let imageManager = ImageManager.shared
    var squareImage = UIImage()

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nameEditBtn: UIButton!
   
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var nameEditStack: UIStackView!
    let communicator = Communicator.shared
    let picker = UIImagePickerController()
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var photoIcon: UIImageView!
     var memberId = UserDefaults.standard.integer(forKey: "MemberIDint")
    @IBOutlet weak var vipStatus: UILabel!
   
    @IBOutlet weak var selfIntroTextView: UITextView!
    @IBOutlet weak var passwordEditStackView: UIStackView!
    var isShowEditStack = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUserprofile(memberId: memberId)
        downloadPhotoIcon(memberId: memberId)
        configureView()
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(changePhoto))
        photoIcon.addGestureRecognizer(gestureRecognizer)
        photoIcon.isUserInteractionEnabled = true
        
        //        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        
        picker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    
    
    
    func authorize() -> Bool {
        let photoLibraryStatus = PHPhotoLibrary.authorizationStatus() //相簿請求
        let camStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video) //相機請求
        switch (camStatus, photoLibraryStatus){ //判斷狀態
        case (.authorized,.authorized): //兩個都允許
            return true
        case (.notDetermined,.notDetermined): //兩個都還未決定,就請求授權
            AVCaptureDevice.requestAccess(for: AVMediaType.video,  completionHandler: { (status) in
                DispatchQueue.main.async(execute: {
                    _ = self.authorize()
                })
            })
            PHPhotoLibrary.requestAuthorization({ (status) in
                DispatchQueue.main.async(execute: {
                    _ = self.authorize()
                })
            })
        case (.authorized,.notDetermined): //相機允許，相簿未決定，相簿請求授權
            PHPhotoLibrary.requestAuthorization({ (status) in
                DispatchQueue.main.async(execute: {
                    _ = self.authorize()
                })
            })
        case (.authorized,.denied): //相機允許，相簿拒絕，做出提醒
            let alertController = UIAlertController(title: "提醒❗️", message: "您目前拍攝的照片並不會儲存至相簿，要前往設定嗎?", preferredStyle: .alert)
            let canceAlertion = UIAlertAction(title: "取消", style: .cancel, handler: {(status) in
                UIImagePickerController.isSourceTypeAvailable(.camera)
                let photoImagePC = UIImagePickerController()
                photoImagePC.delegate = self
                photoImagePC.sourceType = .camera
                self.show(photoImagePC, sender: self)
            })
            let settingAction = UIAlertAction(title: "設定", style: .default, handler: { (action) in
                let url = URL(string: UIApplication.openSettingsURLString)
                if let url = url, UIApplication.shared.canOpenURL(url) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                            print("跳至設定")
                        })
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                }
            })
            alertController.addAction(canceAlertion)
            alertController.addAction(settingAction)
            self.present(alertController, animated: true, completion: nil)
        default: //預設，如都不是以上狀態
            DispatchQueue.main.async(execute: {
                let alertController = UIAlertController(title: "提醒❗️", message: "請點擊允許才可於APP內開啟相機及儲存至相簿", preferredStyle: .alert)
                let canceAlertion = UIAlertAction(title: "取消", style: .cancel, handler: nil)
                let settingAction = UIAlertAction(title: "設定", style: .default, handler: { (action) in
                    let url = URL(string: UIApplication.openSettingsURLString)
                    if let url = url, UIApplication.shared.canOpenURL(url) {
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                                print("跳至設定")
                            })
                        } else {
                            UIApplication.shared.openURL(url)
                        }
                    }
                })
                alertController.addAction(canceAlertion)
                alertController.addAction(settingAction)
                self.present(alertController, animated: true, completion: nil)
            })
        }
        return false
    }
    
    
    
    @objc
    func changePhoto(){
        let alert = UIAlertController(title: "更改大頭貼", message: "請選擇相片來源", preferredStyle: .alert)
        let camera = UIAlertAction(title: "相機", style: .default){ (action) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) &&
                UIImagePickerController.isCameraDeviceAvailable(.front) &&
                UIImagePickerController.isCameraDeviceAvailable(.rear){
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                picker.cameraDevice = .front
                picker.cameraCaptureMode = .photo
                
                picker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
                self.present(picker, animated: true, completion: nil)
                
                
            }
        }
        let gallery = UIAlertAction(title: "相簿", style: .default) { (action) in
            
            //                let picker = UIImagePickerController()
            //                picker.sourceType = .photoLibrary
            //                picker.allowsEditing = true
            //
            //                picker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
            let state = self.authorize()
            if state == true {
                self.present(self.picker, animated: true, completion: nil)
            }
            
            
            
            
        }
        alert.addAction(camera)
        alert.addAction(gallery)
        present(alert,animated: true)
    }
    
    @IBAction func saveUserProfile(_ sender: UIBarButtonItem) {
        let queue = DispatchQueue(label: "dispatchQueue")
        queue.sync {
            self.updateUserProfile()

        }
        communicator.loadUserProfile(memberId: memberId) { (result, error) in
            if let error = error {
                print("loadUserProfile error:\(error)")
                return
            }
            
            guard let result = result else {
                print("result is nil")
                return
            }
            
            guard let jsonObject = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
                else {
                    print("loadUserprofile Fail to generate jsonData")
                    return
            }
            let decoder = JSONDecoder()
            guard let resultObject = try? decoder.decode(Userprofile.self
                , from: jsonObject) else {
                    print("loadUserprofile Fail to decode jsonData.")
                    return
            }
            print("I am going to mypage")
            self.performSegue(withIdentifier: "fromUserProfileSegue", sender: resultObject)
        }
//        print("I am going to mypage")
//        performSegue(withIdentifier: "fromUserProfileSegue", sender: sender)
        
    }
    
    @IBAction func userNameEditBtnPressed(_ sender: UIButton) {
        userNameLabel.isHidden = true
        nameEditBtn.isHidden = true
        nameEditStack.isHidden = false
    }
    
    
    @IBAction func nameEditOKBtnPressed(_ sender: UIButton) {
        
        
        guard let username = nameTextField.text else { return }
        if !username.isEmpty {
            userNameLabel.text = nameTextField.text
            offNameEditMode()
        } else {
            showAlert(title: "Oops", message: "您尚未輸入任何字元喔！")
          
        }
        
    }
    
    @IBAction func nameEditCancelBtnPressed(_ sender: UIButton) {
        offNameEditMode()
        
        
    }
    
    
    
    func offNameEditMode(){
        userNameLabel.isHidden = false
        nameEditBtn.isHidden = false
        nameEditStack.isHidden = true
        nameTextField.text = ""
        nameTextField.placeholder = "Your name"
    }
    
    func showAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default)
        alert.addAction(ok)
        present(alert,animated: true)
    }
    
    func configureView(){
        let viewHeight:CGFloat = isShowEditStack ? 150 : 0.0
        passwordEditStackView.visiblity(gone: false, dimension: viewHeight)
       
        selfIntroTextView.layer.borderWidth = 1
        selfIntroTextView.layer.borderColor = UIColor.gray.cgColor
    }
    
    @IBAction func passwordOKBtnPressed(_ sender: UIButton) {
        
        
        guard let newPassword = newPasswordTextField!.text,
            let confirmPassword = confirmPasswordTextField!.text else {
                print("newPassword or confirmPassword is nil ")
                return
        }
        
        if !newPassword.isEmpty && !confirmPassword.isEmpty {
            
            if newPassword.elementsEqual(confirmPassword) {
                passwordLabel.text = newPassword
                passwordEditStackView?.visiblity(gone: true, dimension: 0.0)
                confirmPasswordTextField!.text = ""
                newPasswordTextField!.text = ""
                
            } else {
              showAlert(title: "Oops", message: "請確認輸入的密碼必須一致！")
             
               
                
            }
            
        } else {
             showAlert(title: "Oops", message: "您尚未輸入任何字元喔！")
           
            
        }
    }
    @IBAction func passwordCancelBtnPressed(_ sender: UIButton) {
        
        
        passwordEditStackView?.visiblity(gone: true, dimension: 0.0)
        confirmPasswordTextField!.text = ""
        newPasswordTextField!.text = ""
        
        
    }
    @IBAction func passwordEditBtnPressed(_ sender: UIButton) {
        
        //        passwordEditStackView.heightAnchor.constraint(equalToConstant: 165)
        isShowEditStack = true
        let viewHeight:CGFloat = isShowEditStack ? 150 : 0.0
        passwordEditStackView?.visiblity(gone: !isShowEditStack, dimension: viewHeight)
        newPasswordTextField.isSecureTextEntry = true
        confirmPasswordTextField.isSecureTextEntry = true
        
    }
    
    func loadUserprofile(memberId: Int){
        
        communicator.loadUserProfile(memberId: memberId) { (result, error) in
            if let error = error {
                print("loadUserProfile error:\(error)")
                return
            }
            
            guard let result = result else {
                print("result is nil")
                return
            }
            
            guard let jsonObject = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
                else {
                    print("loadUserprofile Fail to generate jsonData")
                    return
            }
            let decoder = JSONDecoder()
            guard let resultObject = try? decoder.decode(Userprofile.self
                , from: jsonObject) else {
                    print("loadUserprofile Fail to decode jsonData.")
                    return
            }
            
            
            self.userNameLabel?.text = resultObject.userName
            self.emailLabel?.text = resultObject.email
            self.passwordLabel?.text = resultObject.password
            //            self.postNumLabel?.text = String(resultObject.postCount)
            //            self.collectNumLabel?.text = String(resultObject.collectionCount)
            print("resultObject.selfIntroduction:\(resultObject.selfIntroduction)")
            self.selfIntroTextView?.text = resultObject.selfIntroduction
            let vipStatus = resultObject.vipStatus
            switch vipStatus {
            case 0:
                self.vipStatus.text = "Basic"
            case 1:
                self.vipStatus.text = "Premium"
            default:
                self.vipStatus.text = "Basic"
            }
            //
            
            
        }
        
    }
    
    
    
    
    func updateUserProfile(){
        guard let image = photoIcon.image,
            let userName = userNameLabel.text,
            let email = emailLabel.text,
            let password = passwordLabel.text,
            let vipStatus = self.vipStatus.text,
            let selfIntro = selfIntroTextView.text else {
                print("userProfile is nil")
                return
                
        }
        
        var vipStatusNum = 0
        switch vipStatus {
        case "Basic":
            vipStatusNum = 0
        case "Premium":
            vipStatusNum = 1
        default:
            vipStatusNum = 0
        }
        let photoImage = image.crop(ratio: 1)
        let imageBase64 = imageManager.convertImageToBase64(image: photoImage)
        //        guard let a = squareImage.jpegData(compressionQuality: 0.8),
        //         let aString = String(data: a, encoding: .utf8) else {
        //            print("aString is nil")
        //            return
        //
        //        }
        //       let data = squareImage.pngData()!
        //        guard let dataString = String(data: data, encoding: .utf8) else {
        //            print("dataString is nil")
        //            return
        //
        //        }
        let userProfile = Userprofile(memberId: memberId, email: email , password: password, userName: userName, selfIntroduction: selfIntro, vipStatus: vipStatusNum, postCount: 0, collectionCount: 0)
    
        communicator.updateUserprofile(userProfile: userProfile, imageBase64: imageBase64) { (result, error) in
            if let error = error {
                print("updateUserprofile error:\(error)")
                return
            }
            
            guard let result = result else {
                print("result is nil")
                return
            }
            
            let count = result as! Int
            switch count {
            case 0:
                print("Fail to update userProfile")
            case 1:
                print("Update userProfile OK")
            default :
                return
            }
            
        }
        
    }
    func downloadPhotoIcon(memberId: Int){
        
        let parameter:[String : Any] = ["action":"getImage", "memberId": memberId, "imageSize": 270]
        communicator.doPostData(urlString: communicator.USERPROFILE_URL, parameters: parameter) { (data, error) in
            if let error = error {
                printHelper.println(tag: "Mypageviewcontroller", line: #line, "error:\(error)")
                return
            }
            
            guard let data = data else {
                print("data is nil")
                return
            }
            
            let image = UIImage(data: data)
            
            DispatchQueue.main.async {
                self.photoIcon.image = image
                self.photoIcon.clipsToBounds = true
                self.photoIcon.layer.cornerRadius = self.photoIcon.frame.size.width / 2
            }
            
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    
}



extension UIView {
    
    func visiblity(gone: Bool, dimension: CGFloat = 0.0, attribute: NSLayoutConstraint.Attribute = .height) -> Void {
        if let constraint = (self.constraints.filter{$0.firstAttribute == attribute}.first) {
            constraint.constant = gone ? 0.0 : dimension
            self.layoutIfNeeded()
            self.isHidden = gone
        }
    }
}


extension UserprofileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @objc
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as! UIImage
        squareImage = image.crop(ratio: 1)
        photoIcon.image = squareImage
        dismiss(animated: true, completion: nil)
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("imagePickerControllerDidCancel")
    }
    
}


extension UIImage {
    
    //将图片裁剪成指定比例（多余部分自动删除）
    func crop(ratio: CGFloat) -> UIImage {
        
        
        //计算最终尺寸
        var newSize:CGSize!
        if size.width/size.height > ratio {
            newSize = CGSize(width: size.height * ratio, height: size.height)
        }else{
            newSize = CGSize(width: size.width, height: size.width / ratio)
        }
        
        ////图片绘制区域
        var rect = CGRect.zero
        rect.size.width  = size.width
        rect.size.height = size.height
        rect.origin.x    = (newSize.width - size.width ) / 2.0
        rect.origin.y    = (newSize.height - size.height ) / 2.0
        
        //绘制并获取最终图片
        UIGraphicsBeginImageContext(newSize)
        draw(in: rect)
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let finalImage = resizeImage(image: scaledImage!) else {
            print("finalImage is nil")
            return scaledImage!
        }
        return finalImage
    }
    
    
    
    
    
    func resizeImage(image: UIImage) -> UIImage? {
        var actualHeight: Float = Float(image.size.height)
        var actualWidth: Float = Float(image.size.width)
        let maxHeight: Float = 400.0
        let maxWidth: Float = 400.0
        var imgRatio: Float = actualWidth / actualHeight
        let maxRatio: Float = maxWidth / maxHeight
        let compressionQuality: Float = 0.5
        //50 percent compression
        
        if actualHeight > maxHeight || actualWidth > maxWidth {
            if imgRatio < maxRatio {
                //adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight
                actualWidth = imgRatio * actualWidth
                actualHeight = maxHeight
            }
            else if imgRatio > maxRatio {
                //adjust height according to maxWidth
                imgRatio = maxWidth / actualWidth
                actualHeight = imgRatio * actualHeight
                actualWidth = maxWidth
            }
            else {
                actualHeight = maxHeight
                actualWidth = maxWidth
            }
        }
        let rect = CGRect(x: 0.0, y: 0.0, width: CGFloat(actualWidth), height: CGFloat(actualHeight))
        //        let rect = CGRectMake(0.0, 0.0, CGFloat(actualWidth), CGFloat(actualHeight))
        UIGraphicsBeginImageContext(rect.size)
        image.draw(in: rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        //        let imageData = UIImage.JPEGRepresentation(img!,CGFloat(compressionQuality))
        let imageData1 = img?.jpegData(compressionQuality: 0.5)
        UIGraphicsEndImageContext()
        guard let imageData = imageData1 else {
            print("imageData1 = nil")
            return nil
        }
        return UIImage(data: imageData)!
    }
}
