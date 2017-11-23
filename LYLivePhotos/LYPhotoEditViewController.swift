//
//  LYPhotoEditViewController.swift
//  LYLivePhotos
//
//  Created by cruzr on 2017/11/21.
//  Copyright © 2017年 martin. All rights reserved.
//

import UIKit
import Photos
import PhotosUI
import MobileCoreServices

class LYPhotoEditViewController: UIViewController {

    var livePhotoAsset: PHAsset?
    var photoView: PHLivePhotoView!
    
    var movieURL = URL(fileURLWithPath: (NSTemporaryDirectory()).appending("tempVideo.mov"))
    
    override func viewDidLoad() {
        super.viewDidLoad()

        photoView = PHLivePhotoView(frame: CGRect.init(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.width))
        photoView.contentMode = .scaleAspectFit
        
        self.view.addSubview(photoView)
        // Do any additional setup after loading the view.
        
        let resources = PHAssetResource.assetResources(for: self.livePhotoAsset!)
        for resource in resources {
            if resource.type == .pairedVideo {
                self.removeFileIfExists(fileURL: movieURL)
                PHAssetResourceManager.default().writeData(for: resource, toFile: movieURL as URL, options: nil) { (error) in
                    if error != nil{
                        print("Could not write video file")
                    } else {
                        
                        let item = AVPlayerItem(url: self.movieURL)
                        let player = AVPlayer(playerItem: item)
                        let layer = AVPlayerLayer(player: player)
                        layer.frame = self.view.frame
                        self.view.layer.addSublayer(layer)
                        player.play()
                        
                    }
                }
                
                break
            }
        }
    }
    
    func removeFileIfExists(fileURL : URL) {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: fileURL.path) {
            do {
                try fileManager.removeItem(at: fileURL)
            }
            catch {
                print("Could not delete exist file so cannot write to it")
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        self.photoView.center = self.view.center
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        configureView()
    }
    
    func configureView() {
        if let photoAsset = livePhotoAsset {
            PHImageManager.default().requestLivePhoto(for: photoAsset, targetSize: photoView.frame.size, contentMode: .aspectFit, options: nil, resultHandler: { (photo: PHLivePhoto?, info: [AnyHashable : Any]?) in
                
                if let livePhoto = photo{
                    self.photoView.livePhoto = livePhoto
                    self.photoView.startPlayback(with: .full)
                    
                    let geoCoder = CLGeocoder()
                    geoCoder.reverseGeocodeLocation(photoAsset.location!, completionHandler: { (placemark: [CLPlacemark]?, error: Error?) in
                        if error == nil {
                            self.navigationItem.title = placemark?.first?.locality
                        }
                    })
                }
            })
        }
    }
    
    @IBAction func loopBtnClicked(_ sender: UIButton) {
        
        let loopURL = URL(fileURLWithPath: (NSTemporaryDirectory()).appending("tempLoopVideo.mov"))
        removeFileIfExists(fileURL: loopURL)
        
        AVUtilities.loop(AVURLAsset(url: self.movieURL), outputURL: loopURL) { (asset) in
            DispatchQueue.main.async {
                let item = AVPlayerItem(url: loopURL)
                let player = AVPlayer(playerItem: item)
                let layer = AVPlayerLayer(player: player)
                layer.frame = self.view.frame
                self.view.layer.addSublayer(layer)
                player.play()
            }
        }
        
    }
    
    @IBAction func playBackBtnClicked(_ sender: UIButton) {
        let playbackURL = URL(fileURLWithPath: (NSTemporaryDirectory()).appending("playbackVideo.mov"))
        removeFileIfExists(fileURL: playbackURL)
        
        AVUtilities.playback(AVURLAsset(url: self.movieURL), outputURL: playbackURL) { (asset) in
            DispatchQueue.main.async {
                let item = AVPlayerItem(url: playbackURL)
                let player = AVPlayer(playerItem: item)
                let layer = AVPlayerLayer(player: player)
                layer.frame = self.view.frame
                self.view.layer.addSublayer(layer)
                player.play()
                
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: playbackURL)
                }, completionHandler: { (isSuccess, error) in
                    if isSuccess {
                        print("videoSaved")
                    } else{
                        print("保存失败：\(error!.localizedDescription)")
                    }
                })
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
