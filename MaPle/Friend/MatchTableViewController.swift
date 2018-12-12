//
//  MatchViewController.swift
//  MaPle
//
//  Created by 蘇曉彤 on 2018/12/5.
//

import UIKit

class MatchTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var matchlistTableView: UITableView!
    
    let communicator = FriendCommunicator.shared
    let explorecommunicator = ExploreCommunicator.shared
    var matchlist : [Friend_profile] = []
    let refreshControl = UIRefreshControl()
    let memberid = UserDefaults.standard.integer(forKey: "MemberIDint")


    
    override func viewDidLoad() {
        super.viewDidLoad()
        matchlistTableView.delegate = self
        matchlistTableView.dataSource = self
        getmatch(memberid: memberid)
        
        //refreshControl
        if #available(iOS 10.0, *) {
            self.matchlistTableView.refreshControl = refreshControl
        } else {
            self.matchlistTableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshPictureData(_:)), for: .valueChanged)
    }
    
    //MARK:-TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchlist.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MatchTableViewCell
        let friend = matchlist[indexPath.row]
        cell.statusLabel.isHidden = true
        cell.dislikeButton.isHidden = false
        cell.likeButton.isHidden = false
        cell.nameLB.text = friend.Username
        cell.introLB.text = friend.selfIntroduction
        cell.likeButton.tag = friend.FriendID
        cell.dislikeButton.tag = friend.FriendID
        explorecommunicator.getIcon(memberId: String(friend.FriendID), imageSize: "100") { (data, error) in
            if let error = error {
                print("Download fail: \(error)")
                return
            }
            guard let photodata = data else {
                print("photo data is nil.")
                return
            }
            cell.photoIV.image = UIImage(data: photodata)
            cell.photoIV.clipsToBounds = true
            cell.photoIV.layer.cornerRadius = 30
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "friendProfile"{
            guard  let targetVC = segue.destination as? OthersPage2CollectionViewController else {
                assertionFailure("Faild to get destination")
                return
            }
            guard let selectedIndexPath = self.matchlistTableView.indexPathForSelectedRow else {
                assertionFailure("failed to get indexpath.")
                return
            }
            targetVC.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            targetVC.navigationItem.leftItemsSupplementBackButton = true
            targetVC.memberid = matchlist[selectedIndexPath.row].FriendID
            targetVC.userName = matchlist[selectedIndexPath.row].Username
            print("targetVC.memberid :\(matchlist[selectedIndexPath.row].FriendID)")
        }
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//    }
    
    //MARK:-ButtonAction

    @objc
    func refreshPictureData(_ sender: Any) {
        getmatch(memberid: memberid)
        self.refreshControl.endRefreshing()
    }
    
    @IBAction func likeBt(_ sender: UIButton) {
        print("like friendID:\(sender.tag)")
        self.acceptMatch(friendid: sender.tag)
    }
    
    
    @IBAction func dislikeBt(_ sender: UIButton) {
        print("dislike friendID:\(sender.tag)")
//        self.reject(friendid: sender.tag)
    }
    
    //MARK:-Retrieve Server
    
    func getmatch(memberid: Int) {
        communicator.getAllMatch(memberid: memberid) { (result,error) in
            if let error = error {
                print("getAllFriend error:\(error)")
                return
            }
            guard let result = result else {
                print("result is nil")
                return
            }
            guard let jsonObject = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
                else {
                    print("Fail to generate jsonData")
                    return
            }
            let decoder = JSONDecoder()
            guard let resultObject = try? decoder.decode([Friend_profile].self, from: jsonObject) else {
                print("Fail to decode jsonData.")
                return
            }
            
            self.matchlist = resultObject
            print("\(self.matchlist)")
            self.matchlistTableView.reloadData()
            
        }
    }
    
    
    @objc func acceptMatch(friendid: Int) {
    
        communicator.acceptMatch(memberid: memberid, friendid: friendid) { (result, error) in
            if let error = error {
                print("acceptMatch error:\(error)")
                return
            }
            guard let result = result else {
                print("result is nil")
                return
            }
//            guard let jsonObject = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
//                else {
//                    print("Fail to generate jsonData")
//                    return
//            }
//            let decoder = JSONDecoder()
//            guard let resultObject = try? decoder.decode([Friend_profile].self, from: jsonObject) else {
//                print("Fail to decode jsonData.")
//                return
//            }
            
            print("成功接受朋友配對\(result)")
            
        }
    }
    
    
    func reject(friendid: Int) {
        communicator.reject(memberid: memberid, friendid: friendid) { (result, error) in
            if let error = error {
                print("acceptMatch error:\(error)")
                return
            }
            guard let result = result else {
                print("result is nil")
                return
            }
//            guard let jsonObject = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
//                else {
//                    print("Fail to generate jsonData")
//                    return
//            }
//            let decoder = JSONDecoder()
//            guard let resultObject = try? decoder.decode([Friend_profile].self, from: jsonObject) else {
//                print("Fail to decode jsonData.")
//                return
//            }
            
            print("成功接受拒絕朋友配對\(result)")
        }
    }
    
    
    
    
    
}