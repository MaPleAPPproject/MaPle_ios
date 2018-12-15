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
    var memberId = UserDefaults.standard.integer(forKey: "MemberIDint")
    
    @IBOutlet weak var layout: UICollectionViewFlowLayout!
    
    @IBOutlet weak var collectionViewLayout: UICollectionViewFlowLayout!
    let communicator = Communicator.shared
    
    @IBOutlet weak var collectCollectionView: UICollectionView!
    @IBOutlet weak var postCollectionView: UICollectionView!

    var posts = [Post]()
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        postCollectionView.register(PostCollectionViewCell.self, forCellWithReuseIdentifier: "PostCell")
      
        setScrollView()
        loadUserprofile(memberId: memberId)
        setTapGestureForPhotoIcon()
        downloadPhotoIcon(memberId: memberId)
        getCollectionIds(memberId: memberId)
        getPostIds(memberId: memberId)
        print(#function)
        
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
     getCollectionIds(memberId: memberId)
     loadUserprofile(memberId: memberId)
     getPostIds(memberId: memberId)
     postCollectionView.reloadData()
        
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
       
        shouldSetEmptyView(collectionView)
        return collectionView.tag == 0 ? postIds.count :  collectionIds.count
    }
    
    func shouldSetEmptyView(_ collectionView: UICollectionView){
        if collectionView.tag == 0 {
            if postIds.count == 0 {
                postCollectionView.setEmptyView()
            } else {
                postCollectionView.restore()
            }
        } else  {
            print("*collectionIds.count:\(collectionIds.count)")
            if collectionIds.count == 0 {
                collectCollectionView.setEmptyView2()
            } else {
                collectCollectionView.restore()
            }
        }
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
       
        
            return 1
        
    }
    
   
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
        switch collectionView.tag {
        case 0:
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostCell", for: indexPath) as! PostCollectionViewCell
            if postIds.count == 0 {
                return cell}
            let postId = self.postIds[indexPath.row]
            
            communicator.getPostImage(postId: postId) { (data, error) in
                if let error = error {
                    printHelper.println(tag: "Mypageviewcontroller", line: #line, "error:\(error)")
                    return
                }
                
                guard let data = data else {
                    print("data is nil")
                    return
                }
                
                guard let image = UIImage(data: data) else {return }
                DispatchQueue.main.async {
                    cell.postImageView.image = image
                    
                }
                
            }
            return cell
            
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as! CollectCollectionViewCell
            
            let postId = self.collectionIds[indexPath.row]
            communicator.getPostImage(postId: postId) { (data, error) in
                if let error = error {
                    printHelper.println(tag: "Mypageviewcontroller", line: #line, "error:\(error)")
                    return
                }
                
                guard let data = data else {
                    print("data is nil")
                    return
                }
                
                guard let image = UIImage(data: data) else {return }
                DispatchQueue.main.async {
                    cell.collectImageView.image = image
                    
                }
                
            }
            return cell
            
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostCell", for: indexPath) as! PostCollectionViewCell
            
            return cell
            
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
            
            let id = String(memberId)
            Communicator.friendsListIndex[id] = resultObject.userName
            
            
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
    
    func getPostIds(memberId: Int){
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
            
            self.postIds = resultObject
            DispatchQueue.main.async {
                self.postCollectionView.reloadData()
            }
            
        }
    }
    
    
    func getCollectionIds(memberId: Int) {
        
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
            
            
           self.collectionIds = resultObject
            print("*self.collectionIds:\(self.collectionIds)")
            DispatchQueue.main.async {
                self.collectCollectionView.reloadData()
            }
            
        }
    }
    
    func getPostImage(postId: Int) -> UIImage?{
        var finalImage = UIImage()
        self.communicator.getPostImage(postId: postId, completion: { (data, error) in
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
            
            finalImage = image
            
        })
        return finalImage
        
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        switch segue.identifier {
        case "postShowSegue":
            
            let controller = segue.destination as! SinglePostViewController
            if let indexPath = postCollectionView.indexPathsForSelectedItems?.first {
                
                let postId = postIds[indexPath.row]
                print("postShowSegue prepare postId:\(postId)")
                controller.postId = postId
                controller.memberId = self.memberId
                
            }
        case "collectShowSegue":
            let controller = segue.destination as!  PictureDetailViewController
            if let indexPath = collectCollectionView.indexPathsForSelectedItems?.first {
                print("indexPath:\(indexPath.row)")
                let postId = collectionIds[indexPath.row]
                print("collectShowSegue prepare postId:\(postId)")
            }
            return
        default:
            return
        }
        
    }
    
    
    
    
    @IBAction func unwind(_ segue: UIStoryboardSegue) {
        print(#function)
        if segue.identifier == "fromUserProfileSegue"{
            let segue = segue.source as! UserprofileViewController
            let image = segue.photoIcon.image
            self.photoIcon.image = image
            self.userNameLabel.text = segue.userNameLabel.text
            self.selfIntroLabel.text = segue.selfIntroTextView.text
        }
        
        if segue.identifier == "toMyPage" {
            
            loadUserprofile(memberId: memberId)
            setTapGestureForPhotoIcon()
            downloadPhotoIcon(memberId: memberId)
            getCollectionIds(memberId: memberId)
            getPostIds(memberId: memberId)
        }
        
        if segue.identifier == "backToMyPage" {
            
            getPostIds(memberId: memberId)
            DispatchQueue.main.async {
                self.postCollectionView.reloadData()
            }
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

extension UICollectionView {
    func setEmptyView(){
        let image = UIImage(named: "emptyview2")
        let imageView = UIImageView(image: image)
        imageView.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
        let emptyView = imageView
        self.backgroundView = emptyView
    }
    
    func setEmptyView2(){
        let image = UIImage(named: "emptyView4")
        let imageView = UIImageView(image: image)
        imageView.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
       
        let emptyView = imageView
        self.backgroundView = emptyView
    }
    
    func restore() {
    self.backgroundView = nil

    }
}

struct PostIdResult: Codable {
    
    //    var postsPostIdByMember: [PostIdByMember]?
    var postIds:[Int]?
    
}











