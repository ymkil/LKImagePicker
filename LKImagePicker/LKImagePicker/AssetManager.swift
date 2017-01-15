//
//  AssetManager.swift
//  LKImagePicker
//
//  Created by Mkil on 19/12/2016.
//  Copyright © 2016 黎宁康. All rights reserved.
//

import Foundation
import Photos
import AssetsLibrary

public struct AssetManager {
    
    // MARK: - 获取相册和相册列表
    /// 获取相册
    
    public static func getImageAlbum(_ allowPickingVideo: Bool, _ allowPickingImage: Bool, _ sortDate: Bool, _ completion: @escaping (LKAlbumModel) -> Void) {
        var model: LKAlbumModel? = nil
        
        let option = PHFetchOptions()
        
        if !allowPickingVideo {
            option.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
        }
        if !allowPickingImage {
            option.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.video.rawValue)
        }
        
        option.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: sortDate)]
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
        for i in 0..<smartAlbums.count {
            
//            guard smartAlbums[i] is PHAssetCollection else { continue }
            
            if isPhotoAlbum(smartAlbums[i].localizedTitle!) {
                let fetchResult = PHAsset.fetchAssets(in: smartAlbums[i], options: option)
                model = LKAlbumModel(result: fetchResult, name: smartAlbums[i].localizedTitle!,allowPickingVideo,allowPickingImage,sortDate)
                completion(model!)
                break
            }
        }
    }
    
    /// 获取相册列表
    public static func getAllAlbums(_ allowPickingVideo: Bool, _ allowPickingImage: Bool, _ sortDate: Bool, _ completion: @escaping ([LKAlbumModel]) -> Void) {
        
        var albumArray: [LKAlbumModel] = []
        

        let option = PHFetchOptions()
        if !allowPickingVideo {
            option.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
        }
        if !allowPickingImage {
            option.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.video.rawValue)
        }
        option.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: sortDate)]
        let myPhotoStreamAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumMyPhotoStream, options: nil)
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
        let topLevelUserCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)
        for i in 0..<myPhotoStreamAlbums.count {
            let fetchResult = PHAsset.fetchAssets(in: myPhotoStreamAlbums[i], options: option)
            guard !(fetchResult.count < 1) else { continue }
            albumArray.append(LKAlbumModel(result: fetchResult, name: myPhotoStreamAlbums[i].localizedTitle!,allowPickingVideo,allowPickingImage,sortDate))
        }
        for i in 0..<smartAlbums.count {
            
//            guard smartAlbums[i] is PHAssetCollection else { continue }
            let fetchResult = PHAsset.fetchAssets(in: smartAlbums[i], options: option)
            guard !(fetchResult.count < 1) else {
                continue }
            if ((smartAlbums[i].localizedTitle!.contains("Deleted")) || (smartAlbums[i].localizedTitle == "最近删除")) {
                continue
            }
            if isPhotoAlbum(smartAlbums[i].localizedTitle!) {
                albumArray.insert(LKAlbumModel(result: fetchResult, name: smartAlbums[i].localizedTitle!,allowPickingVideo,allowPickingImage,sortDate), at: 0)
            } else {
                albumArray.append(LKAlbumModel(result: fetchResult, name: smartAlbums[i].localizedTitle!,allowPickingVideo,allowPickingImage,sortDate))
            }
        }
        for i in 0..<topLevelUserCollections.count {
            guard topLevelUserCollections[i] is PHAssetCollection else { continue }
            let fetchResult = PHAsset.fetchAssets(in: topLevelUserCollections[i] as! PHAssetCollection, options: option)
            guard fetchResult.count >= 1 else { continue }
            albumArray.append(LKAlbumModel(result: fetchResult, name: topLevelUserCollections[i].localizedTitle!,allowPickingVideo,allowPickingImage,sortDate))
        }
        completion(albumArray)
    }
    
    /// 获取照片数组 
    public static func getAssetsFromFetchResult(_ result:PHFetchResult<PHAsset>, _ allowPickingVideo:Bool, _ allowPickingImage:Bool, _ sortDate: Bool, _ completion: @escaping ([LKAssetModel]) -> Void) {
        var photoArr:[LKAssetModel] = []
    
        result.enumerateObjects({ (obj, idx, stop) -> Void in
            let asset = obj 
            var type = LKAssetModelMediaType.photo
            if asset.mediaType == .video { type = .video }
            else if asset.mediaType == .audio { type = .audio }
            else if asset.mediaType == .image { type = .photo }
            
            if !allowPickingVideo && type == .video { return }
            if !allowPickingImage && type == .photo { return }
            
            var timeLength = type == .video ? String(format: "%0.0f", asset.duration) : ""
            if type == .video { timeLength = getNewTimeFromDurationSecond(duration: timeLength.toInt) }
            photoArr.append(LKAssetModel(asset,false,type,timeLength))
        })
        completion(photoArr)
         
    }
    
    /// 获取封面图
    public static func getSurfacePlot(_ model: LKAlbumModel, _ sortDate:Bool, _ shouldFixOrientation:Bool, completion:@escaping (UIImage) -> Void) {
        var asset = model.result.lastObject
        if !sortDate {
            asset = model.result.firstObject
        }
        if let asset = asset {
            getPhoto(asset, 80, shouldFixOrientation, completion: { (photo,info, isDegraded) -> Void in
                    if let image = photo {
                       completion(image)
                    }
                }, progressHandler: nil, networkAccessAllowed: true)
        }
    }
    
    // MARK: - 获取照片本身
    
    @discardableResult
    public static func getPhoto(_ asset: PHAsset, _ shouldFixOrientation: Bool,completion:@escaping (UIImage?,[AnyHashable : Any]?,Bool) -> Void, progressHandler: ((Double, Error?, UnsafeMutablePointer<ObjCBool>, [AnyHashable : Any]?) -> Void)?, networkAccessAllowed: Bool) -> PHImageRequestID {
        var fullScreenWidth = Configuration.ScreenWinth
        if fullScreenWidth > Configuration.photoPreviewMaxWidth {
            fullScreenWidth = Configuration.photoPreviewMaxWidth
        }
        return getPhoto(asset, fullScreenWidth, shouldFixOrientation, completion: completion, progressHandler: progressHandler, networkAccessAllowed: networkAccessAllowed)
    }

    @discardableResult
    public static func getPhoto(_ asset: PHAsset, _ width: CGFloat, _ shouldFixOrientation:Bool, completion:@escaping (UIImage?,[AnyHashable : Any]?,Bool) -> Void, progressHandler:((Double, Error?, UnsafeMutablePointer<ObjCBool>, [AnyHashable : Any]?) -> Void)?, networkAccessAllowed: Bool) -> PHImageRequestID {
        
        var imageSize: CGSize
        
        let phAsset = asset
        let aspectRatio = CGFloat(phAsset.pixelWidth) / CGFloat(phAsset.pixelHeight)
        let pixelWidth = width * Configuration.LKScreenScale
        let pixelHeight = pixelWidth / aspectRatio
        imageSize = CGSize(width: pixelWidth, height: pixelHeight)
        
        let option = PHImageRequestOptions()
        option.resizeMode = .fast   // 需检测获取图片的瞬间是否会出现内存过高的问题
        let imageRequestID = PHImageManager.default().requestImage(for: asset, targetSize: imageSize, contentMode: .aspectFill, options: option) {
            (result, info) -> Void in
            var resultImage = result
            let downloadFinined = info![PHImageCancelledKey] == nil && info![PHImageErrorKey] == nil
            if downloadFinined && (resultImage != nil) {
                resultImage = self.fixOrientation(resultImage!, shouldFixOrientation)

                completion(resultImage!, info, info?[PHImageResultIsDegradedKey] as! Bool)
            }
            
            // 从iCloud下载图片
            
            if info![PHImageResultIsInCloudKey] != nil && (resultImage == nil) {
                let option = PHImageRequestOptions()
                
                option.progressHandler = { (progress, error, stop, info) in
                    DispatchQueue.main.async {
                        if let block = progressHandler {
                            block(progress, error, stop, info)
                        }
                    }
                }
                
                option.isNetworkAccessAllowed = true
                option.resizeMode = .fast
                
                PHImageManager.default().requestImageData(for: asset, options: option) {
                    (imageData,dataUTI,orientation,info) -> Void in
                    var resultImage = UIImage(data: imageData!, scale: 0.1)
                    resultImage = self.scaleImage(resultImage!, imageSize)
                    if let _ = resultImage {
                        resultImage = self.fixOrientation(resultImage!, shouldFixOrientation)
                    }
                    
                    completion(resultImage, info, info?[PHImageResultIsDegradedKey] as! Bool)
                }
            }
            
        }
        
        return imageRequestID
    }
    
    
    /// Get Original Photo / 获取原图
    /// 该方法会先返回缩略图，再返回原图，如果info[PHImageResultIsDegradedKey] 为 YES，则表明当前返回的是缩略图，否则是原图。
    
    public static func getOriginalPhoto(asset:PHAsset, _ shouldFixOrientation:Bool, completion:((UIImage?, [AnyHashable : Any]?) -> Void)?) {
        AssetManager.getOriginalPhoto(asset: asset, shouldFixOrientation) { (photo, info, isDegraded) in
            if let completion = completion {
                completion(photo,info)
            }
        }
    }
    
    public static func getOriginalPhoto(asset:PHAsset, _ shouldFixOrientation:Bool, newCompletion:((UIImage?, [AnyHashable : Any]?, Bool?) -> Void)?) {
        let option = PHImageRequestOptions()
        option.isNetworkAccessAllowed = true
        
        PHImageManager.default().requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: option) { (result, info) in
            let downloadFinined = info![PHImageCancelledKey] == nil && info![PHImageErrorKey] == nil
            if downloadFinined , var photo = result {
                photo = self.fixOrientation(photo, shouldFixOrientation)
                let isDegraded = info?[PHImageResultIsDegradedKey] as? Bool
                if let completion = newCompletion {
                    completion(photo, info, isDegraded)
                }
            }
        }
        
    }
    
    /// Save photo
    
    private static var assetLibrary:ALAssetsLibrary = {
        return ALAssetsLibrary()
    }()
    
    public static func savePhoto(_ image:UIImage, completion:((Error?) -> Void)?) {
        let data = UIImageJPEGRepresentation(image, 0.9)
        if #available(iOS 9, *) , let data = data {
            PHPhotoLibrary.shared().performChanges({ 
                let options = PHAssetResourceCreationOptions()
                options.shouldMoveFile = true
                PHAssetCreationRequest.forAsset().addResource(with: .photo, data: data, options: options)
            }, completionHandler: { (success, error) in
                DispatchQueue.main.sync {
                    if success , let completion = completion {
                        completion(nil)
                    } else if let error = error {
                        if let completion = completion {
                            completion(error)
                        }
                    }
                }
            })
        } else {
            assetLibrary.writeImage(toSavedPhotosAlbum: image.cgImage, orientation: AssetManager.imageOrientation(image), completionBlock: { (assetURL, error) in
                if let error = error {
                    if let completion = completion {
                        completion(error)
                    }
                } else {
                    // 多给系统0.5秒的时间，让系统去更新相册数据
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(500)) {
                        if let completion = completion {
                            completion(nil)
                        }
                    }
                }
            })
        }
        
    }
    
    /// 获得一组照片的大小
    
    public static func getPhotosBytesWithArray(_ photos:[LKAssetModel], completion:((String) -> Void)?) {
        var dataLength:Float = 0
        var assetCount = 0
        
        for modle in photos {
            PHImageManager.default().requestImageData(for: modle.asset, options: nil) { (imageData, dataUTI, orientation, info) in
                if modle.type != .video , let imageData = imageData{
                    dataLength += Float(imageData.count)
                    assetCount += 1
                }
                if assetCount >= photos.count {
                    let bytes = AssetManager.getBytesFromDataLength(dataLength: dataLength)
                    if let completion = completion {
                        completion(bytes)
                    }
                }
            }
        }
    }
    
    
    // MARK: - Private Method
    public static func getBytesFromDataLength(dataLength:Float) -> String{
        var bytes:String
        if dataLength >= 0.1 * (1024 * 1024) {
            bytes = String(format: "%0.1fM", dataLength/1024/1024.0)
        } else if dataLength >= 1024 {
            bytes = String(format: "%0.0fK", dataLength/1024.0)
        } else {
            bytes = String(format: "%zdB", dataLength)
        }
        
        return bytes
    }
    
    /// 得到授权返回true
    public static func authorizationStatusAuthorized() -> Bool {
        
        return PHPhotoLibrary.authorizationStatus() != .denied
    }
    
    public static func imageOrientation(_ image: UIImage) -> ALAssetOrientation {
        var orientation:ALAssetOrientation
        switch image.imageOrientation {
        case .up: orientation = .up
        case .down: orientation = .down
        case .left: orientation = .left
        case .right: orientation = .right
        case .upMirrored: orientation = .upMirrored
        case .downMirrored: orientation = .downMirrored
        case .leftMirrored: orientation = .leftMirrored
        case .rightMirrored: orientation = .rightMirrored
        }
        
        return orientation
    }
    
    // MARK: - Tool
    /// 修正图片方向
    @discardableResult
    public static func fixOrientation(_ aImage:UIImage,_ shouldFixOrientation:Bool) -> UIImage {
        guard shouldFixOrientation else { return aImage }
        if aImage.imageOrientation == .up { return aImage }
        
        let transform = CGAffineTransform()
        
        switch aImage.imageOrientation {
        case .down,.downMirrored:
            transform.translatedBy(x: aImage.size.width, y: aImage.size.height)
            transform.rotated(by: CGFloat(M_PI))
        case .left,.leftMirrored:
            transform.translatedBy(x: aImage.size.width, y: 0)
            transform.rotated(by: CGFloat(M_PI_2))
        case .right,.rightMirrored:
            transform.translatedBy(x: 0, y: aImage.size.height)
            transform.rotated(by: -(CGFloat)(M_PI_2))
        default:
            break
        }
        
        switch aImage.imageOrientation {
        case .upMirrored,.downMirrored:
            transform.translatedBy(x: aImage.size.width, y: 0)
            transform.scaledBy(x: -1, y: -1)
        case .leftMirrored,.rightMirrored:
            transform.translatedBy(x: aImage.size.height, y: 0)
            transform.scaledBy(x: -1, y: -1)
        default:
            break
        }
        
        // 获得新的 context,进行 transform
        let ctx = CGContext(data: nil, width: aImage.cgImage!.width, height: aImage.cgImage!.height,
                            bitsPerComponent: aImage.cgImage!.bitsPerComponent, bytesPerRow: 0,
                            space: aImage.cgImage!.colorSpace!, bitmapInfo: aImage.cgImage!.bitmapInfo.rawValue)
        
        ctx?.concatenate(transform)
        switch aImage.imageOrientation {
        case .left,.leftMirrored,.right,.rightMirrored:
            ctx?.draw(aImage.cgImage!, in: CGRect(x: 0, y: 0, width: aImage.size.height, height: aImage.size.width))
        default:
            ctx?.draw(aImage.cgImage!, in: CGRect(x: 0, y: 0, width: aImage.size.width, height: aImage.size.height))
        }
        
        let cgImg = ctx?.makeImage()
        let img = UIImage(cgImage: cgImg!)
        // Swift 中CGcongtext 和 CGimage 自动释放
        return img
    }
    
    public static func scaleImage(_ image: UIImage, _ size: CGSize) -> UIImage {
        if image.size.width > size.width {
            UIGraphicsBeginImageContext(size)
            image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return newImage!
        } else {
            return image
        }
    }
    
    public static func isPhotoAlbum(_ albumName: String) -> Bool {
        var versionStr = UIDevice.current.systemVersion.replacingOccurrences(of: ".", with: "")
        
        if versionStr.characters.count <= 1 {
            versionStr.append("00")
        }else if versionStr.characters.count <= 2 {
            versionStr.append("0")
        }
        
        let version = versionStr.toFloat
        
        if version >= 800 && version <= 802 {
            return albumName == "最近添加" || albumName == "Recently Added"
        } else {
            return albumName == "Camera Roll" || albumName == "相机胶卷" || albumName == "所有照片" || albumName == "All Photos"
        }
    }
    
    public static func getNewTimeFromDurationSecond(duration:Int) -> String {
        var newTime:String
        if duration < 10 {
            newTime = String(format: "0:0%zd", duration)
        } else if duration < 60 {
            newTime = String(format: "0:%zd", duration)
        } else {
            let min = duration / 60
            let sec = duration % 60
            if sec < 10 {
                newTime = String(format: "%zd:0%zd", min,sec)
            } else {
                newTime = String(format: "%zd:%zd", min,sec)
            }
        }
        return newTime
    }
 
}
