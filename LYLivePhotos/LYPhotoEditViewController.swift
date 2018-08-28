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
    
    let layer = AVPlayerLayer()
    
    var movieURL = URL(fileURLWithPath: (NSTemporaryDirectory()).appending("tempVideo.mov"))
    
    var outputURL : URL? = nil
    
    let loopURL = URL(fileURLWithPath: (NSTemporaryDirectory()).appending("tempLoopVideo.mov"))
    let playBackURL = URL(fileURLWithPath: (NSTemporaryDirectory()).appending("tempPlayBackVideo.mov"))
    
    @IBOutlet weak var originalBtn: UIButton! {
        didSet {
            originalBtn.layer.cornerRadius = 5
        }
    }
    
    @IBOutlet weak var loopBtn: UIButton! {
        didSet {
            loopBtn.layer.cornerRadius = 5
        }
    }
    
    @IBOutlet weak var playbackBtn: UIButton! {
        didSet {
            playbackBtn.layer.cornerRadius = 5
        }
    }
    
    @IBOutlet weak var playBtn: UIButton! {
        didSet {
            playBtn.isHidden = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        removeFileIfExists(fileURL: loopURL)
        removeFileIfExists(fileURL: playBackURL)
        let rightBtn = UIBarButtonItem(title: "保存视频", style: .done, target: self, action: #selector(LYPhotoEditViewController.rightBtnClicked))
        self.navigationItem.rightBarButtonItem = rightBtn

//        photoView = PHLivePhotoView(frame: CGRect.init(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.width))
//        photoView.contentMode = .scaleAspectFit
//        self.view.addSubview(photoView)
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(LYPhotoEditViewController.playEnd(no:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        
        let resources = PHAssetResource.assetResources(for: self.livePhotoAsset!)
        for resource in resources {
            if resource.type == .pairedVideo {
                SVProgressHUD.show(withStatus: "")
                self.removeFileIfExists(fileURL: movieURL)
                let options = PHAssetResourceRequestOptions()
                options.isNetworkAccessAllowed = true
                PHAssetResourceManager.default().writeData(for: resource, toFile: movieURL as URL, options: options) { (error) in
                    if error != nil{
                        print("Could not write video file")
                        SVProgressHUD.dismiss()
                    } else {
                        DispatchQueue.main.async {
                            SVProgressHUD.dismiss()
                            let item = AVPlayerItem(url: self.movieURL)
                            let player = AVPlayer(playerItem: item)
                            self.layer.player = player
                            self.layer.frame = self.view.frame
                            self.view.layer.addSublayer(self.layer)
                            player.play()
                            self.outputURL = self.movieURL
                            self.originalBtn.backgroundColor = UIColor.blue
                            self.originalBtn.setTitleColor(UIColor.white, for: .normal)
                        }
                    }
                }
                break
            }
        }
    }
    
    @IBAction func playBtnClicked(_ sender: UIButton) {
        
        if let player = self.layer.player {
            player.seek(to: CMTime(seconds: 0, preferredTimescale: 1))
            player.play()
            playBtn.isHidden = true
        }
    }
    
    @objc func rightBtnClicked() {
        if let url = self.outputURL {
            saveToAlbum(url: url)
        }
    }
    
    func saveToAlbum(url : URL) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
        }, completionHandler: { (isSuccess, error) in
            if isSuccess {
                SVProgressHUD.showSuccess(withStatus: "保存成功，请到相册中查看")
            } else{
                SVProgressHUD.showError(withStatus: "保存失败：\(error!.localizedDescription)")
            }
        })
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
    
    func fileExist(fileURL : URL) -> Bool {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: fileURL.path) {
            return true
        } else {
            return false
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
    
//    func configureView() {
//        if let photoAsset = livePhotoAsset {
//            PHImageManager.default().requestLivePhoto(for: photoAsset, targetSize: photoView.frame.size, contentMode: .aspectFit, options: nil, resultHandler: { (photo: PHLivePhoto?, info: [AnyHashable : Any]?) in
//                if let livePhoto = photo{
//                    self.photoView.livePhoto = livePhoto
//                    self.photoView.startPlayback(with: .full)
//                    let geoCoder = CLGeocoder()
//                    geoCoder.reverseGeocodeLocation(photoAsset.location!, completionHandler: { (placemark: [CLPlacemark]?, error: Error?) in
//                        if error == nil {
//                            self.navigationItem.title = placemark?.first?.locality
//                        }
//                    })
//                }
//            })
//        }
//    }
    
    @IBAction func originalBtnClicked(_ sender: UIButton) {
        if fileExist(fileURL: movieURL) {
            playBtn.isHidden = true
            let item = AVPlayerItem(url: self.movieURL)
            let player = AVPlayer(playerItem: item)
            self.layer.player = player
            player.play()
            self.outputURL = self.movieURL
            self.originalBtn.backgroundColor = UIColor.blue
            self.originalBtn.setTitleColor(UIColor.white, for: .normal)
            self.loopBtn.backgroundColor = UIColor.white
            self.loopBtn.setTitleColor(UIColor.blue, for: .normal)
            self.playbackBtn.backgroundColor = UIColor.white
            self.playbackBtn.setTitleColor(UIColor.blue, for: .normal)
        }
    }
    
    @IBAction func loopBtnClicked(_ sender: UIButton) {
        playBtn.isHidden = true
        if fileExist(fileURL: loopURL) {
            let item = AVPlayerItem(url: self.loopURL)
            let player = AVPlayer(playerItem: item)
            self.layer.player = player
            player.play()
            self.outputURL = self.loopURL
        } else {
            SVProgressHUD.show(withStatus: "处理中")
            AVUtilities.loop(AVURLAsset(url: self.movieURL), outputURL: loopURL) { (asset) in
                let item = AVPlayerItem(url: self.loopURL)
                let player = AVPlayer(playerItem: item)
                self.layer.player = player
                player.play()
                self.outputURL = self.loopURL
                SVProgressHUD.dismiss()
                self.playBtn.isHidden = true
            }
        }
        self.originalBtn.backgroundColor = UIColor.white
        self.originalBtn.setTitleColor(UIColor.blue, for: .normal)
        self.loopBtn.backgroundColor = UIColor.blue
        self.loopBtn.setTitleColor(UIColor.white, for: .normal)
        self.playbackBtn.backgroundColor = UIColor.white
        self.playbackBtn.setTitleColor(UIColor.blue, for: .normal)
    }
    
    @IBAction func playBackBtnClicked(_ sender: UIButton) {
        playBtn.isHidden = true
        if fileExist(fileURL: playBackURL) {
            let item = AVPlayerItem(url: self.playBackURL)
            let player = AVPlayer(playerItem: item)
            self.layer.player = player
            player.play()
            self.outputURL = self.playBackURL
        } else {
            SVProgressHUD.show(withStatus: "处理中")
            AVUtilities.playback(AVURLAsset(url: self.movieURL), outputURL: playBackURL) { (asset) in
                let item = AVPlayerItem(url: self.playBackURL)
                let player = AVPlayer(playerItem: item)
                self.layer.player = player
                player.play()
                self.outputURL = self.playBackURL
                SVProgressHUD.dismiss()
                self.playBtn.isHidden = true
            }
        }
        self.originalBtn.backgroundColor = UIColor.white
        self.originalBtn.setTitleColor(UIColor.blue, for: .normal)
        self.loopBtn.backgroundColor = UIColor.white
        self.loopBtn.setTitleColor(UIColor.blue, for: .normal)
        self.playbackBtn.backgroundColor = UIColor.blue
        self.playbackBtn.setTitleColor(UIColor.white, for: .normal)
    }
    
    @objc func playEnd(no : Notification) {
        self.view.bringSubview(toFront: playBtn)
        playBtn.isHidden = false
    }
}
