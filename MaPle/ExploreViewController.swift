//
//  SecondViewController.swift
//  MaPle
//
//  Created by Violet on 2018/10/23.
//

import UIKit

class ExploreViewController: UIViewController, UICollectionViewDelegate, UISearchBarDelegate, UICollectionViewDataSource,UISearchResultsUpdating,UISearchControllerDelegate {
    
    var collectionViewController: CollectionListViewController!
    lazy var searchtableViewController: SearchTableViewController = {
        self.storyboard?.instantiateViewController(withIdentifier: "searchbarVC") as! SearchTableViewController
    }()
    var selectedViewController: UIViewController!

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var segmentView: UISegmentedControl!
    @IBOutlet weak var collectViewlayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionView: UICollectionView!
    var serverReach: Reachability?
    let communicatior = ExploreCommunicator.shared
    let fullScreenSize = UIScreen.main.bounds.size
    var districtList = [String]()
    var searchActive : Bool = false
    let searchController = UISearchController(searchResultsController: nil)
    let buttonBar = UIView()
    var datas = [Picture]()
    var filtered:[String] = []
    var tops = [Picture]()
    var recoms = [Picture]()
    var news = [Picture]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //draw layout
//        self.collectViewlayout.itemSize = CGSize(width: self.fullScreenSize.width/3, height: self.fullScreenSize.width/3)
//        self.collectViewlayout.minimumLineSpacing = 0
//        self.collectViewlayout.minimumInteritemSpacing = 0
        //check web connection
        serverReach = Reachability.forInternetConnection()
        NotificationCenter.default.addObserver(self, selector: #selector(networkStatusChanged), name: .reachabilityChanged, object: nil)
        serverReach?.startNotifier()
        
        guard serverReach?.currentReachabilityStatus() != NotReachable else {
            print("No network connection.")
            return
        }
//        //Task
//        getPictureTop()
//        getPictureNew()
//        getPictureRecom()
//
//        // Searchbar
        getDistrictList()
        self.searchController.searchResultsUpdater = self
        self.searchController.delegate = self
        self.searchController.searchBar.delegate = self
        
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.dimsBackgroundDuringPresentation = true
        self.searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "搜尋地點"
        searchController.searchBar.sizeToFit()
        searchController.searchBar.becomeFirstResponder()
        self.navigationItem.titleView = searchController.searchBar
        selectedViewController = collectionViewController
//        self.segmentstylechange()
    }
    @objc
    func networkStatusChanged(){
        
        guard let status = serverReach?.currentReachabilityStatus() else {
            return
        }
        print("Network status:\(status)")
        if status == NotReachable {
            showAlert(message: "目前網路狀態不佳,請檢查網路連線")
        } else {
            
        }
    }
    
    
    func changePage(to newViewController: UIViewController) {
        // 2. Remove previous viewController
        selectedViewController.willMove(toParent: nil)
        selectedViewController.view.removeFromSuperview()
        selectedViewController.removeFromParent()
        
        // 3. Add new viewController
        addChild(newViewController)
        self.containerView.addSubview(newViewController.view)
        newViewController.view.frame = containerView.bounds
        newViewController.didMove(toParent: self)
        
        // 4.
        self.selectedViewController = newViewController
    }
    
    func getDistrictList() {
        communicatior.getDistinct { (result, error) in
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
        }
    }

    func showAlert(title: String? = nil, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OK = UIAlertAction(title: "OK", style: .default)
        alert.addAction(OK)
        present(alert,animated: true)
    }
    
