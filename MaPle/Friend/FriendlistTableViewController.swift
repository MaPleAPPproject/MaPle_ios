//
//  FriendlistTableViewController.swift
//  MaPle
//
//  Created by 蘇曉彤 on 2018/11/18.
//

import UIKit

class FriendlistTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var friendlistTableView: UITableView!
    
    let communicator = FriendCommunicator.shared
    var friendlist : [Friend_profile] = []
//    var image = UIImage()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        friendlistTableView.delegate = self
        getfriends()
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
        cell.introLB.text = friend.selfIntroduction
        
        communicator.getPhoto(id: friend.FriendID) { (data, error) in
            if let error = error {
                print("Download fail: \(error)")
                return
            }
            guard let photodata = data else {
                print("photo data is nil.")
                return
            }
            print("getPhoto:\(photodata)")
//            self.image = UIImage(data: photodata)!
            cell.photoIV.image = UIImage(data: photodata)
        }
    
        return cell
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    func getfriends() {
        let memberid = 1
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
        
            self.friendlist = resultObject
            print("\(self.friendlist)")
            self.friendlistTableView.reloadData()
            
        }
    }

}
