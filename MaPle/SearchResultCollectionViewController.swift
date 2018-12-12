//
//  SearchResultCollectionViewController.swift
//  MaPle
//
//  Created by Violet on 2018/11/28.
//

import UIKit
import MapKit

class SearchResultCollectionViewController: UICollectionViewController,UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionFlowLayout: UICollectionViewFlowLayout!
    var filteredtopsPictures = [Picture]()
    var filterednewsPictures = [Picture]()
    var data = [Picture]()
    var selectedDistrict: String?
    let communicatior = ExploreCommunicator.shared
    let fullScreenSize = UIScreen.main.bounds.size
    let selectedAnnotation = LocationAnnotation()
    var finalheaferView: ResultMapCollectionReusableView? = nil
    var finalfooterView: TitleCollectionReusableView? = nil

    
    override func viewDidLoad() {
        super.viewDidLoad()
        //draw layout
        self.navigationController?.title = selectedDistrict
        self.collectionFlowLayout.itemSize = CGSize(width: self.fullScreenSize.width/3, height: self.fullScreenSize.width/3)
        self.collectionFlowLayout.minimumLineSpacing = 0
        self.collectionFlowLayout.minimumInteritemSpacing = 0
        getannotationData(selectedDistrict: selectedDistrict)
        self.title = selectedDistrict
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
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
            if selectedIndexPath.section == 1 {
                targetVC.picture = self.filteredtopsPictures[selectedIndexPath.row]
                targetVC.navigationItem.leftItemsSupplementBackButton = true
            } else {
                targetVC.picture = self.filterednewsPictures[selectedIndexPath.row]
                targetVC.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region = MKCoordinateRegion(center: self.selectedAnnotation.coordinate, span: span)
            if let finalheaferView = self.finalheaferView {
                finalheaferView.resultmapView.setRegion(region, animated: true)
            }
        }
    }
    func getannotationData(selectedDistrict: String?) {
        guard let district = selectedDistrict else {
            assertionFailure("selectedDistrict is nil")
            return
        }
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(district) { (placemark, error) in
            if let error = error {
                print("error:\(error)")
            }
            guard let placemark = placemark else {
                assertionFailure("failed to get placemark")
                return
            }
            guard let coordinate = placemark.first?.location?.coordinate else {
                assertionFailure("failed to get coordinate")
                return
            }
            self.selectedAnnotation.coordinate = coordinate
        }
    }
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 0 //map header
        } else if section == 1 {
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
        if indexPath.section == 1 {
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
        } else if indexPath.section == 2 {
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
        } else {
            return cell
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == "UICollectionElementKindSectionHeader" {
            let reuableView = collectionView.dequeueReusableSupplementaryView(ofKind: "UICollectionElementKindSectionHeader", withReuseIdentifier: "header", for: indexPath)
            guard let finalheaferView = reuableView as? ResultMapCollectionReusableView else {
                assertionFailure("failed to find ResultMapCollectionReusableView")
                return reuableView
            }
            if indexPath.section == 0 {
                finalheaferView.resultmapView.addAnnotation(self.selectedAnnotation)
                self.finalheaferView = finalheaferView
            } else {
                finalheaferView.isHidden = true
            }
            return finalheaferView

        } else {
            let reuablefooterView = collectionView.dequeueReusableSupplementaryView(ofKind: "UICollectionElementKindSectionFooter", withReuseIdentifier: "footer", for: indexPath)

            guard  let finalfooterView = reuablefooterView as? TitleCollectionReusableView else {
                assertionFailure("failed to find TitleCollectionReusableView")
                return reuablefooterView
            }
            if indexPath.section == 0 {
                finalfooterView.titleLabel.text = "熱門"
            } else if indexPath.section == 1 {
                finalfooterView.titleLabel.text = "最新"
            } else {
                finalfooterView.isHidden = true
            }
            finalfooterView.titleLabel.textColor = UIColor(red: 30/255, green: 163/255, blue: 163/255, alpha: 1.0)
            return finalfooterView
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section != 0 {
            return CGSize.zero
        } else {
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height/4)
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
