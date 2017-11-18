//
//  PhotoEditingViewController.swift
//  LYLivePhotoEdit
//
//  Created by cruzr on 2017/11/17.
//  Copyright © 2017年 martin. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

class PhotoEditingViewController: UIViewController {

    var input: PHContentEditingInput?
    
    var livePhoto : PHLivePhoto?
    
    lazy var livePhotoContext: PHLivePhotoEditingContext = {
        return PHLivePhotoEditingContext(livePhotoEditingInput: self.input!)!
    }()
    
    @IBOutlet weak var livePhotoView: PHLivePhotoView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func coverToVideoClicked(_ sender: UIButton) {
        
        if let livePhoto = self.livePhoto {
            let assetResources = PHAssetResource.assetResources(for: livePhoto)
            var videoResource : PHAssetResource? = nil
            for resource in assetResources {
                if resource.type == .pairedVideo {
                    videoResource = resource
                    break
                }
            }
            if videoResource != nil {
                let filePath = NSTemporaryDirectory() + "tempVideo1.mov"
                let fileUrl = URL(fileURLWithPath: filePath)
                removeFileIfExists(fileURL: fileUrl)
                PHAssetResourceManager.default().writeData(for: videoResource!, toFile: fileUrl, options: nil, completionHandler: { (error) in
                    
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: fileUrl)
                    }, completionHandler: { (isSuccess, error) in
                        if isSuccess {
                            print("videoSaved")
                        } else{
                            print("保存失败：\(error!.localizedDescription)")
                        }
                    })
                })
            }
        }else{
            
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
    
    @objc func videoSaved() {
        print("videoSaved")
    }
    
}

extension PhotoEditingViewController : PHContentEditingController {
    // MARK: - PHContentEditingController
    
    func canHandle(_ adjustmentData: PHAdjustmentData) -> Bool {
        // Inspect the adjustmentData to determine whether your extension can work with past edits.
        // (Typically, you use its formatIdentifier and formatVersion properties to do this.)
        return false
    }
    
    func startContentEditing(with contentEditingInput: PHContentEditingInput, placeholderImage: UIImage) {
        // Present content for editing, and keep the contentEditingInput for use when closing the edit session.
        // If you returned true from canHandleAdjustmentData:, contentEditingInput has the original image and adjustment data.
        // If you returned false, the contentEditingInput has past edits "baked in".
        input = contentEditingInput
        
        self.livePhoto = input?.livePhoto
        self.livePhotoView.livePhoto = livePhoto

        
//        let size = input?.displaySizeImage!.size
//        livePhotoContext.frameProcessor = { frame, _ in
//            return frame.image
//        }
//        livePhotoContext.prepareLivePhotoForPlayback(withTargetSize: size!, options: nil, completionHandler: { livePhoto, error in
//            self.livePhoto = livePhoto
//            self.livePhotoView.livePhoto = livePhoto
//        })
    }
    
    func finishContentEditing(completionHandler: @escaping ((PHContentEditingOutput?) -> Void)) {
        // Update UI to reflect that editing has finished and output is being rendered.
        
        // Render and provide output on a background queue.
        DispatchQueue.global().async {
            // Create editing output from the editing input.
            let output = PHContentEditingOutput(contentEditingInput: self.input!)
            
            // Provide new adjustments and render output to given location.
            // output.adjustmentData = <#new adjustment data#>
            // let renderedJPEGData = <#output JPEG#>
            // renderedJPEGData.writeToURL(output.renderedContentURL, atomically: true)
            
            // Call completion handler to commit edit to Photos.
            completionHandler(output)
            
            // Clean up temporary files, etc.
        }
    }
    
    var shouldShowCancelConfirmation: Bool {
        // Determines whether a confirmation to discard changes should be shown to the user on cancel.
        // (Typically, this should be "true" if there are any unsaved changes.)
        return false
    }
    
    func cancelContentEditing() {
        // Clean up temporary files, etc.
        // May be called after finishContentEditingWithCompletionHandler: while you prepare output.
    }
}
