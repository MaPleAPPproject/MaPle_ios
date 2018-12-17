//
//  FriendlistTableViewController.swift
//  MaPle
//
//  Created by 蘇曉彤 on 2018/11/18.
//
import UIKit
import Starscream

class FriendlistTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var friendView: UIView!
    @IBOutlet weak var friendlistTableView: UITableView!
    let memberID = UserDefaults.standard.integer(forKey: "MemberIDint")

    let refreshControl = UIRefreshControl()
    
    let communicator = FriendCommunicator.shared
    var friendlist : [Friend_profile] = []
    var socket: WebSocket!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        friendlistTableView.delegate = self
        friendlistTableView.dataSource = self
        getfriends(memberid: memberID)
        friendlistTableView.separatorInset = UIEdgeInsets.zero
        friendlistTableView.separatorColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        
        
        //refreshControl
        if #available(iOS 10.0, *) {
            self.friendlistTableView.refreshControl = refreshControl
        } else {
            self.friendlistTableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshPictureData(_:)), for: .valueChanged)
        
        if friendlist.isEmpty {
            friendlistTableView.separatorStyle = .none
            let backgroundImage = UIImage.init(named: "background_friend")
            friendView.layer.contents = backgroundImage?.cgImage
        }
        
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        if friendlist.isEmpty {
//            friendlistTableView.separatorStyle = .none
//            let backgroundImage = UIImage.init(named: "background_friend")
//            friendView.layer.contents = backgroundImage?.cgImage
//        }
//    }
    
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendlist.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FriendlistTableViewCell
        let friend = friendlist[indexPath.row]
        
        cell.selectionStyle = .none
        cell.nameLB.text = friend.Username
        cell.nameLB.adjustsFontSizeToFitWidth = true
        cell.introLB.text = friend.selfIntroduction
        cell.chatBt.tag = friend.FriendID
        
        communicator.getPhoto(id: friend.FriendID) { (data, error) in
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
            cell.photoIV.layer.cornerRadius = 60
            
        }
        return cell
    }
    
    
    
    // MARK: - Navigation
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "friendProfile" {
            guard  let targetVC = segue.destination as? OthersPage2CollectionViewController else {
                assertionFailure("Faild to get destination")
                return
            }
            guard let selectedIndexPath = self.friendlistTableView.indexPathForSelectedRow else {
                assertionFailure("failed to get indexpath.")
                return
            }
            targetVC.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            targetVC.navigationItem.leftItemsSupplementBackButton = true
            targetVC.memberid = friendlist[selectedIndexPath.row].FriendID
            targetVC.userName = friendlist[selectedIndexPath.row].Username
        }
    }
    
    
    
    func getfriends(memberid: Int) {
//        guard let memberId =  memberid else {
//            assertionFailure("memberid is nil")
//            return
//        }
        communicator.getAllFriend(memberid: memberid) { (result,error) in
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
            
            for data in resultObject{
            
                let id = String(data.FriendID)
                Communicator.friendsListIndex[id] = data.Username
            }
            print("friend list index: \(Communicator.friendsListIndex)")
            
            
            self.friendlist = resultObject
//            print("\(self.friendlist)")
            self.friendlistTableView.reloadData()
        }
    }
    
    //MARK:-ButtonAction
    @objc
    func refreshPictureData(_ sender: Any) {
        getfriends(memberid: memberID)
        self.refreshControl.endRefreshing()
    }
    
    @IBAction func chatPressed(_ sender: UIButton) {
        print("sender.tag:\(sender.tag)")
        if let controller = storyboard?.instantiateViewController(withIdentifier: "chatRoom") as? ChatViewController {
            controller.friendId = sender.tag
            controller.title = Communicator.friendsListIndex[String(sender.tag)]
            controller.navigationItem.leftItemsSupplementBackButton = true
            self.parent?.view.addSubview(controller.view)
            self.view.addSubview(controller.view)
            show(controller, sender: self)
        }
        
    }
    
    
}
