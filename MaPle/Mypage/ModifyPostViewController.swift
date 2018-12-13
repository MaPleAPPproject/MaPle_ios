//
//  ModifyPostViewController.swift
//  MaPle
//
//  Created by juiying chiu on 2018/12/10.
//

import UIKit

class ModifyPostViewController: UIViewController ,UITextViewDelegate{
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
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func configView(){
        commentTextView.text = comment
        commentTextView.textColor = UIColor.darkGray
        commentTextView.font = UIFont(name: "verdana", size: 15.0)
        commentTextView.returnKeyType = .done
        commentTextView.delegate = self
        
        postImage.layer.borderColor = UIColor.black.cgColor
        postImage.layer.borderWidth = 0.2
        
        let tapgestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(changePhoto))
        postImage.addGestureRecognizer(tapgestureRecognizer)
        postImage.isUserInteractionEnabled = true
        postImage.image = squareImage
        
    }
    
    
    func setLocationLabel(){
        
        if selectedLocation.isEmpty {
            locationLabel.text = location
        } else {
            
            let countryCode = (selectedLocation["countryCode"])
            let country = (selectedLocation["country"])
            let adminArea = (selectedLocation["adminarea"])
            let district = (selectedLocation["district"])
            
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
        self.lat = source.lat
        self.lon = source.lon
        
        setLocationLabel()

        
        
    }
    
    @IBAction func cancelBarBtnPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "請確定要離開嗎？", message: "此次修改將不會被儲存", preferredStyle: .alert)
        let yes = UIAlertAction(title: "我要離開", style: .default) { (action) in
            self.performSegue(withIdentifier: "cancelUpdatePostSegue", sender: self)
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
    
    
    @IBAction func saveBtnPressed(_ sender: UIBarButtonItem) {
        var post :UpdatePost
        print(selectedLocation)
        guard let photoImage = postImage.image else {
            showAlert(message: "請加入照片~")
            return
        }
        
        let imageBase64 = imageManager.convertImageToBase64(image: photoImage.crop(ratio: 1))
        guard let comment = commentTextView.text else {
            showAlert(message: "請加入貼文內容~")
            return
        }
        if !selectedLocation.isEmpty{
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
            
            post = UpdatePost(countryCode: countryCode, address: addressString
                , district: districtString, latitude: lat, longitude: lon, comment: comment)
            }else {
            post = UpdatePost(countryCode: nil, address: nil, district: nil, latitude: nil , longitude: nil, comment: comment)
        }
        
        communicator.updatePost(postId: postId , imageBase64: imageBase64, post: post) { (result, error) in
            if let error = error {
                print("Update post error:\(error)")
                return
            }
            
            guard let result = result else {
                print("result is nil")
                return
            }
            let count = result as! Int
            
            if count == 1 {
                print("Updating post OK")
                self.performSegue(withIdentifier: "updatePostDoneSegue", sender: self)
                
            } else {
                print("Fail to update post")
                self.showAlert(message: "貼文更新失敗，請再試一次！")
                //                self.performSegue(withIdentifier: "updatePostDoneSegue", sender: self)
            }
        }
    }
    
    
    // MARK: - Navigation
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "updatePostDoneSegue" {
           
            
            let controller = segue.destination as! SinglePostViewController
            controller.postId = self.postId
        }
    }
}

extension ModifyPostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @objc
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as! UIImage
        squareImage = image.crop(ratio: 1)
        postImage.image = squareImage
        dismiss(animated: true, completion: nil)
        
    }
    
}
struct UpdatePost: Codable{
    var countryCode: String?
    var address: String?
    var district: String?
    var latitude: Double?
    var longitude: Double?
    var comment: String?
}





