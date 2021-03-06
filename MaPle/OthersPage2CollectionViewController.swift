//
//  OthersPage2CollectionViewController.swift
//  MaPle
//
//  Created by Violet on 2018/11/20.
//

import UIKit


class OthersPage2CollectionViewController: UICollectionViewController {
    
    @IBOutlet weak var colletctionViewFlowLayout: UICollectionViewFlowLayout!

    var finalheaferView = OthersPageUICollectionReusableView()
    var iconData:Data?
    let communicator = ExploreCommunicator.shared
//    var postDetail:PostDetail?
    var userProfile:UserProfileExplore?
    var allpost = [Picture]()
    var allcollect = [Picture]()
    var data = [Picture]()
    let screensize = UIScreen.main.bounds.size
    var memberid:Int?
    var userName:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.colletctionViewFlowLayout.itemSize = CGSize(width: screensize.width/3, height: screensize.width/3)
        self.colletctionViewFlowLayout.minimumLineSpacing = 0
        self.colletctionViewFlowLayout.minimumInteritemSpacing = 0
        // place profile data
//        if let finalpostDetail = postDetail {
//            print("postdetail is nil")
//            return
//        }
        guard let memberid = memberid else {
            print("postdetail is nil")
            return
        }
        let group: DispatchGroup = DispatchGroup()
        let queue1 = DispatchQueue(label: "queue1", attributes: .concurrent)
        queue1.async(group: group) {
            self.getProfile(memberid: memberid)
        }
        let queue2 = DispatchQueue(label: "queue2", attributes: .concurrent)
        queue2.async(group: group) {
            self.getAllpost(memberid: memberid)
            self.getAllcollection(memberid: memberid)

        }
        group.notify(queue: DispatchQueue.main) {
            print("處理完成data...")
            self.collectionView.reloadData()
        }
        
        let notificationName = Notification.Name("GetSegmentPosition")
        NotificationCenter.default.addObserver(self, selector: #selector(self.segmentControl(noti:)), name: notificationName, object: nil)
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let memberid = memberid else {
            print("postdetail is nil")
            return
        }
        // renew collectcount
        getProfile(memberid: memberid)
        guard let headerSegment = self.finalheaferView.segment else {
            return
        }
        if headerSegment.selectedSegmentIndex == 1 {
            self.data.removeAll()
            self.allcollect.removeAll()
            getAllcollection(memberid: memberid)
        }
//        if self.segment.selectedSegmentIndex == 1 {
//            segmentControl(self.segment)
//        }

    }
    
    func getProfile(memberid: Int) {
        communicator.getProfile(memberId: String(memberid)) { (result, error) in
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
            guard let finalResult = try? JSONDecoder().decode(UserProfileExplore.self, from: jsonData) else {
                assertionFailure("fail to decode")
                return
            }
            self.userProfile = finalResult
            self.handleHeaderData(headerView: self.finalheaferView, userProfileData: finalResult)
//            self.collectionView.reloadData()
        }
    }
    
    func getAllpost(memberid: Int) {
        
        communicator.getAllPost(memberid: String(memberid)) { (result, error) in
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
        
        communicator.getAllCollect(memberid: String(memberid)) { (result, error) in
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
    
    
    @objc func segmentControl(noti: Notification?) {
        guard let segmentPostion = noti?.object as? Int else {
            print("noti is nil")
            return
        }
        self.data.removeAll()
        guard let memberid = memberid else {
            print("memberid is nil")
            return
        }
        
        print("current segment:\(segmentPostion)")
        switch segmentPostion {
        case 0:
            self.allpost.removeAll()
            getAllpost(memberid: memberid)
//            self.data = self.allpost
//            collectionView.reloadData()
        case 1:
            self.allcollect.removeAll()
            getAllcollection(memberid: memberid)
            
        default:
            self.allpost.removeAll()
            getAllpost(memberid: memberid)
//            self.data = self.allpost
//            collectionView.reloadData()
        }
    }
    
    

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        print("self.segment.selectedSegmentIndex:\(self.finalheaferView.segment.selectedSegmentIndex)")
        guard self.finalheaferView.segment != nil else {
            print("segment is nil")
            return data.count
        }
        if finalheaferView.segment.selectedSegmentIndex == 0 {
            print("self.data.count=\(self.data.count)")
            self.data = self.allpost
            return self.data.count

        } else {
            print("self.data.count=\(self.data.count)")
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
        communicator.getImage(postId: String(postid)) { (data, error) in
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
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
        }
    }
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
            guard kind == "UICollectionElementKindSectionHeader" else {
                assertionFailure("failed to get header")
                let test = UICollectionReusableView()
                return test
            }
            let reuableView = collectionView.dequeueReusableSupplementaryView(ofKind: "UICollectionElementKindSectionHeader", withReuseIdentifier: "header", for: indexPath)
        guard  let finalheaferView = reuableView as? OthersPageUICollectionReusableView else {
            return reuableView
        }
        self.finalheaferView = finalheaferView
        guard let userName = userName, let memberid = memberid else {
            assertionFailure("userName,memberid is nil")
            return finalheaferView
        }
        self.finalheaferView.userNameLabel.text = userName
        if self.iconData == nil {
            print("iconData is nil")
            communicator.getIcon(memberId: String(memberid), imageSize: "100") { (data, error) in
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
        }
    
    func handleHeaderData(headerView: OthersPageUICollectionReusableView, userProfileData: UserProfileExplore) {
        headerView.collectCountLabel.text = String(userProfileData.collectcount)
        headerView.emailLabel.text = userProfileData.email
        headerView.postCountLabel.text = String(userProfileData.postcount)
        headerView.selfintroLabel.text = userProfileData.selfIntroduction
        if userProfileData.vipStatus == 0 {
            headerView.vipLabel.isHidden = true
        }
        setSegmentStyle(headerView: headerView)
    }
    
    func setSegmentStyle(headerView: OthersPageUICollectionReusableView) {
        
        headerView.segment.tintColor = UIColor(red: 30/255, green: 163/255, blue: 163/255, alpha: 1.0)
        headerView.segment.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont(name: "DINCondensed-Bold", size: 18),
            NSAttributedString.Key.foregroundColor: UIColor(red: 30/255, green: 163/255, blue: 163/255, alpha: 1.0)
            ], for: .normal)
        headerView.segment.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont(name: "DINCondensed-Bold", size: 18),
            NSAttributedString.Key.foregroundColor: UIColor.white
            ], for: .selected)
        headerView.segment.layer.cornerRadius = 0
        headerView.segment.layer.borderColor = UIColor(red: 30/255, green: 163/255, blue: 163/255, alpha: 1.0).cgColor
        headerView.segment.layer.borderWidth = 1.5
        headerView.segment.layer.masksToBounds = true
    }
}
