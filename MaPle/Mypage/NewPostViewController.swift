//
//  NewPostViewController.swift
//  MaPle
//
//  Created by juiying chiu on 2018/11/28.
//

import UIKit
import UITextView_Placeholder

class NewPostViewController: UIViewController, UITextViewDelegate {
    let communicator = Communicator.shared
    
    
    @IBOutlet weak var postImage: UIImageView!
    
    @IBOutlet weak var commentTextView: UITextView!
    
    @IBOutlet weak var locationLabel: UILabel!
    var squareImage = UIImage()
    var comment = String()
    var location = String()
    
    var selectedLocation: [ String : String ] = [:]
    let imageManager = ImageManager.shared
     var memberId = UserDefaults.standard.integer(forKey: "MemberIDint")
    var lat = Double()
    var lon = Double()
    var postId = Int()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
        setLocationLabel()
        //        getMemberIdFromUserDefault()
        
    }
    

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //        print("lat:\(self.lat)")
        //        print("lon:\(self.lon)")
        //        print("select location:\(self.selectedLocation)")
        //        setLocationLabel()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let image = postImage.image else {
            return
        }
        squareImage = image
        
        guard let comment = commentTextView.text else {
            return
        }
        self.comment = comment
        
    }
    
    func configView(){

        commentTextView.placeholderColor = UIColor.darkGray
        commentTextView.placeholder = "What's new"
        commentTextView.returnKeyType = .done
        commentTextView.delegate = self
        postImage.layer.borderColor = UIColor.black.cgColor
        postImage.layer.borderWidth = 0.2
        
        let tapgestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(changePhoto))
        postImage.addGestureRecognizer(tapgestureRecognizer)
        postImage.isUserInteractionEnabled = true
        
    }
    
    
    func setLocationLabel(){
        
        if selectedLocation.isEmpty {
            locationLabel.text = "請點選紅色圖標選擇地點"
            
        } else {
            
            
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
        let source =  segue.source as! MapLocationViewController
        print(source.selectedLocation)
        self.selectedLocation = source.selectedLocation
        
        let countryCode = (source.selectedLocation["countryCode"])
        let country = (source.selectedLocation["country"])
        let adminArea = (source.selectedLocation["adminarea"])
        let district = (source.selectedLocation["district"])
        self.lat = source.lat
        self.lon = source.lon
        print("lat:\(lat)")
        print("lon:\(lon)")
        
        var placeString = ""
        
        if district != nil {
            placeString += district!
            placeString += ", "
        } else {
            
            placeString += adminArea!
            placeString += ", "
        }
        placeString += country!
        print("placeString:\(placeString)")
        locationLabel.text = placeString
        
    }
    
    
    @IBAction func cancelBarBtnPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "請確定要離開嗎？", message: "此次修改將不會被儲存", preferredStyle: .alert)
        let yes = UIAlertAction(title: "我要離開", style: .default) { (action) in
            self.performSegue(withIdentifier: "triggerByCancel", sender: self)
        }
        
        let no = UIAlertAction(title: "繼續編輯", style: .default, handler: nil)
        alert.addAction(yes)
        alert.addAction(no)
        present(alert, animated: true)
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
        let country = selectedLocation["country"] ?? ""
        let address = selectedLocation["address"] ?? ""
        let district = selectedLocation["district"] ?? ""
        let countryCode = selectedLocation["countryCode"] ?? ""
        let adminArea = selectedLocation["adminarea"] ?? ""
        var addressString = ""
        var districtString = ""
        if district == ""{
            addressString = country + ", " + address
            districtString = adminArea + ", " + country
        } else {
            addressString = country + ", " + district + ", " + address
            districtString = district + "," + country
        }
       
        let locaiton = Location(postId: nil, district: districtString, address: addressString, latitude: lat , longitude: lon, countryCode: countryCode)
        
        
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
    var latitude: Double?
    var longitude: Double?
    var countryCode: String?
}
