//
//  newMyPageCollectionViewController.swift
//  MaPle
//
//  Created by Violet on 2018/12/13.
//

import UIKit


class newMyPageCollectionViewController: UICollectionViewController {

    @IBOutlet weak var colletctionViewFlowLayout: UICollectionViewFlowLayout!
    var memberid = UserDefaults.standard.integer(forKey: "MemberIDint")
    var finalheaferView = MyPageCollectionReusableView()
    var finalfooterrView = FooterCollectionReusableView()

    var iconData:Data?
    let exploreCommunicator = ExploreCommunicator.shared
    let myPagecommunicator = Communicator.shared
    //    var postDetail:PostDetail?
    var userProfile:Userprofile?
    var allpost = [Picture]()
    var allcollect = [Picture]()
    var data = [Picture]()
    let screensize = UIScreen.main.bounds.size
    var userName:String?
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        layout.minimumLineSpacing = 1
//        layout.minimumInteritemSpacing = 0.5
//        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right:0)
//        layout.itemSize = CGSize(width: (fullScreenSize.width - 2) / 3, height: (fullScreenSize.width - 2) / 3 )
        self.colletctionViewFlowLayout.itemSize = CGSize(width: screensize.width/3, height: screensize.width/3)
        self.colletctionViewFlowLayout.minimumLineSpacing = 0
        self.colletctionViewFlowLayout.minimumInteritemSpacing = 0

        let group: DispatchGroup = DispatchGroup()
        let queue1 = DispatchQueue(label: "queue1", attributes: .concurrent)
        queue1.async(group: group) {
            self.getProfile(memberid: self.memberid)
        }
        let queue2 = DispatchQueue(label: "queue2", attributes: .concurrent)
        queue2.async(group: group) {
            self.getAllpost(memberid: self.memberid)
            self.getAllcollection(memberid: self.memberid)
            
        }
        group.notify(queue: DispatchQueue.main) {
            print("處理完成data...")
            self.collectionView.reloadData()
        }
        
        let notificationName = Notification.Name("GetSegmentPosition")
        NotificationCenter.default.addObserver(self, selector: #selector(self.segmentControl(noti:)), name: notificationName, object: nil)
        
        //refreshControl
        if #available(iOS 10.0, *) {
            self.collectionView.refreshControl = refreshControl
        } else {
            self.collectionView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // renew collectcount
        getProfile(memberid: self.memberid)
        guard let headerSegment = self.finalheaferView.segmentControl else {
            return
        }
        if headerSegment.selectedSegmentIndex == 1 {
            self.data.removeAll()
            self.allcollect.removeAll()
            getAllcollection(memberid: self.memberid)
        } else if headerSegment.selectedSegmentIndex == 0 {
            self.data.removeAll()
            self.allpost.removeAll()
            getAllpost(memberid: self.memberid)
        }
        //        if self.segment.selectedSegmentIndex == 1 {
        //            segmentControl(self.segment)
        //        }
        
    }
   
    // MARK:- to Server action
    
    @objc
    func refreshData() {
        
        let group: DispatchGroup = DispatchGroup()
        let queue1 = DispatchQueue(label: "queue1", attributes: .concurrent)
        queue1.async(group: group) {
            self.getProfile(memberid: self.memberid)
        }
        let queue2 = DispatchQueue(label: "queue2", attributes: .concurrent)
        queue2.async(group: group) {
            self.getAllpost(memberid: self.memberid)
            self.getAllcollection(memberid: self.memberid)
            
        }
        group.notify(queue: DispatchQueue.main) {
            print("處理完成data...")
            self.collectionView.reloadData()
        }
        self.refreshControl.endRefreshing()
    }
    
