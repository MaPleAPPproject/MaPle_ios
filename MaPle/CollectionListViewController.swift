//
//  CollectionListViewController.swift
//  MaPle
//
//  Created by Violet on 2018/11/27.
//

import UIKit

class CollectionListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    @IBOutlet weak var segmentView: UISegmentedControl!
    @IBOutlet weak var collectViewlayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    var serverReach: Reachability?
    let communicatior = ExploreCommunicator.shared
    let fullScreenSize = UIScreen.main.bounds.size
    var districtList:[String]?
    var searchActive : Bool = false
    let searchController = UISearchController(searchResultsController: nil)
//    let buttonBar = UIView()
    var datas = [Picture]()
    var filtered:[Picture] = []
    var tops = [Picture]()
    var recoms = [Picture]()
    var news = [Picture]()
//    private let refreshControl = UIRefreshControl()
    let memberid = UserDefaults.standard.string(forKey: "MemberID")

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //draw layout
        self.collectViewlayout.itemSize = CGSize(width: self.fullScreenSize.width/3, height: self.fullScreenSize.width/3)
        self.collectViewlayout.minimumLineSpacing = 0
        self.collectViewlayout.minimumInteritemSpacing = 0
        //check web connection
        serverReach = Reachability.forInternetConnection()
        NotificationCenter.default.addObserver(self, selector: #selector(networkStatusChanged), name: .reachabilityChanged, object: nil)
        serverReach?.startNotifier()
        
        guard serverReach?.currentReachabilityStatus() != NotReachable else {
            print("No network connection.")
            return
        }
        guard let finalmemberid = memberid else {
            assertionFailure("memberid is nil")
            return
        }
        //Task
        getPictureTop()
        getPictureNew()
        getPictureRecom(memberid: finalmemberid)
        
        // Searchbar
        getDistrictList()
        self.segmentstylechange()
        
        //refreshControl
//        if #available(iOS 10.0, *) {
//            self.collectionView.refreshControl = refreshControl
//        } else {
//            self.collectionView.addSubview(refreshControl)
//        }
//        refreshControl.addTarget(self, action: #selector(refreshPictureData(_:)), for: .valueChanged)
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        //        DispatchQueue.main.async {
        //            UIView.animate(withDuration: 0.3) {
        //                self.buttonBar.frame.origin.x = (self.segmentView.frame.width / CGFloat(self.segmentView.numberOfSegments)) * CGFloat(self.segmentView.selectedSegmentIndex)
        //                self.buttonBar.layoutIfNeeded()
        //                print("self.buttonBar.frame.origin.x:\(self.buttonBar.frame.origin.x)")
        //            }
        //        }
        super.viewWillAppear(animated)
        print("viewWillAppear index:\(self.segmentView.selectedSegmentIndex)")
        self.categoryValueChanged(self.segmentView)
        
    }
    
    
