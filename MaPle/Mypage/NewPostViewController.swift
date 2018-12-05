//
//  NewPostViewController.swift
//  MaPle
//
//  Created by juiying chiu on 2018/11/28.
//

import UIKit

class NewPostViewController: UIViewController, UITextViewDelegate {
    let communicator = Communicator.shared
    
    
    @IBOutlet weak var postImage: UIImageView!
    
    @IBOutlet weak var commentTextView: UITextView!
    
    @IBOutlet weak var locationLabel: UILabel!
    var squareImage = UIImage()
    var comment = String()
    var location = String()
    var isEditMode = false
    var selectedLocation: [ String : String ] = [:]
    let imageManager = ImageManager.shared
    let memberId = 2
    var lat = Double()
    var lon = Double()
    var postId = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
        setLocationLabel()
        
        
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setLocationLabel()
    }
    
    func configView(){
        commentTextView.text = "What's new?"
        commentTextView.textColor = UIColor.lightGray
        commentTextView.font = UIFont(name: "verdana", size: 13.0)
        commentTextView.returnKeyType = .done
        commentTextView.delegate = self
        
        
        postImage.layer.borderColor = UIColor.black.cgColor
        postImage.layer.borderWidth = 0.2
        
        let tapgestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(changePhoto))
        postImage.addGestureRecognizer(tapgestureRecognizer)
        postImage.isUserInteractionEnabled = true
        
        if isEditMode {
            postImage.image = squareImage
            commentTextView.text = comment
        }
        
        
        
        
        
    }
    
    
    func setLocationLabel(){
        
        if isEditMode{
            locationLabel.text = location
            isEditMode = !isEditMode
            
        } else {
            
            if selectedLocation.isEmpty {
                locationLabel.text = "請點選紅色圖標選擇地點"
            } else {
                print(selectedLocation)
                
                let country = (selectedLocation["country"])
                let adminArea = (selectedLocation["adminarea"])
                let district = (selectedLocation["district"])
                var placeString = country!
                
                
                if district != nil {
                    placeString += district!
                } else {
                    placeString += adminArea!
                }
                
                locationLabel.text = placeString
                
            }
            
        }
        
        
        
    }
    
    
    @objc
    func changePhoto(){
        let alert = UIAlertController(title: nil, message: "請選擇相片來源", preferredStyle: .alert)
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
            
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.allowsEditing = true
            
            picker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
            self.present(picker, animated: true, completion: nil)
            
            
            
        }
        alert.addAction(camera)
        alert.addAction(gallery)
        present(alert,animated: true)
    }
    
    @IBAction func unwind(_ segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func cancelBarBtnPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "請確定要離開嗎？", message: "此次修改將不會被儲存", preferredStyle: .alert)
        let yes = UIAlertAction(title: "我要離開", style: .default) { (action) in
            self.performSegue(withIdentifier: "toMyPage", sender: self)
        }
        
        let no = UIAlertAction(title: "繼續編輯", style: .default, handler: nil)
        alert.addAction(yes)
        alert.addAction(no)
        present(alert, animated: true)
    }
    
    @IBAction func markerBtnPressed(_ sender: UIButton) {
    }
    
    func showAlert(message: String){
        let alert = UIAlertController(title: "提醒", message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "了解", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true)
    }
    @IBAction func savePost(_ sender: UIBarButtonItem) {
        
        guard let photoImage = postImage.image else {
            showAlert(message: "請加入照片~")
            return
        }
        
        
        let imageBase64 = imageManager.convertImageToBase64(image: photoImage.crop(ratio: 1))
        guard let comment = commentTextView.text else {
            showAlert(message: "請加入貼文內容~")
            return
        }
        
        guard let country = selectedLocation["country"],
            let address = selectedLocation["address"],
            let district = selectedLocation["district"],
            let countryCode = selectedLocation["countryCode"] else {
                showAlert(message: "請加入地點資訊！")
                return
                
        }
        
        let addressString = "\(country) ,\(district), \(address)"
        let locaiton = Location(postId: nil, district: addressString, address: address, lat: lat , lon: lon, countryCode: countryCode)
        
        
        communicator.insertNewPost(memberId: memberId, imageBase64: imageBase64, comment: comment, locationTable: locaiton) { (result, error) in
            
            if let error = error {
                print("insertNewPost error:\(error)")
                return
            }
            
            guard let result = result else {
                print("result is nil")
                return
            }
            
            let resultDict = result as! Dictionary< String, Int>
            
            
            let pictureCount = resultDict["pictureCount"]
            let locationCount = resultDict["locationCount"]
            
            if pictureCount == 1 && locationCount == 1{
                print("Post inserting OK")
                
                guard let postId = resultDict["postId"] else { return }
                self.postId = postId
                self.performSegue(withIdentifier: "toMyPage", sender: self)
                
            } else {
                print("Fail to insert post")
                self.performSegue(withIdentifier: "toMyPage", sender: self)
            }
            
        }
        
        
        
    }
    
    // MARK: - Navigation
    
}


extension NewPostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @objc
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as! UIImage
        squareImage = image.crop(ratio: 1)
        postImage.image = squareImage
        dismiss(animated: true, completion: nil)
        
    }
    
}


struct Location: Codable {
    var postId:Int?
    var district: String?
    var address: String?
    var lat: Double?
    var lon: Double?
    var countryCode: String?
}
