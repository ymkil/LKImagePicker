//
//  LKAlbumModel.swift
//  LKImagePicker
//
//  Created by Mkil on 19/12/2016.
//  Copyright © 2016 黎宁康. All rights reserved.
//

import Foundation
import Photos
import AssetsLibrary

public enum LKAssetModelMediaType {
    case photo
    case livePhoto
    case video
    case audio
}

public class LKAssetModel {
    let asset: PHAsset
    var isSelected: Bool = false
    let type:LKAssetModelMediaType
    let timeLength:String
    
    init(_ asset:PHAsset,_ isSelected:Bool,_ type:LKAssetModelMediaType,_ timeLength:String) {
        self.asset = asset
        self.isSelected = isSelected
        self.type = type
        self.timeLength = timeLength
    }
}

public class LKAlbumModel {
    
    let name: String
    var count: Int
    let result: PHFetchResult<PHAsset>
    
    var models:[LKAssetModel] = []
    
    init(result: PHFetchResult<PHAsset>, name: String, _ allowPickingVideo:Bool, _ allowPickingImage:Bool, _ sortDate: Bool) {
        self.result = result
        self.name = name
        count = result.count

        AssetManager.getAssetsFromFetchResult(result, allowPickingVideo, allowPickingImage, sortDate) {
            (models) -> Void in
            self.models = models
        }
    }
}
