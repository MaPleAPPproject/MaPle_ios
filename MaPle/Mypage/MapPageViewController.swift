//
//  MapPageViewController.swift
//  MaPle
//
//  Created by Violet on 2018/10/23.
//

//
//  FirstViewController.swift
//  MaPle
//
//  Created by Violet on 2018/10/23.
//

import UIKit
import CarbonKit


class MyPageViewController:
UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    
    
    
    
    @IBOutlet weak var selfIntroLabel: UILabel!
    @IBOutlet weak var collectNumLabel: UILabel!
    @IBOutlet weak var postNumLabel: UILabel!
    
    @IBOutlet weak var collectView: UIView!
    @IBOutlet weak var postView: UIView!
    @IBOutlet weak var photoIcon: UIImageView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    var postIdArray = [Int]()
    var postIds = [Int]()
    var collectionIds = [Int]()
    
    @IBOutlet weak var layout: UICollectionViewFlowLayout!
    
    
    @IBOutlet weak var collectionViewLayout: UICollectionViewFlowLayout!
    let communicator = Communicator.shared
    
    
    @IBOutlet weak var collectCollectionView: UICollectionView!
    @IBOutlet weak var postCollectionView: UICollectionView!
    var memberId = 2
    var posts = [Post]()
    var images = [UIImage]() {
        didSet{
            //           postCollectionView.reloadData()
        }
        
        willSet{
            postCollectionView.reloadData()
        }
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    var collectImages = [UIImage](){
        didSet{
            //            collectCollectionView.reloadData()
        }
        
        willSet{
            collectCollectionView.reloadData()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setScrollView()
        loadUserprofile(memberId: memberId)
        setTapGestureForPhotoIcon()
        
        
        downloadPhotoIcon()
        
        getAllPostImages(memberId: memberId) // posts in postView
        getCollections()
        getAllPosts()
        //         postCollectionView.reloadData()
        //         collectCollectionView.reloadData()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        
        
        
    }
    
    @IBAction func segmentValueChanged(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            self.postView.isHidden = false
            self.collectView.isHidden = true
        case 1:
            self.postView.isHidden = true
            self.collectView.isHidden = false
        default:
            return
        }
        
    }
    
    // MARK:- scrollView method
    
    func setScrollView() {
        let fullSize = UIScreen.main.bounds.size
        scrollView.contentSize.width = fullSize.width
        scrollView.contentSize.height = fullSize.height * 2
        scrollView.showsVerticalScrollIndicator = true
        scrollView.isScrollEnabled = true
        setFlowLayout(layout: layout)
        setFlowLayout(layout: collectionViewLayout)
    }
    
    // MARK:- Set segue to userprofile
    
    func setTapGestureForPhotoIcon(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(toUserProfiles))
        photoIcon.isUserInteractionEnabled = true
        photoIcon.addGestureRecognizer(tapGestureRecognizer)
    }
    
    // MARK: - collectionView Methods
    func setFlowLayout (layout:UICollectionViewFlowLayout!){
        let fullScreenSize = UIScreen.main.bounds.size
        postCollectionView.delegate = self
        postCollectionView.dataSource = self
        collectCollectionView.delegate = self
        collectCollectionView.dataSource = self
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 0.5
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right:0)
        layout.itemSize = CGSize(width: (fullScreenSize.width - 2) / 3, height: (fullScreenSize.width - 2) / 3 )
        layout.scrollDirection = .vertical
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch collectionView.tag {
        case 0:
            return images.count
        case 1:
            return collectImages.count
        default:
            return images.count
        }
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        switch collectionView.tag {
        case 0:
            return 1
        case 1:
            return 1
        default:
            return 1
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch collectionView.tag {
        case 0:
            let cell = setCellForCollectionView(collectionView:collectionView ,withReuseIdentifier: "PostCell", indexPath: indexPath, imagesArray: images)
            
            return cell
        case 1:
            
            let cell =  setCellForCollectionView(collectionView:collectionView ,withReuseIdentifier: "CollectionCell", indexPath: indexPath, imagesArray: collectImages)
            
            return cell
            
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "", for: indexPath)
            return cell
            
        }
        
        
        
        
        
    }
    
    func setCellForCollectionView(collectionView: UICollectionView, withReuseIdentifier:String, indexPath: IndexPath, imagesArray:[UIImage]) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: withReuseIdentifier, for: indexPath)
        
        if withReuseIdentifier == "PostCell"{
            guard let finalCell = cell as? PostCollectionViewCell else {
                return cell
            }
            
            if imagesArray.count > 0 {
                DispatchQueue.main.async {
                    finalCell.postImageView.image = imagesArray[indexPath.row]
                    self.postCollectionView.reloadData()
                    
                    
                }
            }
            return finalCell
            
        } else {
            guard let finalCell = cell as? CollectCollectionViewCell else {
                return cell
            }
            
            if imagesArray.count > 0 {
                DispatchQueue.main.async {
                    finalCell.collectImageView.image = imagesArray[indexPath.row]
                    self.collectCollectionView.reloadData()
                    
                }
            }
            return finalCell
        }
        
    }
    @objc
    func toUserProfiles(){
        
        performSegue(withIdentifier: "userprofileSegue", sender: self)
    }
    
    
    
    // MARK:- Load data from server.
    
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
            self.postNumLabel?.text = String(resultObject.postCount)
            self.collectNumLabel?.text = String(resultObject.collectionCount)
            self.selfIntroLabel?.text = resultObject.selfIntroduction
            
            
            
        }
        
    }
    
    
    func downloadPhotoIcon(){
        let memberId = 2
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
    
    func getAllPosts(){
        let memberId = 2
        communicator.getAllPostsByMemberId(memberId: memberId) { (result, error) in
            guard let jsonObject = self.handleResult(result: result, error: error) else {
                return
            }
            
            let decoder = JSONDecoder()
            
            guard let resultObject = try? decoder.decode( [Post].self
                , from: jsonObject ) else {
                    print(" Fail to decode jsonData.")
                    return
            }
            
            self.posts = resultObject
            print("self.posts:\(self.posts)")
            printHelper.printLog(item: self.posts)
        }
    }
    
    
    
    
    
    
    func handleResult(result: Any?, error: Error?) -> Data? {
        if let error = error {
            print("error:\(error)")
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
    
    // get all posts by memberId
    func getAllPostImages(memberId: Int){
        
        communicator.getAllPostIds(memberId: memberId) { (result, error
            ) in
            
            guard let jsonObject = self.handleResult(result: result, error: error) else {
                return
            }
            
            let decoder = JSONDecoder()
            
            guard let resultObject = try? decoder.decode( [Int].self
                , from: jsonObject ) else {
                    print(" Fail to decode jsonData.")
                    return
            }
            
            var resultPostIds = resultObject
            
            let count = resultPostIds.count
            
            if count > 0{
                for index in 0...count-1 {
                    let postId = resultPostIds[index]
                    self.postIds.append(postId)
                }
            }
            
            self.postIdArray = self.postIds
            printHelper.println(tag: "", line: #line, "self.postIdArray:\(self.postIdArray)")
            if self.postIdArray.count > 0 && !self.postIdArray.isEmpty{
                for index in 0..<self.postIdArray.count {
                    self.communicator.getPostImage(postId: self.postIdArray[index], completion: { (data, error) in
                        if let error = error {
                            printHelper.println(tag: "Mypageviewcontroller", line: #line, "getPostImage error:\(error)")
                            return
                        }
                        
                        guard let data = data else {
                            print("getPostImage data is nil")
                            return
                        }
                        
                        guard let image = UIImage(data: data) else {
                            print("getPostImage is nil")
                            return}
                        self.images.append(image)
                        self.postCollectionView.reloadData()
                        
                    })
                }
                DispatchQueue.main.async{
                    
                    self.layout.invalidateLayout()
                }
                
            } else {
                print("postIdArray is nil or empty.")
            }
            
        }
        
    }
    
    
    func getCollections() {
        let memberId = 2
        communicator.getCollectionIdsByMemeber(memberId: memberId) { (result, error) in
            guard let jsonObject = self.handleResult(result: result, error: error) else {
                return
            }
            
            let decoder = JSONDecoder()
            
            guard let resultObject = try? decoder.decode( [Int].self
                , from: jsonObject ) else {
                    print(" Fail to decode jsonData.")
                    return
            }
            
            var resultCollectionIds = resultObject
            
            let count = resultCollectionIds.count
            
            if count > 0{
                for index in 0...count-1 {
                    let collectionId = resultCollectionIds[index]
                    self.collectionIds.append(collectionId)
                }
            }
            
            printHelper.println(tag: "", line: #line, " self.collectionIds:\(self.collectionIds)")
            if self.collectionIds.count > 0 && !self.collectionIds.isEmpty{
                for index in 0..<self.collectionIds.count {
                    self.communicator.getPostImage(postId: self.collectionIds[index], completion: { (data, error) in
                        if let error = error {
                            printHelper.println(tag: "Mypageviewcontroller", line: #line, "error:\(error)")
                            return
                        }
                        
                        guard let data = data else {
                            print("data is nil")
                            return
                        }
                        
                        guard let image = UIImage(data: data) else {
                            print("image is nil")
                            return}
                        self.collectImages.append(image)
                        self.collectCollectionView.reloadData()
                        
                        
                    })
                }
                
            } else {
                print("postIdArray is nil or empty.")
            }
            
        }
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        switch segue.identifier {
        case "postShowSegue":
            let controller = segue.destination as!  SinglePostViewController
            if let indexPath = postCollectionView.indexPathsForSelectedItems?.first {
                print("indexPath:\(indexPath.row)")
                let postId = postIdArray[indexPath.row]
                print("postShowSegue prepare postId:\(postId)")
                controller.postId = postId
                
                controller.memberId = self.memberId
                
            }
        case "collectShowSegue":
            let controller = segue.destination as!  SinglePostViewController
            if let indexPath = collectCollectionView.indexPathsForSelectedItems?.first {
                print("indexPath:\(indexPath.row)")
                let postId = collectionIds[indexPath.row]
                print("collectShowSegue prepare postId:\(postId)")
                controller.collectionId = postId
            }
            return
        default:
            return
        }
        
    }
}


extension MyPageViewController: UIScrollViewDelegate{
    
}



extension Communicator {
    func loadUserProfile(memberId:Int, completion:@escaping DoneHandler) {
        let parameters: [String : Any] = [ACTION_KEY:FINDBYID_KEY
            , MEMBERID_KEY: memberId]
        doPost(urlString: USERPROFILE_URL, parameters: parameters, completion: completion)
        print("loadUserProfile")
        print("parameters:\(parameters)")
        
    }
    
    func getAllPostIds(memberId:Int, completion:@escaping DoneHandler) {
        
        let parameters: [String : Any] = [ACTION_KEY:"getPostIds"
            , "memberId": memberId]
        doPost(urlString: CPOST_URL, parameters: parameters, completion: completion)
        
        print("getAllPostId parameters:\(parameters)")
        
    }
    
    func getPostImage(postId:Int, completion:@escaping DownloadDoneHandler) {
        let parameters:[String:Any] = [ACTION_KEY: "getImage", "postid":postId, "imageSize":270]
        
        doPostData(urlString: PICTURE_URL, parameters: parameters, completion: completion)
        printHelper.println(tag: "MyPageViewController", line: #line, #function)
        print("getPostImage parameters:\(parameters)")
    }
    
    func getCollectionIdsByMemeber(memberId:Int, completion:@escaping DoneHandler) {
        let parameters: [String : Any] = [ACTION_KEY:"getCollectionIds"
            , "memberId": memberId]
        doPost(urlString: CPOST_URL, parameters: parameters, completion: completion)
        print("getAllPostId parameters:\(parameters)")
        
    }
}

struct Userprofile: Codable {
    var memberId: Int
    var email: String
    var password: String
    var userName: String
    var selfIntroduction: String
    var vipStatus: Int
    var postCount: Int
    var collectionCount: Int
    enum CodingKeys: String, CodingKey {
        case memberId = "memberId"
        case email = "email"
        case password = "password"
        case userName = "userName"
        case selfIntroduction = "selfIntroduction"
        case vipStatus = "vipStatus"
        case postCount = "postcount"
        case collectionCount = "collectcount"
    }
    
    init(memberId:Int,email: String, password: String, userName: String, selfIntroduction: String, vipStatus: Int, postCount:Int, collectionCount: Int) {
        self.memberId = memberId
        self.email = email
        self.password = password
        self.userName = userName
        self.selfIntroduction = selfIntroduction
        self.vipStatus = vipStatus
        self.postCount = postCount
        self.collectionCount = collectionCount
        
    }
    
}


struct Post: Codable {
    //    var postId:Int?
    //    var pictureId:Int
    //    var location:String
    var comment:String
    //    var countryCode: String
    //    var address: String
    var district: String
    //    var latitude: Double
    //    var longitude: Double
    var userName: String?
    var postedDate: String
    
}

struct  PostIdByMember :Codable {
    
    var comment: String?
    var date: CLong?
    var lat: Double?
    var lon: Double?
    var postId: Int?
    enum CodingKeys: String, CodingKey {
        case comment = "comment"
        case date = "date"
        case lat = "lat"
        case lon = "lon"
        case postId = "postid"
    }
    
}

struct PostIdResult: Codable {
    
    //    var postsPostIdByMember: [PostIdByMember]?
    var postIds:[Int]?
    
}









