//
//  LKPhotoPickerController.swift
//  LKImagePicker
//
//  Created by Mkil on 20/12/2016.
//  Copyright © 2016 黎宁康. All rights reserved.
//

import UIKit
import Photos

public class LKPhotoPickerController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    var showTakePhotoBtn:Bool = true
    var isSelectOriginalPhoto = false
    var model:LKAlbumModel?
    
    lazy var collectionView:UICollectionView = { [unowned self] in
        let lkImagePickerVC = self.navigationController as! LKImagePickerController
        
        let layout = UICollectionViewFlowLayout()
        let margin:CGFloat = 5
        let itemWH:CGFloat = (self.view.lk_width - CGFloat(lkImagePickerVC.imageConfig.columnNumber + 1) * margin) / CGFloat(lkImagePickerVC.imageConfig.columnNumber)
        layout.itemSize = CGSize(width: itemWH, height: itemWH)
        layout.minimumInteritemSpacing = margin
        layout.minimumLineSpacing = margin
        
        let top:CGFloat = 44 + 20
        let collectionViewHeight = lkImagePickerVC.imageConfig.maxImagesCount > 1 ? self.view.lk_height - 50 - top : self.view.lk_height - top
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: top, width: self.view.lk_width, height: collectionViewHeight), collectionViewLayout: layout)

        collectionView.backgroundColor = UIColor.white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.alwaysBounceHorizontal = false
        collectionView.contentInset = UIEdgeInsetsMake(margin, margin, margin, margin)
        
        if let model = self.model {
            if self.showTakePhotoBtn && lkImagePickerVC.imageConfig.allowTakePicture {
                collectionView.contentSize = CGSize(width: self.view.lk_width, height: (CGFloat(model.count + lkImagePickerVC.imageConfig.columnNumber) / CGFloat(lkImagePickerVC.imageConfig.columnNumber)) * self.view.lk_width)
            } else {
                collectionView.contentSize = CGSize(width: self.view.lk_width, height: (CGFloat(model.count + lkImagePickerVC.imageConfig.columnNumber - 1) / CGFloat(lkImagePickerVC.imageConfig.columnNumber)) * self.view.lk_width)
            }
        }
        collectionView.register(LKListCell.self, forCellWithReuseIdentifier: "LKListCell")
        collectionView.register(LKAssetCameraCell.self, forCellWithReuseIdentifier: "LKAssetCameraCell")
        return collectionView
    }()
    
    
    lazy var imagePickerVc:UIImagePickerController = { [unowned self] in
        
        let imagePickerVc = UIImagePickerController()
        imagePickerVc.delegate = self
        
        return imagePickerVc
    }()
    
    /// BottomBar
    lazy var bottomBar: UIView = { [unowned self] in
        let bottomView = UIView()
        bottomView.frame = CGRect(x: 0, y: self.view.lk_height - 50, width: self.view.lk_width, height: 50)
        bottomView.backgroundColor = Configuration.bottomBarBackgrounddColor
        
        let lineView = UIView()
        lineView.frame = CGRect(x: 0, y: 0, width: self.view.lk_width, height: 1)
        let rgb:CGFloat = 222 / 255.0
        lineView.backgroundColor = UIColor(red: rgb, green: rgb, blue: rgb, alpha: 1.0)
        bottomView.addSubview(lineView)
        return bottomView
    }()
    
    lazy var previewButton:UIButton = { [unowned self] in
        let lkImagePickerVC = self.navigationController as! LKImagePickerController
        
        var previewWidth = Bundle.lk_localizedString(key: "Preview").boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), options: .usesFontLeading, attributes: [NSFontAttributeName:Configuration.bigFont], context: nil).size.width + 2
        if !lkImagePickerVC.imageConfig.allowPreview {
            previewWidth = 0.0
        }
        
        let previewBut = UIButton(type: .custom)
        previewBut.frame = CGRect(x: 10, y: 3, width: previewWidth, height: 44)
        previewBut.titleLabel?.font = Configuration.bigFont
        previewBut.setTitle(Bundle.lk_localizedString(key: "Preview"), for: .normal)
        previewBut.setTitle(Bundle.lk_localizedString(key: "Preview"), for: .disabled)
        previewBut.setTitleColor(UIColor.black, for: .normal)
        previewBut.setTitleColor(UIColor.lightGray, for: .disabled)
        previewBut.isEnabled = lkImagePickerVC.selectedModels.count > 0
        previewBut.addTarget(self, action: #selector(previewButtonClick), for: .touchUpInside)
        return previewBut
    }()
    
    lazy var originalPhotoButton:UIButton = { [unowned self] in
        
        var fullImageWidth = Bundle.lk_localizedString(key: "Full image").boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), options: .usesFontLeading, attributes: [NSFontAttributeName:Configuration.bigFont], context: nil).size.width
        
        let originalPhotoBut = UIButton(type: .custom)
        originalPhotoBut.frame = CGRect(x: self.previewButton.frame.maxX, y: self.view.lk_height - 50, width: fullImageWidth + 56, height: 50)
        originalPhotoBut.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0)
        originalPhotoBut.addTarget(self, action: #selector(originalPhotoButtonClick), for: .touchUpInside)
        originalPhotoBut.titleLabel?.font = Configuration.bigFont
        originalPhotoBut.setTitle(Bundle.lk_localizedString(key: "Full image"), for: .normal)
        originalPhotoBut.setTitle(Bundle.lk_localizedString(key: "Full image"), for: .selected)
        originalPhotoBut.setTitleColor(UIColor.lightGray, for: .normal)
        originalPhotoBut.setTitleColor(UIColor.black, for: .selected)
        originalPhotoBut.setImage(UIImage.imageNamedFromMyBundle(name: Configuration.photoOriginDefImageName), for: .normal)
        originalPhotoBut.setImage(UIImage.imageNamedFromMyBundle(name: Configuration.photoOriginSelImageName), for: .selected)
        return originalPhotoBut
    }()
    
    lazy var originalPhotoLable:UILabel = {
        var fullImageWidth = Bundle.lk_localizedString(key: "Full image").boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), options: .usesFontLeading, attributes: [NSFontAttributeName:Configuration.bigFont], context: nil).size.width
        
        let originalPhotoLable = UILabel()
        originalPhotoLable.frame = CGRect(x: fullImageWidth + 46, y: 0, width: 80, height: 50)
        originalPhotoLable.textAlignment = .left
        originalPhotoLable.font = Configuration.bigFont
        originalPhotoLable.textColor = UIColor.black
        
        return originalPhotoLable
    }()
    
    lazy var doneButton:UIButton = { [unowned self] in
        let lkImagePickerVC = self.navigationController as! LKImagePickerController
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: self.view.lk_width - 44 - 12, y: 3, width: 44, height: 44)
        button.titleLabel?.font = Configuration.bigFont
        button.addTarget(self, action: #selector(doneButtonClick), for: .touchUpInside)
        button.setTitle(Bundle.lk_localizedString(key: "Done"), for: .normal)
        button.setTitle(Bundle.lk_localizedString(key: "Done"), for: .disabled)
        button.setTitleColor(Configuration.okButtonTitleColorNormal, for: .normal)
        button.setTitleColor(Configuration.okButtonTitleColorDisabled, for: .disabled)
        button.isEnabled = lkImagePickerVC.selectedModels.count > 0
        return button
    }()
    
    lazy var numberImageView:UIImageView = { [unowned self] in
        let lkImagePickerVC = self.navigationController as! LKImagePickerController
        let imageView = UIImageView(image: UIImage.imageNamedFromMyBundle(name: Configuration.photoNumberIconImageName))
        imageView.frame = CGRect(x: self.view.lk_width - 56 - 28, y: 10, width: 30, height: 30)
        imageView.backgroundColor = UIColor.clear
        imageView.isHidden = lkImagePickerVC.selectedModels.count <= 0
        return imageView
    }()
    
    lazy var numberLable:UILabel = { [unowned self] in
        let lkImagePickerVC = self.navigationController as! LKImagePickerController
        let lable = UILabel()
        lable.frame = CGRect(x: self.view.lk_width - 56 - 28, y: 10, width: 30, height: 30)
        lable.font = Configuration.bigFont
        lable.textColor = UIColor.white
        lable.textAlignment = .center
        lable.text = lkImagePickerVC.selectedModels.count > 0 ? String(format: "%ld", lkImagePickerVC.selectedModels.count) : ""
        lable.isHidden = lkImagePickerVC.selectedModels.count <= 0
        lable.backgroundColor = UIColor.clear
        return lable
    }()
    
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        view.backgroundColor = UIColor.white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: Bundle.lk_localizedString(key: "Cancel"), style: .plain, target: self, action: #selector(cancel))
        
        if let model = model {
            navigationItem.title = model.name
            self.showTakePhotoBtn = AssetManager.isPhotoAlbum(model.name)
            initSubViews()
        } else {
            let lkImagePickerVC = self.navigationController as! LKImagePickerController
            let imageConfig = lkImagePickerVC.imageConfig
            AssetManager.getImageAlbum(imageConfig.allowPickingVideo, imageConfig.allowPickingImage, imageConfig.sortAscendingByModificationDate) { (model) in
                self.model = model
                self.initSubViews()
            }
        }
    }

    func initSubViews() -> Void {
        let lkImagePickerVC = self.navigationController as! LKImagePickerController
        
        checkSelectedModels()
        scrollCollectionViewToBottom()
        
        view.addSubview(collectionView)
        if lkImagePickerVC.imageConfig.showSelectBtn {
            [bottomBar,originalPhotoButton].forEach {
                view.addSubview($0)
            }
            [previewButton,doneButton,numberImageView,numberLable].forEach {
                bottomBar.addSubview($0)
            }
            originalPhotoButton.addSubview(originalPhotoLable)
            originalPhotoButton.isHidden = !lkImagePickerVC.imageConfig.allowPickingImage
        }        
    }
    
    //MARK: - UICollectionViewDelegate UICollectionViewDataSource
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
        if let model = model {
            if showTakePhotoBtn {
                let lkImagePickerVC = self.navigationController as! LKImagePickerController
                if lkImagePickerVC.imageConfig.allowPickingImage && lkImagePickerVC.imageConfig.allowTakePicture {
                    return model.count + 1
                }
            }
        }
       
        return (model != nil) ? model!.count: 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let lkImagePickerVC = self.navigationController as? LKImagePickerController
        
        if let model = model, showTakePhotoBtn , let lkImagePickerVC = lkImagePickerVC {
            if lkImagePickerVC.imageConfig.sortAscendingByModificationDate && indexPath.row >= model.count || !lkImagePickerVC.imageConfig.sortAscendingByModificationDate && indexPath.row == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LKAssetCameraCell", for: indexPath) as! LKAssetCameraCell
                
                cell.imageView.image = UIImage.imageNamedFromMyBundle(name: Configuration.photoAssetCameraName)
                return cell
            }
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"LKListCell", for: indexPath) as! LKListCell
        
        if let lkImagePickerVC = self.navigationController as? LKImagePickerController {
            cell.shouldFixOrientation = lkImagePickerVC.imageConfig.shouldFixOrientation
        }
        if let model = model , let lkImagePickerVC = lkImagePickerVC {
            if !lkImagePickerVC.imageConfig.sortAscendingByModificationDate && showTakePhotoBtn {
                cell.model = model.models[indexPath.row - 1]
            } else {
                cell.model = model.models[indexPath.row]
            }
            
        }
        cell.didSelectPhotoBlock = { [weak self,weak cell] (isSelected) -> Void  in
            if let weakSelf = self,let weakCell = cell {
                let lkImagePickerVC = weakSelf.navigationController as! LKImagePickerController
                // 选择
                if isSelected {
                    // 2. select:check if over the maxImagesCount / 选择照片,检查是否超过了最大个数的限制
                    if lkImagePickerVC.selectedModels.count < lkImagePickerVC.imageConfig.maxImagesCount {
                        weakCell.model!.isSelected = true
                        lkImagePickerVC.selectedModels.append(weakCell.model!)
                    } else {
                        let title = String(format: Bundle.lk_localizedString(key: "Select a maximum of %zd photos"), lkImagePickerVC.imageConfig.maxImagesCount)
                        lkImagePickerVC.showAlertWithTitle(title: title)
                        weakCell.selectPhotoButton.isSelected = false
                    }
                } else {
                    weakCell.model!.isSelected = false
                    for index in 0..<lkImagePickerVC.selectedModels.count {
                        let selectedModel = lkImagePickerVC.selectedModels[index]
                        if weakCell.model!.asset.localIdentifier == selectedModel.asset.localIdentifier {
                            lkImagePickerVC.selectedModels.remove(at: index)
                            break
                        }
                    }
                }
                weakSelf.refreshBottomToolBarStatus()
            }
        }
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let model = model, showTakePhotoBtn {
            let lkImagePickerVC = navigationController as! LKImagePickerController
            if lkImagePickerVC.imageConfig.sortAscendingByModificationDate && indexPath.row >= model.count || !lkImagePickerVC.imageConfig.sortAscendingByModificationDate && indexPath.row == 0 {
                takePhoto()
                return
            }
        }
        
        if let model = model {
            
            // TODO: 待添加视频播放功能
            if model.models[indexPath.row].type == .video {
                let lkImagePickerVC = navigationController as! LKImagePickerController
                lkImagePickerVC.showAlertWithTitle(title: "暂不支持视频播放")
                return
            }
            
            let photoPickerVC = LKPhotoPreviewController()
            photoPickerVC.currentIndex = indexPath.row
            photoPickerVC.models = model.models
            pushPhotoPrevireViewController(photoPickerVC)
        }
    }
    
    
    func refreshBottomToolBarStatus() {
        let lkImagePickerVC = self.navigationController as! LKImagePickerController
        doneButton.isEnabled = lkImagePickerVC.selectedModels.count > 0
        previewButton.isEnabled = lkImagePickerVC.selectedModels.count > 0
        numberLable.isHidden = lkImagePickerVC.selectedModels.count <= 0
        numberImageView.isHidden = lkImagePickerVC.selectedModels.count <= 0
        numberLable.text = String(format: "%ld", lkImagePickerVC.selectedModels.count)
        UIView.showOscillatoryAnimationWithLayer(layer: numberLable.layer, type: .smaller)
        
        originalPhotoButton.isSelected = isSelectOriginalPhoto && lkImagePickerVC.selectedModels.count > 0 ? true : false
        
        if originalPhotoButton.isSelected {
            getSelectedPhotoBytes()
        } else {
            originalPhotoLable.text = ""
        }
    }
    
    func pushPhotoPrevireViewController(_ photoPreviewVC:LKPhotoPreviewController) {
        photoPreviewVC.isSelectOriginalPhoto = isSelectOriginalPhoto
        photoPreviewVC.backButtonClickBlock = { [weak self] (isSelectOriginalPhoto) in
            if let weakSelf = self {
                weakSelf.isSelectOriginalPhoto = isSelectOriginalPhoto
                weakSelf.collectionView.reloadData()
                weakSelf.refreshBottomToolBarStatus()
            }
        }
        
        photoPreviewVC.doneButtonClickBlock = { [weak self] (isSelectOriginalPhoto) in
            if let weakSelf = self {
                weakSelf.isSelectOriginalPhoto = isSelectOriginalPhoto
                weakSelf.doneButtonClick()
            }
        }
        
        navigationController?.pushViewController(photoPreviewVC, animated: true)
    }
    
    func checkSelectedModels() {
        let lkImagePickerVC = navigationController as! LKImagePickerController
        if lkImagePickerVC.selectedModels.count > 0 {
            for model in model!.models {
                model.isSelected = false
                
                for index in 0..<lkImagePickerVC.selectedModels.count {
                    let selectmodel = lkImagePickerVC.selectedModels[index]
                    if model.asset == selectmodel.asset {
                        model.isSelected = true
                        lkImagePickerVC.selectedModels.replaceSubrange(Range(index..<index + 1), with: [model])
                    }
                }
            }
        }
    }
    
    //MARK: - Click Event
    func previewButtonClick() {
        let lkImagePickerVC = navigationController as! LKImagePickerController
        let photoPickerVC = LKPhotoPreviewController()
        photoPickerVC.models = lkImagePickerVC.selectedModels
        pushPhotoPrevireViewController(photoPickerVC)
    }
    
    func originalPhotoButtonClick() {
        let lkImagePickerVC = navigationController as! LKImagePickerController
        if lkImagePickerVC.selectedModels.count <= 0 { return }
        originalPhotoButton.isSelected = !originalPhotoButton.isSelected
        isSelectOriginalPhoto = originalPhotoButton.isSelected
        originalPhotoLable.isHidden = !originalPhotoButton.isSelected
        if isSelectOriginalPhoto { getSelectedPhotoBytes() }
    }
    
    func doneButtonClick() {
        let lkImagePickerVC = navigationController as! LKImagePickerController
        
        /// 判断是否满足最小必选张数的限制
        if lkImagePickerVC.selectedModels.count < lkImagePickerVC.imageConfig.minImagesCount {
            let title = String(format: Bundle.lk_localizedString(key: "Select a minimum of %zd photos"), lkImagePickerVC.imageConfig.minImagesCount)
            lkImagePickerVC.showAlertWithTitle(title: title)
            return
        }
        
        lkImagePickerVC.showProgressHUD()
        
        var photos = [Any](repeating: 0, count: lkImagePickerVC.selectedModels.count)
        var assets = [Any](repeating: 0, count: lkImagePickerVC.selectedModels.count)
        var infoArr = [Any](repeating: 0, count: lkImagePickerVC.selectedModels.count)
        
        var havenotShowAlert = true
        for index in 0..<lkImagePickerVC.selectedModels.count {
            let model = lkImagePickerVC.selectedModels[index]
            AssetManager.getPhoto(model.asset, true, completion: { (photo, info, isDegraded) in
                if isDegraded { return }
                
                if let image = photo {
                    let scalephoto = self.scaleImage(image: image, size: CGSize(width: lkImagePickerVC.imageConfig.photoWidth, height: lkImagePickerVC.imageConfig.photoWidth * image.size.height / image.size.width))
                    if scalephoto != nil {
                        photos.replaceSubrange(Range(index..<index + 1), with: [scalephoto!])
                    }
                }
                if let info = info {
                    infoArr.replaceSubrange(Range(index..<index + 1), with: [info])
                }
                assets.replaceSubrange(Range(index..<index + 1), with: [model.asset])
                
                for item in photos { if !(item is UIImage) { return } }
                
                self.didGetAllPhotos(photos, assets, infoArr)
                
            }, progressHandler: { (progress, error, stop, info) in
                
                if progress < 1 && havenotShowAlert {
                    lkImagePickerVC.hideProgressHUD()
                    lkImagePickerVC.showAlertWithTitle(title: Bundle.lk_localizedString(key: "Synchronizing photos from iCloud"))
                    havenotShowAlert = false
                    return
                }
                
            }, networkAccessAllowed: true)
        }
    }
    

    func cancel() {
        navigationController?.dismiss(animated: true, completion: nil)
        let imagePickerVc = navigationController as! LKImagePickerController
        imagePickerVc.pickerDelegate?.imagePickerControllerDidCancel?(imagePickerVc)
    }
    
    func didGetAllPhotos(_ photos:[Any], _ assets:[Any], _ infoArr:[Any]) {
        let lkImagePickerVC = navigationController as! LKImagePickerController
        lkImagePickerVC.hideProgressHUD()
        
        if lkImagePickerVC.imageConfig.autoDismiss {
            navigationController?.dismiss(animated: true) {
                self.callDelegateMethodWithPhotos(photos as! [UIImage], assets, infoArr as! [[AnyHashable : Any]])
            }
        } else {
            self.callDelegateMethodWithPhotos(photos as! [UIImage], assets, infoArr as! [[AnyHashable : Any]])
        }
    }
    
    func callDelegateMethodWithPhotos(_ photos:[UIImage], _ assets:[Any], _ infoArr:[[AnyHashable : Any]]) {
        let lkImagePickerVC = navigationController as! LKImagePickerController
        lkImagePickerVC.pickerDelegate?.imagePickerControllerDidFinish?(lkImagePickerVC, photos, assets, isSelectOriginalPhoto)
        lkImagePickerVC.didFinishPickingPhotosHandle?(photos, assets, isSelectOriginalPhoto)
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        let type = info[UIImagePickerControllerMediaType] as! String
        if type == "public.image" {
            let lkImagePickerVC = navigationController as! LKImagePickerController
            lkImagePickerVC.showProgressHUD()
            
            let image = info[UIImagePickerControllerOriginalImage] as? UIImage
            if let image = image {
                AssetManager.savePhoto(image) { (error) in
                    lkImagePickerVC.hideProgressHUD()
                    
                    if error == nil {
                        self.reloadPhotoArray()
                    }
                }
            }
        }
        
    }
    
    func reloadPhotoArray() {
        let lkImagePickerVC = navigationController as! LKImagePickerController
        AssetManager.getImageAlbum(lkImagePickerVC.imageConfig.allowPickingVideo, lkImagePickerVC.imageConfig.allowPickingImage, lkImagePickerVC.imageConfig.sortAscendingByModificationDate) { (model) in
            if lkImagePickerVC.imageConfig.sortAscendingByModificationDate {
                let assetModel = model.models.last
                assetModel?.isSelected = true
                if let assetModel = assetModel {
                    self.model?.models.append(assetModel)
                    self.model?.count += 1
                    lkImagePickerVC.selectedModels.append(assetModel)
                }
            } else {
                let assetModel = model.models.first
                assetModel?.isSelected = true
                if let assetModel = assetModel {
                    self.model?.models.insert(assetModel, at: 0)
                    self.model?.count += 1
                    lkImagePickerVC.selectedModels.append(assetModel)
                }
            }
            self.refreshBottomToolBarStatus()
            self.collectionView.reloadData()
        }

    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    //MARK: -  Private Method
    
    func takePhoto() {
        
        let authStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        if authStatus == .restricted || authStatus == .denied {
            var appName = Bundle.main.infoDictionary?["CFBundleDisplayName"]
            if appName == nil { appName = Bundle.main.infoDictionary?["CFBundleName"] }
            
            let message = String(format: Bundle.lk_localizedString(key: "Please allow %@ to access your camera in \"Settings -> Privacy -> Camera\""), appName as! String)
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: Bundle.lk_localizedString(key: "Cancel"), style: .cancel, handler: nil))
            alertController.addAction(UIAlertAction(title: Bundle.lk_localizedString(key: "Setting"), style: .default, handler: { (alertAction) in
                UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
            }))
            self.present(alertController, animated: true, completion: nil)
        } else {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePickerVc.sourceType = .camera
                imagePickerVc.modalPresentationStyle = .currentContext
                present(imagePickerVc, animated: true, completion: nil)
            } else {
                let lkImagePickerVC = navigationController as! LKImagePickerController
                
                lkImagePickerVC.showAlertWithTitle(title: "模拟器中无法打开照相机,请在真机中使用")
            }
        }
    }

    /// 缩放图片
    
    func scaleImage(image: UIImage, size: CGSize) -> UIImage? {
        if image.size.width < size.width { return image }
        UIGraphicsBeginImageContext(size)
        image.draw(in: CGRect(origin: CGPoint.zero, size: size))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    
    func scrollCollectionViewToBottom() {
        let lkImagePickerVC = navigationController as! LKImagePickerController
        if let model = model {
            if lkImagePickerVC.imageConfig.shouldScrollToBottom && model.count > 0 && lkImagePickerVC.imageConfig.sortAscendingByModificationDate {
                var item = model.count - 1
                if showTakePhotoBtn {
                    if lkImagePickerVC.imageConfig.allowPickingImage && lkImagePickerVC.imageConfig.allowTakePicture {
                        item += 1
                    }
                }
                collectionView.scrollToItem(at: IndexPath(item: item, section: 0), at: .bottom, animated: false)
            }
        }
    }

    func getSelectedPhotoBytes() {
        let lkImagePickerVC = navigationController as! LKImagePickerController
        AssetManager.getPhotosBytesWithArray(lkImagePickerVC.selectedModels) {
            (totalBytes) in
            self.originalPhotoLable.text = "(\(totalBytes))"
        }
    }
    
    
}
