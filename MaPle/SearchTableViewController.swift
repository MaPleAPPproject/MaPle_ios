//
//  SearchTableViewController.swift
//  MaPle
//
//  Created by Violet on 2018/11/27.
//

import UIKit

class SearchTableViewController: UITableViewController {
    
    let searchController = UISearchController(searchResultsController: nil )
//    let searchController: SearchTableViewController!
    let communicator = ExploreCommunicator.shared
    var districtList = [String]()
    var filtered = [String]()
    var searchActive : Bool = false
    var topPictures = [Picture]()
    var newPictures = [Picture]()


    override func viewDidLoad() {
        super.viewDidLoad()
        getDistrictList()
        self.tableView.register(SearchTableViewCell.self, forCellReuseIdentifier: "cell")
    }

    func getDistrictList() {
        communicator.getDistinct { (result, error) in
            if let error = error {
                print("error:\(error)")
            }
            guard let result = result else {
                assertionFailure("result is nil")
                return
            }
            guard let jsonData = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted) else {
                print("failed to get data")
                return
            }
            guard let finalresult = try? JSONDecoder().decode([String].self, from: jsonData) else {
                print("failed to decode")
                return
            }
            self.districtList = finalresult
            self.tableView.reloadData()
        }
    }
    
//    func changePage(to newViewController: UIViewController) {
//        // 2. Remove previous viewController
//        selectedViewController.willMove(toParent: nil)
//        selectedViewController.view.removeFromSuperview()
//        selectedViewController.removeFromParent()
//
//        // 3. Add new viewController
//        addChild(newViewController)
//        self.containerView.addSubview(newViewController.view)
//        newViewController.view.frame = containerView.bounds
//        newViewController.didMove(toParent: self)
//
//        // 4.
//        self.selectedViewController = newViewController
//    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if searchActive {
           return filtered.count
        } else {
            return districtList.count
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "searchResult", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        // Configure the cell...
        if searchActive {
            cell.textLabel?.text = filtered[indexPath.row]
        } else {
            cell.textLabel?.text = districtList[indexPath.row]
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchResult" {
            guard let selectedIndexPath = self.tableView.indexPathForSelectedRow else {
                assertionFailure("failed to get indexpath.")
                return
            }
            let searchString = filtered[selectedIndexPath.row]
            print("topPictures:\(topPictures.description)")
            let filteredtopsPictures =  self.topPictures.filter({ (item) -> Bool in
                let countryText: NSString = item.district as NSString
                return (countryText.range(of: searchString, options: NSString.CompareOptions.caseInsensitive).location) != NSNotFound
            })
            print("filteredtopsPictures:\(filteredtopsPictures.description)")
            let filterednewsPictures =  self.newPictures.filter({ (item) -> Bool in
                let countryText: NSString = item.district as NSString
                return (countryText.range(of: searchString, options: NSString.CompareOptions.caseInsensitive).location) != NSNotFound
            })
            guard let targetVC = (segue.destination as! UINavigationController).topViewController as? SearchResultCollectionViewController else {
                assertionFailure("failed to get destination")
                return
            }
            targetVC.filterednewsPictures = filterednewsPictures
            targetVC.filteredtopsPictures = filteredtopsPictures
            targetVC.selectedDistrict = searchString
            targetVC.navigationItem.leftItemsSupplementBackButton = true
        }
    }
    

}
