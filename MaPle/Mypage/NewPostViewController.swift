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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
        
        
        // Do any additional setup after loading the view.
    }
    
    func configView(){
        commentTextView.text = "What's new?"
        commentTextView.textColor = UIColor.lightGray
        commentTextView.font = UIFont(name: "verdana", size: 13.0)
        commentTextView.returnKeyType = .done
        commentTextView.delegate = self
        commentTextView.layer.borderColor = UIColor.green.cgColor
        commentTextView.layer.borderWidth = 1
        
        postImage.layer.borderColor = UIColor.black.cgColor
        postImage.layer.borderWidth = 0.2
        
        let tapgestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(changePhoto))
        postImage.addGestureRecognizer(tapgestureRecognizer)
        postImage.isUserInteractionEnabled = true
       
       
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
    

    @IBAction func locationBtn(_ sender: UIButton) {
        
        
    }
    @IBAction func savePost(_ sender: UIBarButtonItem) {
        
//        communicator.insertNewPost(memberId: <#T##Int#>, imageBase64: <#T##String#>, comment: <#T##String#>, locationTable: <#T##Location#>) { (<#Any?#>, <#Error?#>) in
//            <#code#>
//        }
        
        
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


extension NewPostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @objc
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as! UIImage
        squareImage = image.crop(ratio: 1)
        postImage.image = squareImage
        dismiss(animated: true, completion: nil)
        
    }
    
}
