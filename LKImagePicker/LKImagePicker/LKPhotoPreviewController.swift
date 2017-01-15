//
//  LKPhotoPreviewController.swift
//  LKImagePicker
//
//  Created by Mkil on 21/12/2016.
//  Copyright © 2016 黎宁康. All rights reserved.
//

import UIKit

public class LKPhotoPreviewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource{

    var models:[LKAssetModel]?
    var currentIndex:Int = 0
    
    var isHideNaviBar = false
    var isSelectOriginalPhoto = false
    var backButtonClickBlock:((Bool) -> Void)?
    var doneButtonClickBlock:((Bool) -> Void)?
    
    lazy var collectionView:UICollectionView = { [unowned self] in
        let lkImagePickerVC = self.navigationController as! LKImagePickerController
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: self.view.lk_width + 20, height: self.view.lk_height)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        let collectionView = UICollectionView(frame: CGRect(x: -10, y: 0, width: self.view.lk_width + 20, height: self.view.lk_height), collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.black
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        collectionView.scrollsToTop = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentOffset = CGPoint(x: 0, y: 0)
        collectionView.contentSize = CGSize(width: CGFloat(self.models!.count) * (self.view.lk_width + 20), height: 0)
        collectionView.register(LKPhotoPreviewCell.self, forCellWithReuseIdentifier: "LKPhotoPreviewCell")
        
       return collectionView
    }()

    /// configCustomNaviBar
    lazy var navibar:UIView = { [unowned self] in
        let navibar = UIView()
        navibar.frame = CGRect(x: 0, y: 0, width: self.view.lk_width, height: 64)
        navibar.backgroundColor = Configuration.previewBarBackgroundColor
        
        let backButton = UIButton(frame: CGRect(x: 10, y: 10, width: 44, height: 44))
        backButton.setImage(UIImage.imageNamedFromMyBundle(name: Configuration.previewNavBarBackImageName), for: .normal)
        backButton.setTitleColor(UIColor.white, for: .normal)
        backButton.addTarget(self, action: #selector(backButtonClick), for: .touchUpInside)
        
        navibar.addSubview(backButton)
        return navibar
    }()
    
    lazy var selectButton: UIButton = { [unowned self] in
        let selectButton = UIButton()
        selectButton.frame = CGRect(x: self.view.lk_width - 54, y: 10, width: 42, height: 42)
        selectButton.setImage(UIImage.imageNamedFromMyBundle(name: Configuration.photoDefImageName), for: .normal)
        selectButton.setImage(UIImage.imageNamedFromMyBundle(name: Configuration.photoSelImageName), for: .selected)
        selectButton.addTarget(self, action: #selector(selectButtonClick(_:)), for: .touchUpInside)
        return selectButton
    }()
    
    /// BottomBar
    lazy var bottomBar: UIView = { [unowned self] in
        let bottomView = UIView()
        bottomView.frame = CGRect(x: 0, y: self.view.lk_height - 44, width: self.view.lk_width, height: 44)
        bottomView.backgroundColor = Configuration.previewBarBackgroundColor
        return bottomView
    }()
    
    lazy var originalPhotoButton:UIButton = { [unowned self] in
        
        var fullImageWidth = Bundle.lk_localizedString(key: "Full image").boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), options: .usesFontLeading, attributes: [NSFontAttributeName:Configuration.bigFont], context: nil).size.width
        
        let originalPhotoBut = UIButton(type: .custom)
        originalPhotoBut.frame = CGRect(x: 0, y: 0, width: fullImageWidth + 56, height: 44)
        originalPhotoBut.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0)
        originalPhotoBut.addTarget(self, action: #selector(originalPhotoButtonClick), for: .touchUpInside)
        originalPhotoBut.titleLabel?.font = Configuration.bigFont
        originalPhotoBut.setTitle(Bundle.lk_localizedString(key: "Full image"), for: .normal)
        originalPhotoBut.setTitle(Bundle.lk_localizedString(key: "Full image"), for: .selected)
        originalPhotoBut.setTitleColor(UIColor.lightGray, for: .normal)
        originalPhotoBut.setTitleColor(UIColor.white, for: .selected)
        originalPhotoBut.setImage(UIImage.imageNamedFromMyBundle(name: Configuration.photoOriginDefImageName), for: .normal)
        originalPhotoBut.setImage(UIImage.imageNamedFromMyBundle(name: Configuration.photoOriginSelImageName), for: .selected)
        return originalPhotoBut
    }()
    