    @IBAction func categoryValueChanged(_ sender: UISegmentedControl) {
        UIView.animate(withDuration: 0.3) {
            self.buttonBar.frame.origin.x = (self.segmentView.frame.width / CGFloat(self.segmentView.numberOfSegments)) * CGFloat(self.segmentView.selectedSegmentIndex)
        }
        switch sender.selectedSegmentIndex {
        case 0:
            self.datas = self.tops
            self.collectionView.reloadData()
        case 1:
            self.datas = self.recoms
            self.collectionView.reloadData()
        case 2:
            self.datas = self.news
            self.collectionView.reloadData()
        default:
            self.datas = self.tops
            self.collectionView.reloadData()

        }
    }
    
    
    //MARK:- collectionView Method
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if searchActive {
            return filtered.count
        }
        else
        {
            return datas.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        guard let pictureCell = cell as? ExploreCollectionViewCell else {
            assertionFailure("pictureCell = cell as? ExploreCollectionViewCell")
            return cell
        }
        let postid = datas[indexPath.row].postid
        communicatior.getImage(postId: String(postid)) { (data, error) in
            if let error = error {
                print("error:\(error)")
            }
            guard let picturedata = data else {
                print("data is nil")
                return
            }
            pictureCell.imageView.image = UIImage(data: picturedata)
            
        }
        return pictureCell
    }
    
    //MARK:- Actions
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
            targetVC.picture = self.datas[selectedIndexPath.row]
            targetVC.navigationItem.leftItemsSupplementBackButton = true
        } else if segue.identifier == "ContainerViewSegue" {
            collectionViewController = segue.destination as! CollectionListViewController
        }
        
    }
    
    @IBAction func unwindToList(_ unwindSegue: UIStoryboardSegue) {
        guard unwindSegue.identifier == "ExplorePage" else {
            return
        }
    }
    //MARK:- SearchBar
   
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchString = searchController.searchBar.text
        
        filtered = self.districtList.filter({ (item) -> Bool in
            let countryText: NSString = item as NSString
            return (countryText.range(of: searchString!, options: NSString.CompareOptions.caseInsensitive).location) != NSNotFound
        })
        
        print("filtered:\(filtered.description)")
        searchtableViewController.searchActive = true
        searchtableViewController.filtered = self.filtered
        searchtableViewController.topPictures = self.collectionViewController.tops
        searchtableViewController.newPictures = self.collectionViewController.news
        searchtableViewController.tableView.reloadData()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        changePage(to: collectionViewController)
        searchActive = false
        self.dismiss(animated: true, completion: nil)
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        changePage(to: searchtableViewController)
        searchActive = true
        searchtableViewController.tableView.reloadData()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        searchtableViewController.tableView.reloadData()
    }
    
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        if !searchActive {
            searchActive = true
            searchtableViewController.tableView.reloadData()
        }
        
//        searchController.searchBar.resignFirstResponder()
    }
    
    //MARK:- Segment Style
    func segmentstylechange() {
        self.segmentView.backgroundColor = .clear
        self.segmentView.tintColor = .clear
        self.segmentView.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont(name: "DINCondensed-Bold", size: 18),
            NSAttributedString.Key.foregroundColor: UIColor.lightGray
            ], for: .normal)
        
        self.segmentView.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont(name: "DINCondensed-Bold", size: 18),
            NSAttributedString.Key.foregroundColor: UIColor(red: 30/255, green: 163/255, blue: 163/255, alpha: 1.0)
            ], for: .selected)
        // This needs to be false since we are using auto layout constraints
        buttonBar.translatesAutoresizingMaskIntoConstraints = false
        buttonBar.backgroundColor = UIColor(red: 30/255, green: 163/255, blue: 163/255, alpha: 1.0)
        view.addSubview(buttonBar)
        // Constrain the top of the button bar to the bottom of the segmented control
        buttonBar.topAnchor.constraint(equalTo: segmentView.bottomAnchor).isActive = true
        buttonBar.heightAnchor.constraint(equalToConstant: 5).isActive = true
        // Constrain the button bar to the left side of the segmented control
        buttonBar.leftAnchor.constraint(equalTo: segmentView.leftAnchor).isActive = true
        // Constrain the button bar to the width of the segmented control divided by the number of segments
        buttonBar.widthAnchor.constraint(equalTo: segmentView.widthAnchor, multiplier: 1 / CGFloat(segmentView.numberOfSegments)).isActive = true
        segmentView.addTarget(self, action: #selector(self.categoryValueChanged(_:)), for: UIControl.Event.valueChanged)
    }
}