    func getProfile(memberid: Int) {
        myPagecommunicator.loadUserProfile(memberId: memberid) { (result, error) in
            if let error = error {
                print("error:\(error)")
            }
            guard let result = result else {
                assertionFailure("result is nil")
                return
            }
            guard let jsonData = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted) else {
                assertionFailure("failed to get data")
                return
            }
            guard let finalResult = try? JSONDecoder().decode(Userprofile.self, from: jsonData) else {
                assertionFailure("fail to decode")
                return
            }
            self.userProfile = finalResult
            self.handleHeaderData(headerView: self.finalheaferView, userProfileData: finalResult)
        }
    }
    
    func getAllpost(memberid: Int) {
        
        exploreCommunicator.getAllPost(memberid: String(memberid)) { (result, error) in
            if let error = error {
                print("error:\(error)")
            }
            guard let result = result else {
                assertionFailure("result is nil")
                return
            }
            for item in result {
                guard let jsonData = try? JSONSerialization.data(withJSONObject: item, options: .prettyPrinted) else {
                    assertionFailure("fail to get data")
                    return
                }
                guard let finalResult = try? JSONDecoder().decode(Picture.self, from: jsonData) else {
                    assertionFailure("fail to decode")
                    return
                }
                self.allpost.append(finalResult)
            }
            self.data = self.allpost
            self.collectionView.reloadData()
        }
        
    }
    
    func getAllcollection(memberid: Int) {
        
        exploreCommunicator.getAllCollect(memberid: String(memberid)) { (result, error) in
            if let error = error {
                print("error:\(error)")
            }
            guard let result = result else {
                assertionFailure("result is nil")
                return
            }
            for item in result {
                guard let jsonData = try? JSONSerialization.data(withJSONObject: item, options: .prettyPrinted) else {
                    assertionFailure("fail to get data")
                    return
                }
                guard let finalResult = try? JSONDecoder().decode(Picture.self, from: jsonData) else {
                    assertionFailure("fail to decode")
                    return
                }
                self.allcollect.append(finalResult)
            }
            self.data = self.allcollect
            self.collectionView.reloadData()
            
        }
    }
    
    // MARK:- uiview's action

    @objc func segmentControl(noti: Notification?) {
        guard let segmentPostion = noti?.object as? Int else {
            print("noti is nil")
            return
        }
        self.data.removeAll()
        
        print("current segment:\(segmentPostion)")
        switch segmentPostion {
        case 0:
            self.allpost.removeAll()
            getAllpost(memberid: self.memberid)
            //            self.data = self.allpost
        //            collectionView.reloadData()
        case 1:
            self.allcollect.removeAll()
            getAllcollection(memberid: self.memberid)
            
        default:
            self.allpost.removeAll()
            getAllpost(memberid: self.memberid)
            //            self.data = self.allpost
            //            collectionView.reloadData()
        }
    }
    
    
    // MARK:- colletionView method

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //        print("self.segment.selectedSegmentIndex:\(self.finalheaferView.segment.selectedSegmentIndex)")
        guard self.finalheaferView.segmentControl != nil else {
            print("segment is nil")
            return data.count
        }
        if finalheaferView.segmentControl.selectedSegmentIndex == 0 {
            print("self.data.count=\(self.data.count)")
            if self.data.count == 0 {
                self.finalfooterrView.imageView.image = UIImage(named:"emptyview.png")
            }
            self.data = self.allpost
            return self.data.count
            
        } else {
            print("self.data.count=\(self.data.count)")
            if self.data.count == 0 {
                self.finalfooterrView.imageView.image = UIImage(named:"emptyView4.png")
            }
            self.data = self.allcollect
            return self.data.count
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        guard let pictureCell = cell as? ExploreCollectionViewCell else {
            assertionFailure("pictureCell = cell as? ExploreCollectionViewCell")
            return cell
        }
        let postid = self.data[indexPath.row].postid
        exploreCommunicator.getImage(postId: String(postid)) { (data, error) in
            if let error = error {
                print("error:\(error)")
            }
            guard let data = data else {
                assertionFailure("data is nil")
                return
            }
            pictureCell.imageView.image = UIImage(data: data)
        }
        return pictureCell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if finalheaferView.segmentControl.selectedSegmentIndex == 0 {
            print("post")
            performSegue(withIdentifier: "showPost", sender: self)

        } else {
            print("collect")
            performSegue(withIdentifier: "showCollection", sender: self)

        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == "UICollectionElementKindSectionHeader" {
            let reuableView = collectionView.dequeueReusableSupplementaryView(ofKind: "UICollectionElementKindSectionHeader", withReuseIdentifier: "header", for: indexPath)
            guard let finalheaferView = reuableView as? MyPageCollectionReusableView else {
                assertionFailure("failed to find MyPageCollectionReusableView")
                return reuableView
            }
            self.finalheaferView = finalheaferView
            //        guard let userName = userName, let memberid = memberid else {
            //            assertionFailure("userName,memberid is nil")
            //            return finalheaferView
            //        }
            //        self.finalheaferView.userNameLabel.text = userName
            if self.iconData == nil {
                print("iconData is nil")
                exploreCommunicator.getIcon(memberId: String(memberid), imageSize: "100") { (data, error) in
                    if let error = error {
                        print("error:\(error)")
                    }
                    guard let data = data else {
                        print("data is nil")
                        return
                    }
                    self.finalheaferView.iconImageView.image = UIImage(data: data)
                }
            } else {
                self.finalheaferView.iconImageView.image = UIImage(data: self.iconData!)
            }
            self.finalheaferView.iconImageView.layer.cornerRadius = self.finalheaferView.iconImageView.layer.frame.size.width/2
            self.finalheaferView.iconImageView.layer.masksToBounds = true
            self.finalheaferView.selfintroLabel.adjustsFontSizeToFitWidth = true
            guard  let userdetail = userProfile else {
                print("userprofile is nil")
                return finalheaferView
            }
            self.handleHeaderData(headerView: finalheaferView, userProfileData: userdetail)
            return finalheaferView
            
        } else {
            let reuablefooterView = collectionView.dequeueReusableSupplementaryView(ofKind: "UICollectionElementKindSectionFooter", withReuseIdentifier: "footer", for: indexPath)
            
            guard  let finalfooterView = reuablefooterView as? FooterCollectionReusableView else {
                assertionFailure("failed to find FooterCollectionReusableView")
                return reuablefooterView
            }
            self.finalfooterrView = finalfooterView
//            self.finalfooterrView = finalfooterView
            guard self.finalheaferView.segmentControl != nil else {
                print("segment is nil")
                return reuablefooterView
            }
            guard indexPath.section == 0 else {
                reuablefooterView.isHidden = true
                return reuablefooterView
            }
            if self.data.count == 0 {
                if self.finalheaferView.segmentControl.selectedSegmentIndex == 0 {
                    finalfooterView.frame.size = CGSize(width: screensize.width, height: screensize.height*0.55)
                    finalfooterView.imageView.contentMode = .scaleToFill
                    DispatchQueue.main.async {
                        finalfooterView.imageView.image = UIImage(named:"emptyview.png")
                        finalfooterView.imageView.isHidden = false

                    }
                } else {
                    finalfooterView.frame.size = CGSize(width: screensize.width, height: screensize.height*0.55)
                    finalfooterView.imageView.contentMode = .scaleToFill
                    DispatchQueue.main.async {
                        finalfooterView.imageView.image = UIImage(named:"emptyView4.png")
                        finalfooterView.imageView.isHidden = false

                    }
                }
                return finalfooterView
            } else {
                finalfooterView.imageView.isHidden = true
                return finalfooterView
                }
        }
    }
    
    func handleHeaderData(headerView: MyPageCollectionReusableView, userProfileData: Userprofile) {
        headerView.userNameLabel.text = userProfileData.userName
        headerView.collectLabel.text = String(userProfileData.collectionCount)
        headerView.postCountLabel.text = String(userProfileData.postCount)
        headerView.selfintroLabel.text = userProfileData.selfIntroduction
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(toUserProfiles))
        headerView.iconImageView.isUserInteractionEnabled = true
        headerView.iconImageView.addGestureRecognizer(tapGestureRecognizer)
        setSegmentStyle(headerView: headerView)
    }
    
    func setSegmentStyle(headerView: MyPageCollectionReusableView) {
        
        headerView.segmentControl.tintColor = UIColor(red: 30/255, green: 163/255, blue: 163/255, alpha: 1.0)
        headerView.segmentControl.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont(name: "DINCondensed-Bold", size: 18),
            NSAttributedString.Key.foregroundColor: UIColor(red: 30/255, green: 163/255, blue: 163/255, alpha: 1.0)
            ], for: .normal)
        headerView.segmentControl.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont(name: "DINCondensed-Bold", size: 18),
            NSAttributedString.Key.foregroundColor: UIColor.white
            ], for: .selected)
        headerView.segmentControl.layer.cornerRadius = 0
        headerView.segmentControl.layer.borderColor = UIColor(red: 30/255, green: 163/255, blue: 163/255, alpha: 1.0).cgColor
        headerView.segmentControl.layer.borderWidth = 1.5
        headerView.segmentControl.layer.masksToBounds = true
    }
    
    // MARK:- segue method
    
