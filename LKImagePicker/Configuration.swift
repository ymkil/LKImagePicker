//
//  Configuration.swift
//  LKImagePicker
//
//  Created by Mkil on 19/12/2016.
//  Copyright © 2016 黎宁康. All rights reserved.
//

import UIKit
import Photos

internal enum LKOscillatoryAnimationType {
    case bigger
    case smaller
}


@objc public protocol LKImagePickerControllerDelegate: class {
    
   @objc optional func imagePickerControllerDidFinish(_ picker:LKImagePickerController, _ photos:[UIImage], _ assets:[Any], _ isSelectOriginalPhoto:Bool)
    
   @objc optional func imagePickerControllerDidCancel(_ picker:LKImagePickerController)
}


public struct ImagePickerConfig {
    
    /// 默认最大可选9张图片
    public var maxImagesCount = 9 {
        didSet {
            if maxImagesCount > 1 {
                showSelectBtn = true
            }
        }
    }
    
    /// 最小图片必选张数，默认是0
    public var minImagesCount = 0
    
    /// 默认按修改时间升序，默认为true，如果设置为false，最新照片会显示在最前面，内部拍照按钮会排在第一个
    public var sortAscendingByModificationDate = true
    
    /// 默认为true，如果设置为false，原图按钮将隐藏
    public var allowPickingOriginImage = true
    
    // TODO: 暂时不支持播放视频，会尽快完善
    /// 默认为true，如果设置为false，将不能选择发送视频
    public var allowPickingVideo = true {
        didSet {
            if !allowPickingVideo {
                allowPickingImage = true
            }
        }
    }
    
    /// 默认为true，如果设置为false，将不能选择发送图片
    public var allowPickingImage = true {
        didSet {
            if !allowPickingImage {
                allowPickingVideo = true
            }
        }
    }
    
    /// 默认为true，如果设置为false，将不能在选择器中拍照
    public var allowTakePicture = true
    
    // 默认为true，如果设置为false，预览按钮将隐藏，用户将不能取预览照片
    public var allowPreview = true
    
    /// 默认为false，如果设置true，会自动修正图片
    public var shouldFixOrientation = false
    
    /// 默认为true，图片展示列表自动滑动到底部
    public var shouldScrollToBottom = true
    
    /// 默认为true，如果设置为false，选择器将不会自动dismiss
    public var autoDismiss = true
    
    /// 默认828像素宽
    public var photoWidth: CGFloat = 828
    
    /// 取图片超过15秒还没有成功时，会自动dis missHUD
    public var timeout:Int = 15
    
    /// collection list 一行显示的个数(2 <= columnNumber <= 6)，默认为4
    public var  columnNumber:Int = 4 {
        didSet {
            if columnNumber <= 2 {
                columnNumber = 2
            } else if columnNumber >= 6 {
                columnNumber = 6
            }
        }
    }
    
    /// 在单选模式
    public var showSelectBtn = true {
        didSet {
            // 多选模式下，不允许showSelectBtn为false
            if !showSelectBtn && maxImagesCount > 1 {
                showSelectBtn = true
            }
        }
    }
    
    
    public var pushPicturePickerVc = true
    
}

public struct Configuration {
    
    public static let ScreenWinth = UIScreen.main.bounds.size.width
    public static let ScreenHeight = UIScreen.main.bounds.size.height
    public static let NavBarHeight = CGFloat(64)
    
    public static let LKScreenScale: CGFloat = {
        var scale:CGFloat = 2.0
        if UIScreen.main.bounds.size.width > 700 {
            scale = 1.5
        }
        return scale
    }()
    
    public static let LKScreenWidth: CGFloat = {
        let width = UIScreen.main.bounds.size.width
        return width
    }()
    
    internal static let photoPreviewMaxWidth:CGFloat = 600
    
    
    //MARK: Colors
    
    public static var navBarBackgroundColor = UIColor(red: 34/255.0, green: 34/255.0, blue: 34/255.0, alpha: 1)
    public static var buttonBackgroundColorNormal = UIColor(red: 83/255.0, green: 179/255.0, blue: 17/255.0, alpha: 1)
    public static var bottomBarBackgrounddColor = UIColor(red: 253/255.0, green: 253/255.0, blue: 253/255.0, alpha: 1)
    public static var okButtonTitleColorNormal = UIColor(red: 83/255.0, green: 179/255.0, blue: 17/255.0, alpha: 1.0)
    public static var okButtonTitleColorDisabled = UIColor(red: 83/255.0, green: 179/255.0, blue: 17/255.0, alpha: 0.5)
    public static var previewBarBackgroundColor = UIColor(red: 34/255.0, green: 34/255.0, blue: 34/255.0, alpha: 0.7)
    
    // MARK: Fonts
    public static var bigFont = UIFont.systemFont(ofSize: 16)
    public static var middleFont = UIFont.systemFont(ofSize: 14)
    public static var smallFont = UIFont.systemFont(ofSize: 12)
    
    // MARK: Image
    
    public static var photoOriginDefImageName = "photo_original_def"
    public static var photoOriginSelImageName = "photo_original_sel"
    public static var photoNumberIconImageName = "preview_number_icon"
    public static var previewNavBarBackImageName = "navi_back"
    public static var photoDefImageName = "photo_photoPickerVc_def"
    public static var photoSelImageName = "photo_sel_photoPickerVc"
    public static var photoAssetCameraName = "picture"
    public static var videoSendIconName = "VideoSendIcon"
}

    //MARK: - extension