//    @objc func refreshPictureData(_ sender: Any) {
//        guard let finalmemberid = self.memberid else {
//            assertionFailure("memberid is nil")
//            return
//        }
//        getPictureTop()
//        getPictureNew()
//        getPictureRecom(memberid:finalmemberid)
//        self.refreshControl.endRefreshing()
//    }
    
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
    func getPictureTop() {
        communicatior.getTop { (result, error) in
            if let error = error {
                print("failed to getTop:\(error)")
            }
            guard let result = result else {
                print("result is nil")
                return
            }
            //            print("result:\(result)")
            for item in result {
                guard let jsonData = try? JSONSerialization.data(withJSONObject: item, options: .prettyPrinted) else {
                    print("Fail to generate jsonData") //先將json物件轉為data
                    return
                }
                guard let resultObject = try? JSONDecoder().decode(Picture.self, from: jsonData) else {
                    print("fail to decode")
                    return
                }
                self.tops.append(resultObject)
            }
            //            print("tops:\(self.tops)")
            self.datas = self.tops
            self.collectionView.delegate = self
            self.collectionView.dataSource = self
            self.collectionView.reloadData()
        }
        
    }
    
    func getPictureRecom(memberid: String) {
        communicatior.getRecom(memberid: memberid, completion: { (result, error) in
            if let error = error {
                print("error:\(error)")
            }
            guard let result = result else {
                print("result is nil")
                return
            }
            for item in result {
                guard let jsonData = try? JSONSerialization.data(withJSONObject: item, options: .prettyPrinted) else {
                    print("Fail to generate jsonData") //先將json物件轉為data
                    return
                }
                guard let resultObject = try? JSONDecoder().decode(Picture.self, from: jsonData) else {
                    print("fail to decode")
                    return
                }
                self.recoms.append(resultObject)
            }
            //            print("recoms:\(self.recoms)")
            self.datas = self.recoms
            self.collectionView.reloadData()
        })
        
    }
    
    func getPictureNew() {
        communicatior.getAll { (result, error) in
            if let error = error {
                print("failed to getTop:\(error)")
            }
            guard let result = result else {
                print("result is nil")
                return
            }
            //            print("result:\(result)")
            for item in result {
                guard let jsonData = try? JSONSerialization.data(withJSONObject: item, options: .prettyPrinted) else {
                    print("Fail to generate jsonData") //先將json物件轉為data
                    return
                }
                guard let resultObject = try? JSONDecoder().decode(Picture.self, from: jsonData) else {
                    print("fail to decode")
                    return
                }
                self.news.append(resultObject)
            }
            //            print("news:\(self.news)")
            self.datas = self.news
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
            if datas.count == 0 {
                self.backgroundImageView.isHidden = false
                self.backgroundImageView.image = UIImage(named:"recomView.png")
                self.backgroundImageView.contentMode = .scaleAspectFit
            } else {
                self.backgroundImageView.isHidden = true
            }
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
    
    func showAlert(title: String? = nil, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OK = UIAlertAction(title: "OK", style: .default)
        alert.addAction(OK)
        present(alert,animated: true)
    }
    
    @IBAction func categoryValueChanged(_ sender: UISegmentedControl) {
        
        self.datas.removeAll()
        switch sender.selectedSegmentIndex {
        case 0:
            self.tops.removeAll()
            getPictureTop()
        case 1:
            self.recoms.removeAll()
            getPictureRecom(memberid: self.memberid!)
        case 2:
            self.news.removeAll()
            getPictureNew()
        default:
            self.tops.removeAll()
            getPictureTop()
        }
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
            targetVC.picture = self.datas[selectedIndexPath.row]
            targetVC.navigationItem.leftItemsSupplementBackButton = true
        }
        
    }
    
    @IBAction func unwindToList(_ unwindSegue: UIStoryboardSegue) {
        guard unwindSegue.identifier == "ExplorePage" else {
            return
        }
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
        
        //add underline
        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = .gray
        view.addSubview(line)
        line.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        // Constrain the button bar to the left side of the segmented control
        line.leftAnchor.constraint(equalTo: segmentView.leftAnchor).isActive = true
        // Constrain the button bar to the width of the segmented control divided by the number of segments
        line.widthAnchor.constraint(equalTo: segmentView.widthAnchor).isActive = true
        line.topAnchor.constraint(equalTo: segmentView.bottomAnchor).isActive = true
        
        // This needs to be false since we are using auto layout constraints
        //        buttonBar.translatesAutoresizingMaskIntoConstraints = false
        //        buttonBar.backgroundColor = UIColor(red: 30/255, green: 163/255, blue: 163/255, alpha: 1.0)
        //        view.addSubview(buttonBar)
        //        // Constrain the top of the button bar to the bottom of the segmented control
        //        buttonBar.bottomAnchor.constraint(equalTo: segmentView.bottomAnchor).isActive = true
        //        buttonBar.heightAnchor.constraint(equalToConstant: 5).isActive = true
        //        // Constrain the button bar to the left side of the segmented control
        //        buttonBar.leftAnchor.constraint(equalTo: segmentView.leftAnchor).isActive = true
        //        // Constrain the button bar to the width of the segmented control divided by the number of segments
        //        buttonBar.widthAnchor.constraint(equalTo: segmentView.widthAnchor, multiplier: 1 / CGFloat(segmentView.numberOfSegments)).isActive = true
        segmentView.addTarget(self, action: #selector(self.categoryValueChanged(_:)), for: UIControl.Event.valueChanged)
    }
}
