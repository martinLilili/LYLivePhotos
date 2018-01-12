//
//  PhotosCollectionViewController.swift
//  LYLivePhotos
//
//  Created by cruzr on 2017/11/18.
//  Copyright © 2017年 martin. All rights reserved.
//

import UIKit
import Photos

private let reuseIdentifier = "Cell"

class PhotosCollectionViewController: UICollectionViewController {

    var livePhotoAssets: PHFetchResult<PHAsset>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
//        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        
        PHPhotoLibrary.requestAuthorization { (status:PHAuthorizationStatus) in
            switch status {
            case .authorized:
                self.fetchPhotos()
            default:
                self.showNoPhotoAccessAlert()
            }
        }

        self.collectionView?.gtm_addRefreshHeaderView {
            [weak self] in
            print("excute refreshBlock")
            self?.fetchPhotos()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchPhotos() {
        
        let sortDesciptor = NSSortDescriptor(key: "creationDate", ascending:false)
        let predicate = NSPredicate(format: "(mediaSubtype & %d) != 0", PHAssetMediaSubtype.photoLive.rawValue)
        
        let options = PHFetchOptions()
        
        options.sortDescriptors = [sortDesciptor]
        options.predicate = predicate
        
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            self.livePhotoAssets = PHAsset.fetchAssets(with: options)
            
            DispatchQueue.main.async {
                self.collectionView?.endRefreshing(isSuccess: true)
                self.collectionView?.reloadData()
            }
        }
    }
    
    
    func showNoPhotoAccessAlert() {
        let alert = UIAlertController(title: "No Photo Access Permission", message: "Please grant this App access your photos in Settings -- > Privacy", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler:{ (action: UIAlertAction) in
            let url = URL(string: UIApplicationOpenSettingsURLString)
            UIApplication.shared.open(url!, options: ["" : ""], completionHandler: nil)
            return
        }))
        
        self.present(alert, animated: true, completion: nil)
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
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if let numberOfItems = livePhotoAssets?.count {
            return numberOfItems
        } else {
            return 0
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotosCollectionViewCell
    
        if let asset = livePhotoAssets?[indexPath.row]{
            let options = PHImageRequestOptions()
            options.isNetworkAccessAllowed = true
            
            let targetSize = CGSize(width: 200, height: 200)
            PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options, resultHandler: { (image: UIImage?, info: [AnyHashable : Any]?) in
                cell.imageView.image = image
            })
        }
    
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = collectionView?.indexPathsForSelectedItems?.first {
            let photoVC = segue.destination as! LYPhotoEditViewController
            photoVC.livePhotoAsset = livePhotoAssets?[indexPath.item]
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