internal extension String {
    var toFloat: Float {
        let numberFormatter = NumberFormatter()
        return numberFormatter.number(from: self)?.floatValue ?? 0
    }
    
    var toDouble: Double {
        let numberFormatter = NumberFormatter()
        return numberFormatter.number(from: self)?.doubleValue ?? 0
    }
    
    var toInt: Int {
        let numberFormatter = NumberFormatter()
        return numberFormatter.number(from: self)?.intValue ?? 0
    }
}

internal extension UIView {
    
    var lk_left: CGFloat{
        return frame.origin.x
    }
    
    func setLk_left(_ x: CGFloat) -> Void{
        var rect = frame
        rect.origin.x = x;
        frame = rect
    }
    
    var lk_top: CGFloat {
        return frame.origin.y
    }
    
    func setLk_top(_ y: CGFloat) -> Void {
        var rect = frame
        rect.origin.y = y
        frame = rect
    }
    
    var lk_right: CGFloat {
        return frame.origin.x + frame.size.width
    }
    
    func setLk_right(_ right: CGFloat) -> Void {
        var rect = frame
        rect.origin.x = right - rect.size.width
        frame = rect
    }
    
    var  lk_bottom: CGFloat {
        return frame.origin.y + frame.size.height
    }
    
    func setLk_bottom(_ bottom: CGFloat) -> Void {
        var rect = frame
        rect.origin.y = bottom - rect.size.height
        frame = rect
    }
    
    var lk_width:CGFloat {
        return frame.size.width
    }
    
    func setLk_width(_ width: CGFloat) -> Void {
        var rect = frame
        rect.size.width = width
        frame = rect
    }
    
    var lk_height: CGFloat {
        return frame.size.height
    }
    
    func setLk_height(_ height: CGFloat) -> Void {
        var rect = frame
        rect.size.height = height
        frame = rect
    }
    
    var lk_centerX: CGFloat {
        return center.x
    }
    
    func setLk_centerX(_ centerX: CGFloat) -> Void {
        center = CGPoint(x: centerX, y: center.y)
    }
    
    var lk_centerY: CGFloat{
        return center.y
    }
    
    func setLk_centerY(_ centerY: CGFloat) -> Void {
        center = CGPoint(x: center.x, y: centerY)
    }
    
    var lk_origin: CGPoint {
        return frame.origin
    }
    
    func setLk_origin(_ origin: CGPoint) -> Void {
        var rect = frame
        rect.origin = origin
        frame = rect
    }
    
    var lk_size: CGSize {
        return frame.size
    }
    
    func setLk_size(_ size: CGSize) -> Void {
        var rect = frame
        rect.size = size
        frame = rect
    }
    
    class func showOscillatoryAnimationWithLayer(layer:CALayer, type:LKOscillatoryAnimationType) {
        let scale1 = type == .bigger ? 1.15 : 0.5
        let scale2 = type == .bigger ? 0.92 : 1.15
        
        UIView.animate(withDuration: 0.15, delay: 0, options: .beginFromCurrentState, animations: { 
            layer.setValue(scale1, forKeyPath: "transform.scale")
        }) { (finished) in
            UIView.animate(withDuration: 0.15, delay: 0, options: [.beginFromCurrentState,.curveEaseOut], animations: { 
                 layer.setValue(scale2, forKeyPath: "transform.scale")
            }, completion: { (finished) in
                UIView.animate(withDuration: 0.1, delay: 0, options: [.beginFromCurrentState,.curveEaseOut], animations: { 
                    layer.setValue(1.0, forKeyPath: "transform.scale")
                }, completion: nil)
            })
        }
    
    }
    
}

internal extension UIImage {
    
    class func imageNamedFromMyBundle(name:String) -> UIImage? {
        var image = UIImage(named: "LKImagePicker.bundle/".appending(name))
        
        if image == nil {
            image = UIImage(named: "Frameworks/LKImagePicker.framework/LKImagePicker.bundle/".appending(name))
            if image == nil {
                image = UIImage(named: name)
            }
        }
        
        return image
    }
}

private var lkBundle: Bundle? = nil
private var localizedBundle: Bundle? = nil

internal extension Bundle {
    
    static var lk_imagePickerBundle:Bundle {
        if lkBundle == nil {
            var path = Bundle.main.path(forResource: "LKImagePicker", ofType: "bundle")
            if path == nil {
                path = Bundle.main.path(forResource: "LKImagePicker", ofType: "bundle", inDirectory: "Frameworks/LKImagePicker.framework/")
            }
            
            lkBundle = Bundle(path: path!)
        }
       return lkBundle!
    }
    
    class func lk_localizedString(key: String, _ value: String = "") -> String {

        if localizedBundle == nil {
            var language = NSLocale.preferredLanguages.first
            
            if let tempLanguage = language {
                if tempLanguage.range(of: "zh-Hans") != nil {
                    language = "zh-Hans"
                } else {
                    language = "en"
                }
            }

            localizedBundle = Bundle(path: Bundle.lk_imagePickerBundle.path(forResource: language, ofType: "lproj")!)
        }
        
        if let bundle = localizedBundle {
            return bundle.localizedString(forKey: key, value: value, table: nil)
        }
        
        return ""
    }
    
}



