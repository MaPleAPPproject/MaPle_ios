//
//  SearchResultCollectionViewController.swift
//  MaPle
//
//  Created by Violet on 2018/11/28.
//

import UIKit


class SearchResultCollectionViewController: UICollectionViewController {

    @IBOutlet weak var collectionFlowLayout: UICollectionViewFlowLayout!
    var filteredtopsPictures = [Picture]()
    var filterednewsPictures = [Picture]()
    var data = [Picture]()
    var selectedDistrict: String?
    let communicatior = ExploreCommunicator.shared
    let fullScreenSize = UIScreen.main.bounds.size
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //draw layout
        self.navigationController?.title = selectedDistrict
        self.collectionFlowLayout.itemSize = CGSize(width: self.fullScreenSize.width/3, height: self.fullScreenSize.width/3)
        self.collectionFlowLayout.minimumLineSpacing = 0
        self.collectionFlowLayout.minimumInteritemSpacing = 0

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            print(filteredtopsPictures.count)
            return filteredtopsPictures.count
        } else {
            print(filterednewsPictures.count)
            return filterednewsPictures.count
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        guard let finalcell = cell as? ExploreCollectionViewCell else {
            assertionFailure("failed to get class")
            return cell
        }
        if indexPath.section == 0 {
                let postid = filteredtopsPictures[indexPath.row].postid
                communicatior.getImage(postId: String(postid)) { (data, error) in
                    if let error = error {
                        print("error:\(error)")
                    }
                    guard let data = data else {
                        assertionFailure("data is nil")
                        return
                    }
                    finalcell.imageView.image = UIImage(data: data)
                }
                return finalcell
        } else {
            let postid = filterednewsPictures[indexPath.row].postid
            communicatior.getImage(postId: String(postid)) { (data, error) in
                if let error = error {
                    print("error:\(error)")
                }
                guard let data = data else {
                    assertionFailure("data is nil")
                    return
                }
                finalcell.imageView.image = UIImage(data: data)
            }
            return finalcell
        }
    }
    
    
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
