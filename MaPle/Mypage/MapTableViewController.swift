//
//  MapTableViewController.swift
//  MaPle
//
//  Created by juiying chiu on 2018/11/29.
//

import UIKit
import MapKit

class MapTableViewController: UITableViewController, UISearchResultsUpdating, UISearchControllerDelegate, MKMapViewDelegate {
   
    //    let width = UIScreen.main.bounds.width - 100
//    let rect = CGRect(x: 0, y: 0, width: width, height: 20)
//    var searchBar = UISearchBar(frame: rect)
//    let leftNavBarButton = UIBarButtonItem(customView:searchBar)
//    self.navigationItem.leftBarButtonItem = leftNavBarButton
//    searchBar.placeholder = "Your placeholder"
//    searchBar.sizeToFit()
    
   
    
    @IBOutlet weak var mapView: MKMapView!
    var attractionImages = [String]()
    var attractionNames = [String]()
    var webAddresses = [String]()
    
    var searching = false
    var matches = [Int]()
    var searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func initialize() {
       
        navigationController?.navigationBar.prefersLargeTitles = true
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "請輸入地址..."
        searchController.searchBar.sizeToFit()
        searchController.searchResultsUpdater = self // 設定代理UISearchResultsUpdating的協議
        searchController.delegate = self // 設定代理UISearchBarDelegate的協議
        searchController.dimsBackgroundDuringPresentation = false // 預設為true，若是沒改為false，則在搜尋時整個TableView的背景顏色會變成灰底的
        
        self.tableView.tableHeaderView = searchController.searchBar
        self.tableView = UITableView(frame: CGRect(x: 0, y: 20, width: self.view.frame.size.width, height: self.view.frame.size.height), style: .plain)
        self.tableView.backgroundColor = UIColor.white
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.view.addSubview(tableView!)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return searching ? matches.count : attractionNames.count
    }
    
    
    // MARK:- updateSearchResults methods
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text,
            !searchText.isEmpty {
            matches.removeAll()
            
            for index in 0..<attractionNames.count {
                if attractionNames[index].lowercased().contains(
                    searchText.lowercased()) {
                    matches.append(index)
                }
            }
            searching = true
        } else {
            searching = false
        }
        tableView.reloadData()
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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

}