    lazy var originalPhotoLable:UILabel = {
        var fullImageWidth = Bundle.lk_localizedString(key: "Full image").boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), options: .usesFontLeading, attributes: [NSFontAttributeName:Configuration.bigFont], context: nil).size.width
        
        let originalPhotoLable = UILabel()
        originalPhotoLable.frame = CGRect(x: fullImageWidth + 42, y: 0, width: 80, height: 44)
        originalPhotoLable.textAlignment = .left
        originalPhotoLable.font = Configuration.bigFont
        originalPhotoLable.textColor = UIColor.white
        
        return originalPhotoLable
    }()
    
    lazy var doneButton:UIButton = { [unowned self] in
        let lkImagePickerVC = self.navigationController as! LKImagePickerController
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: self.view.lk_width - 44 - 12, y: 0, width: 44, height: 44)
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
        imageView.frame = CGRect(x: self.view.lk_width - 56 - 28, y: 7, width: 30, height: 30)
        imageView.backgroundColor = UIColor.clear
        imageView.isHidden = lkImagePickerVC.selectedModels.count <= 0
        return imageView
    }()
    
    lazy var numberLable:UILabel = { [unowned self] in
        let lkImagePickerVC = self.navigationController as! LKImagePickerController
        let lable = UILabel()
        lable.frame = CGRect(x: self.view.lk_width - 56 - 28, y: 7, width: 30, height: 30)
        lable.font = Configuration.middleFont
        lable.textColor = UIColor.white
        lable.textAlignment = .center
        lable.backgroundColor = UIColor.clear
        lable.isHidden = lkImagePickerVC.selectedModels.count <= 0
        return lable
    }()


    override public func viewDidLoad() {
        super.viewDidLoad()
        
        checkSelectedModels()
        initSubViews()
        view.clipsToBounds = true
        refreshToolBarStatus()
        // Do any additional setup after loading the view.
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        if currentIndex > 0 {
            collectionView.contentOffset = CGPoint(x: (view.lk_width + 20) * CGFloat(currentIndex), y: 0)
            refreshToolBarStatus()
        }
        
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    override public var prefersStatusBarHidden: Bool { return true }
    
    
    func initSubViews() -> Void {
        let lkImagePickerVC = self.navigationController as! LKImagePickerController
        
        [collectionView,navibar,bottomBar].forEach {
            view.addSubview($0)
        }
        navibar.addSubview(selectButton)
        [originalPhotoButton,doneButton,numberImageView,numberLable].forEach {
            bottomBar.addSubview($0)
        }
        originalPhotoButton.addSubview(originalPhotoLable)
        originalPhotoButton.isHidden = !lkImagePickerVC.imageConfig.allowPickingOriginImage
    }
    
    
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - UICollectionViewDelegate UICollectionViewDataSource
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let models = models {
            return models.count
        }
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"LKPhotoPreviewCell", for: indexPath) as! LKPhotoPreviewCell
        
        if let lkImagePickerVC = self.navigationController as? LKImagePickerController {
            cell.shouldFixOrientation = lkImagePickerVC.imageConfig.shouldFixOrientation
        }
        cell.model = models![indexPath.row]
       
        cell.singleTapGestureBlock = { [weak self,weak bottomBar,weak navibar] in
            if let weakSelf = self {
                weakSelf.isHideNaviBar = !weakSelf.isHideNaviBar
                bottomBar!.isHidden = weakSelf.isHideNaviBar
                navibar!.isHidden = weakSelf.isHideNaviBar
            }
        }
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if cell is LKPhotoPreviewCell {
            let lkCell = cell as! LKPhotoPreviewCell
            lkCell.recoverSubviews()
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if cell is LKPhotoPreviewCell {
            let lkCell = cell as! LKPhotoPreviewCell
            lkCell.recoverSubviews()
        }
    }
    
    func checkSelectedModels() {
        let lkImagePickerVC = self.navigationController as! LKImagePickerController
        if lkImagePickerVC.selectedModels.count > 0 ,let models = models {
            for model in models {
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
    
    //MARK: - UIScrollViewDelegate
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var offSetWidth:CGFloat = scrollView.contentOffset.x
        offSetWidth = offSetWidth + (self.view.lk_width + 20)*0.5
        let currentIndex:Int = Int(offSetWidth / (self.view.lk_width + 20))
        
        if let models = models {
            if currentIndex < models.count && self.currentIndex != currentIndex {
                self.currentIndex = currentIndex
                refreshToolBarStatus()
            }
        }
        
    }
    
    func refreshToolBarStatus() {
        let lkImagePickerVC = navigationController as! LKImagePickerController
        
        if let models = models {
            let model = models[currentIndex]
            selectButton.isSelected = model.isSelected
        }
        doneButton.isEnabled = lkImagePickerVC.selectedModels.count > 0
        numberLable.isHidden = lkImagePickerVC.selectedModels.count <= 0
        numberImageView.isHidden = lkImagePickerVC.selectedModels.count <= 0
        numberLable.text = String(format: "%ld", lkImagePickerVC.selectedModels.count)
        originalPhotoButton.isSelected = isSelectOriginalPhoto && lkImagePickerVC.selectedModels.count > 0 ? true : false
        
        if originalPhotoButton.isSelected {
            getSelectedPhotoBytes()
        } else {
            originalPhotoLable.text = ""
        }
    }
    
    //MARK: - Click Event

    func backButtonClick() {
        backButtonClickBlock?(isSelectOriginalPhoto)
        navigationController!.popViewController(animated: true)
    }
    
    func originalPhotoButtonClick() {
        originalPhotoButton.isSelected = !originalPhotoButton.isSelected
        isSelectOriginalPhoto = originalPhotoButton.isSelected
        originalPhotoLable.isHidden = !originalPhotoButton.isSelected
        if isSelectOriginalPhoto { getSelectedPhotoBytes() }
    }
    
    func doneButtonClick() {
        doneButtonClickBlock?(isSelectOriginalPhoto)
    }
    
    func getSelectedPhotoBytes() {
        let lkImagePickerVC = navigationController as! LKImagePickerController
        AssetManager.getPhotosBytesWithArray(lkImagePickerVC.selectedModels) {
            (totalBytes) in
            self.originalPhotoLable.text = "(\(totalBytes))"
        }
    }
    
    func selectButtonClick(_ selectButton:UIButton) {

        let lkImagePickerVC = navigationController as! LKImagePickerController
        let model = models![currentIndex]
        // 选择
        if !selectButton.isSelected {
            
            // 2. select:check if over the maxImagesCount / 选择照片,检查是否超过了最大个数的限制
            if lkImagePickerVC.selectedModels.count < lkImagePickerVC.imageConfig.maxImagesCount {
                model.isSelected = true
                lkImagePickerVC.selectedModels.append(model)
                refreshToolBarStatus()
                UIView.showOscillatoryAnimationWithLayer(layer: numberLable.layer, type: .smaller)
            } else {
                let title = String(format: Bundle.lk_localizedString(key: "Select a maximum of %zd photos"), lkImagePickerVC.imageConfig.maxImagesCount)
                lkImagePickerVC.showAlertWithTitle(title: title)
            }
            
        } else {
            model.isSelected = false
            for index in 0..<lkImagePickerVC.selectedModels.count {
                let selectedModel = lkImagePickerVC.selectedModels[index]
                if model.asset.localIdentifier == selectedModel.asset.localIdentifier {
                    lkImagePickerVC.selectedModels.remove(at: index)
                    break
                }
            }
            refreshToolBarStatus()
            UIView.showOscillatoryAnimationWithLayer(layer: numberLable.layer, type: .smaller)
        }
        
        if selectButton.isSelected {
            UIView.showOscillatoryAnimationWithLayer(layer: selectButton.layer, type: .bigger)
        }
    }
    
}
