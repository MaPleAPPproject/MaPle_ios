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
    var postId: Int? {
        didSet{
            
        }
    }
    var collectionId: Int?{
        didSet{
           
             configCollection()
        }
    }
    let communicator = Communicator.shared
    var memberIdFromCollection = Int(){
        didSet{
           
            downloadPhotoIcon(memberId: memberIdFromCollection)
//            print("memberIdFromCollection:\(memberIdFromCollection)")
        }
    }
    var memberId = Int(){
        didSet{
            
            configPost()
            print("memberId:\(memberId)")
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
//        guard let postId = self.postId else {return}
//        print("getMemberIdByPostId.postId:\(postId)")
       
//        getMemberIdByPostId(postId: 1)
//        print("memberIdFromCollection:\(memberIdFromCollection)")
   
       
      
       
       
       
       
        
        // Do any additional setup after loading the view.
//        guard  let postIdItem = self.postId ,
//        let post = loadPost(postId: postIdItem)  else {return}
//        print("post:\(post)")
//        postedDateLabel.text = post.postedDate
//        nameLabel.text = post.userName
//        locationLabel.text = post.district
//        commentLabel.text = post.comment
        
    }
    

    @IBAction func markerBtnPressed(_ sender: UIButton) {
    }
    
    func configPost(){
        guard let postId = self.postId else {return}
        self.loadPost(postId: postId)
        getPostImage(postId: postId)
        downloadPhotoIcon(memberId: memberId)
    }
    
    func configCollection() {
        guard let collectionId = self.collectionId else {return}
        self.loadPost(postId: collectionId)
        getMemberIdByPostId(postId: collectionId)
        getPostImage(postId: collectionId)
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
            
//            let decoder = JSONDecoder()
//            guard let resultObject = try? decoder.decode( Int.self
//                , from: result as! Data) else {
//                    print("handleResult Fail to decode jsonData.")
//                    return
//            }
//            guard let memberId = result as! Int else {return}
            self.memberIdFromCollection = memberId
            
           
          
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
