//
//  OthersPageViewController.swift
//  MaPle
//
//  Created by Violet on 2018/11/15.
//

import UIKit

class OthersPageViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {
 
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var colletctionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var selfintroLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var vipLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var collectCountLabel: UILabel!
    @IBOutlet weak var postCountLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    
    var iconData:Data?
    let communicator = ExploreCommunicator.shared
    var postDetail:PostDetail?
    var userProfile:UserProfileExplore?
    var allpost = [Picture]()
    var allcollect = [Picture]()
    var data = [Picture]()
    let screensize = UIScreen.main.bounds.size
    
    override func loadView() {
        super.loadView()
        guard let finalpostDetail = postDetail else {
            assertionFailure("postdetail is nil")
            return
        }
//        getAllpost(memberid: finalpostDetail.memberId)
//        self.data = self.allpost
//        getAllcollection(memberid: finalpostDetail.memberId)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.colletctionViewFlowLayout.itemSize = CGSize(width: screensize.width/3, height: screensize.width/3)
        self.colletctionViewFlowLayout.minimumLineSpacing = 0
        self.colletctionViewFlowLayout.minimumInteritemSpacing = 0
        // place profile data
        guard let finalpostDetail = postDetail else {
            assertionFailure("postdetail is nil")
            return
        }
        getAllpost(memberid: finalpostDetail.memberId)
        getAllcollection(memberid: finalpostDetail.memberId)
        getProfile(memberid: finalpostDetail.memberId)
        userNameLabel.text = finalpostDetail.username
        
        guard let iconData = iconData else {
            assertionFailure("iconData is nil")
            return
        }
        self.iconImageView.image = UIImage(data: iconData)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let finalpostDetail = postDetail else {
            assertionFailure("postdetail is nil")
            return
        }
        //set uiview
        self.iconImageView.layer.cornerRadius = self.iconImageView.layer.frame.size.width/2
        self.iconImageView.layer.masksToBounds = true
        self.selfintroLabel.adjustsFontSizeToFitWidth = true
        collectionView.reloadData()
        // renew collectcount
        getProfile(memberid: finalpostDetail.memberId)
        if self.segment.selectedSegmentIndex == 1 {
            segmentControl(self.segment)
        }
        
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
            self.collectCountLabel.text = String(finalResult.collectcount)
            self.postCountLabel.text = String(finalResult.postcount)
            self.emailLabel.text = finalResult.email
            self.selfintroLabel.text = finalResult.selfIntroduction
            if finalResult.vipStatus == 0 {
                self.vipLabel.isHidden = true
            }

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
            if self.segment.selectedSegmentIndex == 0 {
                self.data = self.allpost
                self.collectionView.reloadData()
            }
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
            if self.segment.selectedSegmentIndex == 1 {
                self.data = self.allpost
                self.collectionView.reloadData()
            }
        }
    }

    
    @IBAction func segmentControl(_ sender: UISegmentedControl) {
        self.data.removeAll()
        
        guard let finalPostdetail = self.postDetail else {
            print("postdetail is nil")
            return
        }
            print("current segment:\(sender.selectedSegmentIndex)")
            switch sender.selectedSegmentIndex {
            case 0:
                self.allpost.removeAll()
                getAllpost(memberid: finalPostdetail.memberId)
//                self.data = self.allpost
//                self.collectionView.reloadData()
            case 1:
                self.allcollect.removeAll()
                getAllcollection(memberid: finalPostdetail.memberId)
//                self.data = self.allcollect
//                self.collectionView.reloadData()
            default:
                self.allpost.removeAll()
                getAllpost(memberid: finalPostdetail.memberId)
//                self.data = self.allpost
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
    // MARK: - collectionView
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("self.segment.selectedSegmentIndex:\(self.segment.selectedSegmentIndex)")
        if self.segment.selectedSegmentIndex == 0 {
            self.data = self.allpost
            return data.count
        }else {
            self.data = self.allcollect
            return data.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        guard kind == "UICollectionElementKindSectionHeader" else {
//            assertionFailure("failed to get header")
//            let test = UICollectionReusableView()
//            return test
//        }
//        let reuableView = collectionView.dequeueReusableSupplementaryView(ofKind: "UICollectionElementKindSectionHeader", withReuseIdentifier: "header", for: indexPath)
////        reuableView.backgroundColor = .black
////        let control = UISegmentedControl(items: ["Seg1","Seg2","Seg3"])
////        control.addTarget(self, action: "valueChanged:", for: UIControl.Event.valueChanged)
////        reuableView.addSubview(control)
//        return reuableView
//    }
}
