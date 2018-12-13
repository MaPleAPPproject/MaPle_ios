//
//  FriendlistTableViewController.swift
//  MaPle
//
//  Created by 蘇曉彤 on 2018/11/18.
//

import UIKit
import Starscream

class FriendlistTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var friendlistTableView: UITableView!
    let memberid = UserDefaults.standard.string(forKey: "MemberID")

//    let memberid = UserDefaults.standard.integer(forKey: "MemberIDint")
    let communicator = FriendCommunicator.shared
    var friendlist : [Friend_profile] = []
    var socket: WebSocket!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        friendlistTableView.delegate = self
        friendlistTableView.dataSource = self
        getfriends()
        friendlistTableView.separatorInset = UIEdgeInsets.zero
        friendlistTableView.separatorColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        print("UserDefaults.standard.string---->\(memberid)")
    }
    
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
        cell.nameLB.text = friend.Username
        cell.nameLB.adjustsFontSizeToFitWidth = true
        cell.introLB.text = friend.selfIntroduction
        cell.chatBt.tag = friend.FriendID
        
        communicator.getPhoto(id: String(friend.FriendID)) { (data, error) in
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
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
    
    
    
    func getfriends() {
        guard let memberId =  memberid else {
            assertionFailure("memberid is nil")
            return
        }
        communicator.getAllFriend(memberid: memberId) { (result,error) in
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
            
            self.friendlist = resultObject
            print("\(self.friendlist)")
            self.friendlistTableView.reloadData()
            
        }
    }
    
    @IBAction func profilePressed(_ sender: Any) {
        
    }
    
    
    @IBAction func chatPressed(_ sender: UIButton) {
        print("sender.tag:\(sender.tag)")
        if let controller = storyboard?.instantiateViewController(withIdentifier: "chatRoom") as? ChatViewController {
            controller.friendId = sender.tag
            controller.title = String(sender.tag)
            controller.navigationItem.leftItemsSupplementBackButton = true
            self.parent?.view.addSubview(controller.view)
            self.view.addSubview(controller.view)
            show(controller, sender: self)
        }
        
    }
    
    
}

