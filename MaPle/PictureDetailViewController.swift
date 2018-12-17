//
//  PictureDetailViewController.swift
//  MaPle
//
//  Created by Violet on 2018/11/13.
//

import UIKit

class PictureDetailViewController: UIViewController {
    
    var picture: Picture?
    var pictureDetail: PostDetail?
    var iconData: Data?
    var pictureData: Data?
    
    @IBOutlet weak var collectBt: UIButton!
    @IBOutlet weak var collectCountLabel: UILabel!
    @IBOutlet weak var districtBt: UIButton!
    @IBOutlet weak var userNameBt: UIButton!
    @IBOutlet weak var iconImageView: UIImageView!
    let communicatior = ExploreCommunicator.shared
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    let memberid = UserDefaults.standard.string(forKey: "MemberID")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set icon image
        self.iconImageView.layer.cornerRadius = self.iconImageView.frame.size.width/2 //裁成圓角
        self.iconImageView.layer.masksToBounds = true //隱藏裁切部分
        self.collectBt.imageView?.image?.withRenderingMode(.alwaysTemplate)
        //set district bt
        self.districtBt.titleLabel?.adjustsFontForContentSizeCategory = true
        //config Views
        handleRetriveData(picture: picture)
        // Do any additional setup after loading the view.
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let picture = self.picture, let userid = memberid else {
            print("picture is nil")
            return
        }
        checkCollected(postid: picture.postid, userid: userid)
        getPictureDetail(postid: picture.postid)
    }
    
    func checkCollected(postid: Int, userid: String) {
        
        communicatior.isCollectable(postId: String(postid), collectorId: userid) { (result, error) in
            if let error = error {
                print("error:\(error)")
            }
            guard let result = result else {
                assertionFailure("result is nil")
                return
            }
            guard let resultbool = result as? Int else {
                print("failed change to int")
                return
            }
            if resultbool == 1 {
                self.collectBt.tintColor = UIColor(red: 245/255, green: 136/255, blue: 136/255, alpha: 1.0)
            }else {
                self.collectBt.tintColor = UIColor(red: 30/255, green: 163/255, blue: 163/255, alpha: 1.0)
            }
        }
    }
    
    func handleRetriveData(picture: Picture?) {
        
        guard  let finalpicture = picture , let userid = memberid else {
            assertionFailure("picture data is nil")
            return
        }
        getPictureDetail(postid: finalpicture.postid)
        checkCollected(postid: finalpicture.postid, userid: userid)
        self.commentLabel.text = finalpicture.comment
        self.commentLabel.adjustsFontSizeToFitWidth = true
        
        self.dateLabel.text = getDate(date: finalpicture.date)
        communicatior.getImage(postId: String(finalpicture.postid)) { (data, error) in
            if let error = error {
                print("error:\(error)")
            }
            guard let picturedata = data else {
                print("data is nil")
                return
            }
            self.pictureImageView.image = UIImage(data: picturedata)
            self.pictureData = picturedata
        }
    }
    
    func getPictureDetail(postid: Int) {
        communicatior.getPostdetail(postId: String(postid)) { (result, error) in
            if let error = error {
                print("error:\(error)")
            }
            guard let result = result else {
                assertionFailure("result is nil")
                return
            }
            print("get success response:\(result)")
            guard let jsonData = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted) else {
                assertionFailure("fail to get data")
                return
            }
            guard let finalResult = try? JSONDecoder().decode(PostDetail.self, from: jsonData) else {
                assertionFailure("fail to decode")
                return
            }
            self.pictureDetail = finalResult
            self.getIcon(memberId: finalResult.memberId)
            self.collectCountLabel.text = String(finalResult.collectcount)
            self.userNameBt.setTitle(finalResult.username, for: .normal)
            self.districtBt.setTitle(finalResult.district, for: .normal)
        }
    }
    
    func getIcon(memberId: Int) {
        
        communicatior.getIcon(memberId: String(memberId), imageSize: String(100)) { (data, error) in
            if let error = error {
                print("error:\(error)")
            }
            guard let data = data else {
                assertionFailure("data is nil")
                return
            }
            self.iconImageView.image = UIImage(data: data)
            self.iconData = data
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
    func getDate(date: Int64)-> String{
        // convert to seconds
        let timeInMilliseconds = date
        let timeInSeconds = Double(timeInMilliseconds) / 1000
        
        // get the Date
        let dateTime = Date(timeIntervalSince1970: timeInSeconds)
        
        // display the date and time
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .long
        let dateString = formatter.string(from: dateTime)
        print(formatter.string(from: dateTime))
        return dateString
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showProfile"{
            guard  let targetVC = segue.destination as? OthersPage2CollectionViewController else {
                assertionFailure("Faild to get destination")
                return
            }
            targetVC.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            targetVC.navigationItem.leftItemsSupplementBackButton = true
            targetVC.memberid = pictureDetail?.memberId
            targetVC.userName = pictureDetail?.username
            targetVC.iconData = iconData
        } else if segue.identifier == "showMap" {
            guard  let targetVC = segue.destination as? LocationMapViewController else {
                assertionFailure("Faild to get destination")
                return
            }
            targetVC.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            targetVC.navigationItem.leftItemsSupplementBackButton = true
            targetVC.postdetail = pictureDetail
            targetVC.imagedata = pictureData
        }
    }
    
    @IBAction func CollectBtPress(_ sender: UIButton) {

        guard let postdetail = pictureDetail, let picture = picture, let userid = memberid else {
            print("postdetail and picture is nil")
            return
        }
        
        let redcolor = UIColor(red: 245/255, green: 136/255, blue: 136/255, alpha: 1.0)
        if sender.tintColor == redcolor {
            print("already like need to cancellike")
            communicatior.cancelCollect(postId: String(picture.postid), collectorId: userid) { (result, error) in
                if let error = error {
                    print("error:\(error)")
                }
                guard let result = result else {
                    assertionFailure("result is nil")
                    return
                }
                guard let resultint = result as? Int else {
                    assertionFailure("failed to decode")
                    return
                }
                if resultint == 1 {
                    self.collectBt.tintColor = UIColor(red: 30/255, green: 163/255, blue: 163/255, alpha: 1.0)
                    self.collectCountLabel.text = String(Int(self.collectCountLabel.text!)!-1)
                    
                } else if resultint == 0{
                    print("failed to collect")
                }
            }
        }else {
            print("need to like")
            let memberid = UserDefaults.standard.integer(forKey: "MemberIDint")
            let userpre = UserPreference(postid: postdetail.postid, collectorid: memberid, memberid: postdetail.memberId, collectcount: postdetail.collectcount)
            communicatior.addCollect(userPreference: userpre) { (result, error) in
                if let error = error {
                    print("error:\(error)")
                }
                guard let result = result else {
                    assertionFailure("result is nil")
                    return
                }
                guard let resultint = result as? Int else {
                    assertionFailure("failed to decode")
                    return
                }
                if resultint == 1 {
                    self.collectBt.tintColor = UIColor(red: 245/255, green: 136/255, blue: 136/255, alpha: 1.0)
                    
                    self.collectCountLabel.text = String(Int(self.collectCountLabel.text!)!+1)
                } else if resultint == 0{
                    print("failed to cancel collect")
                }
            }
        }
        
    }
    
}