//    func setTapGestureForPhotoIcon(){
//        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(toUserProfiles))
//        finalheaferView.iconImageView.isUserInteractionEnabled = true
//        finalheaferView.iconImageView.addGestureRecognizer(tapGestureRecognizer)
//    }
    
    @objc
    func toUserProfiles(){
        performSegue(withIdentifier: "userprofileSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showPost":
            guard let selectedIndexPath = self.collectionView.indexPathsForSelectedItems?.first else {
                assertionFailure("failed to get indexPathsForSelectedItems")
                return
            }
            guard let targetVC = segue.destination as? SinglePostViewController else {
                assertionFailure("Faild to get destination")
                return
            }
            targetVC.postId = self.data[selectedIndexPath.row].postid
            targetVC.memberId = self.memberid
            targetVC.navigationItem.leftItemsSupplementBackButton = true
            return
        case "showCollection":
            guard let selectedIndexPath = self.collectionView.indexPathsForSelectedItems?.first else {
                assertionFailure("failed to get indexPathsForSelectedItems")
                return
            }
            guard let targetVC = segue.destination as? PictureDetailViewController else {
                assertionFailure("Faild to get destination")
                return
            }
            targetVC.picture = self.data[selectedIndexPath.row]
            targetVC.navigationItem.leftItemsSupplementBackButton = true
            return
        default:
            return
        }
//        if segue.identifier == "showDetail" {
//            guard let selectedIndexPath = self.collectionView.indexPathsForSelectedItems?.first else {
//                assertionFailure("failed to get indexPathsForSelectedItems")
//                return
//            }
//            guard let targetVC = segue.destination as? PictureDetailViewController else {
//                assertionFailure("Faild to get destination")
//                return
//            }
//            targetVC.picture = self.data[selectedIndexPath.row]
//            targetVC.navigationItem.leftItemsSupplementBackButton = true
//        }
    }
    
    @IBAction func unwind(_ segue: UIStoryboardSegue) {
        print(#function)
        if segue.identifier == "fromUserProfileSegue"{
            getProfile(memberid: memberid)
            let segue = segue.source as! UserprofileViewController
            let image = segue.photoIcon.image
            self.finalheaferView.iconImageView.image = image
//            print("segue.userNameLabel.text:\(segue.userNameLabel.text)")
//            print("segue.selfIntroTextView.text:\(segue.selfIntroTextView.text)")
//            self.finalheaferView.userNameLabel.text = segue.userNameLabel.text
//            self.finalheaferView.selfintroLabel.text = segue.selfIntroTextView.text
//            self.data.removeAll()
        }
        
        if segue.identifier == "toMyPage" {
//            refreshData()
//            getProfile(memberid: self.memberid)
//            loadUserprofile(memberId: memberId)
//            setTapGestureForPhotoIcon()
//            downloadPhotoIcon(memberId: memberId)
//            getCollectionIds(memberId: memberId)
//            getPostIds(memberId: memberId)
        }
        
        if segue.identifier == "backToMyPage" {
//            refreshData()
//            getPostIds(memberId: memberId)
//            DispatchQueue.main.async {
//                self.postCollectionView.reloadData()
//            }
        }
        
        
        
    }

}
