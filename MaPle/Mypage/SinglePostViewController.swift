//
//  SinglePostViewController.swift
//  MaPle
//
//  Created by juiying chiu on 2018/11/26.
//

import UIKit

class SinglePostViewController: UIViewController {
    
    @IBOutlet weak var photoIcon: UIImageView!
    @IBOutlet weak var postImage: UIImageView!
    
    @IBOutlet weak var postedDateLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var commentLabel: UILabel!
    
    var post: Post!
    var postId: Int?
    let communicator = Communicator.shared
    var memberIdFromCollection = Int(){
        didSet{
            
            downloadPhotoIcon(memberId: memberIdFromCollection)
            //            print("memberIdFromCollection:\(memberIdFromCollection)")
        }
    }
     var memberId = UserDefaults.standard.integer(forKey: "MemberIDint")
    //        Int(){
    //        didSet{
    //
    //            configPost()
    //            print("memberId:\(memberId)")
    //        }
    //    }
    override func viewDidLoad() {
        super.viewDidLoad()
        configPost()
        
        let rightEditBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.edit, target: self, action: #selector(modifyBarButtonTapped))
        let rightTrashBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.trash, target: self, action: #selector(deletBarButtonTapped))
        
        let backbutton = UIButton(type: .custom)
        backbutton.setImage(UIImage(named: "backward-arrow-2"), for: .normal) // Image can be downloaded from here below link
        backbutton.setTitle("Back", for: .normal)
        backbutton.setTitleColor(backbutton.tintColor, for: .normal) // You can change the TitleColor
        backbutton.addTarget(self, action:#selector(backBtnPressed), for: .touchUpInside)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backbutton)
        self.navigationItem.setRightBarButtonItems([rightEditBarButtonItem,rightTrashBarButtonItem], animated: true)
    }
    
    @objc
    func backBtnPressed(){
        performSegue(withIdentifier: "backToMyPage", sender: self)
    }
    
    @objc
    func modifyBarButtonTapped(){
        
        performSegue(withIdentifier: "editPostSegue", sender: self)
    }
    @objc
    func deletBarButtonTapped(){
        let alert = UIAlertController(title: "刪除貼文", message: "請問確定要刪除此篇貼文嗎？", preferredStyle: .alert)
        let yes = UIAlertAction(title: "是", style: .default) { (action) in
            guard let postId = self.postId else {return}
            
            self.communicator.deletePost(postId: postId, completion: { (result, error) in
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
                case 0...2:
                    print("Fail to delete post")
                    self.performSegue(withIdentifier: "backToMyPage", sender: self)
                    break
                case 3:
                    print("Delete Post OK")
                    self.performSegue(withIdentifier: "backToMyPage", sender: self)
                    break
                default :
                    self.performSegue(withIdentifier: "backToMyPage", sender: self)
                    break
                }
            })
        }
        alert.addAction(yes)
        let cancel = UIAlertAction(title: "取消", style: .default, handler: nil)
        alert.addAction(cancel)
        present(alert, animated: true)
        
    }
    
    
    @IBAction func markerBtnPressed(_ sender: UIButton) {
    }
    
    func configPost(){
        guard let postId = self.postId else {return}
        self.loadPost(postId: postId)
        getPostImage(postId: postId)
        downloadPhotoIcon(memberId: memberId)
    }
    
    
    
    func loadPost(postId: Int) {
        
        
        communicator.getPost(postId: postId) { (result, error) in
            printHelper.println(tag: "SinglePost", line: #line, "postId:\(postId)")
            guard let jsonObject = self.handleResult(result: result, error: error) else {
                return
            }
            
            let decoder = JSONDecoder()
            guard let resultObject = try? decoder.decode(Post.self
                , from: jsonObject) else {
                    print("handleResult Fail to decode jsonData.")
                    return
            }
            
            self.commentLabel.text = resultObject.comment
            self.locationLabel.text = resultObject.district
            self.nameLabel.text = resultObject.userName
            
            let date = resultObject.postedDate
            let index = date.index(date.startIndex, offsetBy: 16)
            self.postedDateLabel.text = "發文時間：\(String(date[..<index]))"
            
        }
    }
    
    override func viewDidLayoutSubviews() {
        self.locationLabel.sizeToFit()
    }
    
    func handleResult(result: Any?, error: Error?) -> Data? {
        if let error = error {
            print("getPost error:\(error)")
            return nil
        }
        
        guard let result = result else {
            print("result is nil")
            return nil
        }
        
        guard let jsonObject = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
            else {
                print("Fail to generate jsonData")
                return nil
        }
        
        
        return jsonObject
    }
    
    
    func downloadPhotoIcon(memberId: Int){
        
        
        let parameter:[String : Any] = ["action":"getImage", "memberId": memberId, "imageSize": 270]
        communicator.doPostData(urlString: communicator.USERPROFILE_URL, parameters: parameter) { (data, error) in
            if let error = error {
                printHelper.println(tag: "SinglePost", line: #line, "error:\(error)")
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.photoIcon.image = UIImage(named: "adduser")
                }
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
    
    func getPostImage(postId:Int){
        
        
        self.communicator.getPostImage(postId: postId, completion: { (data, error) in
            if let error = error {
                printHelper.println(tag: "SinglePostViewController", line: #line, "error:\(error)")
                return
            }
            
            guard let data = data else {
                print("data is nil")
                return
            }
            
            guard let image = UIImage(data: data) else {
                print("image is nil")
                return}
            self.postImage.image = image
            
        })
    }
    
    
    func getMemberIdByPostId(postId: Int)   {
        
        self.communicator.getMemberIdByPostId(postId:postId ){ (result, error) in
            printHelper.println(tag: "SinglePost", line: #line, "postId:\(postId)")
            
            
            if let error = error {
                print("getPost error:\(error)")
                return
            }
            
            guard let memberId = result as? Int else {
                print("result is nil")
                return
            }
            
            print("memberId:\(memberId)")
            
            self.memberIdFromCollection = memberId
            
            
            
        }
    }
    
    @IBAction func unwind(_ segue: UIStoryboardSegue) {
        if segue.identifier == "updatePostDoneSegue"{
            viewDidLoad()
        }
    }
    
    
    
    
    // MARK: - Navigation
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editPostSegue" {
            if let nvVC = segue.destination as? UINavigationController {
                guard let controller = nvVC.topViewController as? ModifyPostViewController else {
                    return
                }
                guard let image = self.postImage.image,
                    let comment = self.commentLabel.text,
                    let location = self.locationLabel.text,
                    let postId = self.postId else {
                        return
                }
                
                controller.squareImage = image
                controller.comment = comment
                controller.location = location
                controller.postId = postId
                
            }
            
            
        }
        
        
    }
    
    
    
    
}
