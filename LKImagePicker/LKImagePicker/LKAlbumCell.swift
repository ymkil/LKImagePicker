//
//  LKAlbumCell.swift
//  LKImagePicker
//
//  Created by Mkil on 20/12/2016.
//  Copyright © 2016 黎宁康. All rights reserved.
//

import UIKit
import Photos

public class LKAlbumCell: UITableViewCell {

    var model: LKAlbumModel? = nil
    var selectedCount = 0
    let coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.frame = CGRect(x: 10, y: 10, width: 50, height: 50)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var titleLable: UILabel = {[unowned self] in
        let lable = UILabel()
        lable.frame = CGRect(x: 80, y: 0, width: self.lk_width - 70 - 50, height: 70)
        lable.font = UIFont.boldSystemFont(ofSize: 17)
        lable.textColor = UIColor.black
        lable.textAlignment = .left
        return lable
        }()
    
    lazy var selectedCountButton: UIButton = { [unowned self] in
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: self.lk_width - 20 - 30, y: (70 - 20) / 2.0, width: 20, height: 20)
        button.layer.cornerRadius = 10;
        button.clipsToBounds = true
        button.backgroundColor = Configuration.buttonBackgroundColorNormal
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = Configuration.middleFont
        button.isHidden = true
        return button
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        [coverImageView,titleLable,selectedCountButton].forEach{
            addSubview($0)
        }
    }
    
    func initConfiguration(sortDate:Bool, shouldFixorientation:Bool) {
        if let model = model {
            let nameString = NSMutableAttributedString(string: model.name, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 14),NSForegroundColorAttributeName:UIColor.black])
            let countSring = NSMutableAttributedString(string: String(format: "  %zd", model.count), attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 14),NSForegroundColorAttributeName:UIColor.black])
            nameString.append(countSring)
            titleLable.attributedText = nameString
            
            selectedCountButton.isHidden = true
            if selectedCount > 0 {
                selectedCountButton.setTitle(String(format: "%ld", selectedCount), for: .normal)
                selectedCountButton.isHidden = false
            }
            AssetManager.getSurfacePlot(model, sortDate, shouldFixorientation) {
                (postImage) -> Void in
                self.coverImageView.image = postImage
            }
        }
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }



}


public class LKListCell: UICollectionViewCell {

    var _imageRequestID:PHImageRequestID? = nil
    var _representedAssetIdentifier:String? = nil
    var shouldFixOrientation:Bool = false
    var didSelectPhotoBlock:((Bool) -> Void)?
    
    var model: LKAssetModel? {
        willSet {
            if let new = newValue {
                self._representedAssetIdentifier = new.asset.localIdentifier
                let imageRequestID = AssetManager.getPhoto(new.asset, self.lk_width, shouldFixOrientation, completion: {    (photo,info, isDegraded) -> Void in
                        if self._representedAssetIdentifier == new.asset.localIdentifier {
                            self.pictureImageView.image = photo
                        } else {
                            if let id = self._imageRequestID {
                                PHImageManager.default().cancelImageRequest(id)
                            }
                        }
                        if !isDegraded {
                            self._imageRequestID = 0
                        }
                    }, progressHandler: nil, networkAccessAllowed: true)
                
                if let id = _imageRequestID {
                    if id != imageRequestID {
                        PHImageManager.default().cancelImageRequest(id)
                    }
                }
                _imageRequestID = imageRequestID
                
                selectPhotoButton.isSelected = new.isSelected
                selectImageView.image = selectPhotoButton.isSelected ? UIImage.imageNamedFromMyBundle(name: Configuration.photoSelImageName) : UIImage.imageNamedFromMyBundle(name: Configuration.photoDefImageName)
                
                timeLabel.text = new.timeLength
                if new.type == .video {
                    selectImageView.isHidden = true
                    selectPhotoButton.isHidden = true
                    bottomView.isHidden = false
                } else {
                    selectImageView.isHidden = false
                    selectPhotoButton.isHidden = false
                    bottomView.isHidden = true
                }
            }
        }
    }

    lazy var pictureImageView: UIImageView = { [unowned self] in
        let imageView = UIImageView()
        imageView.frame = CGRect(x: 0, y: 0, width: self.lk_width, height: self.lk_height)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var selectPhotoButton:UIButton = { [unowned self] in
        let selectBut = UIButton()
        selectBut.frame = CGRect(x: self.lk_width - 44, y: 0, width: 44, height: 44)
        selectBut.addTarget(self, action: #selector(selectPhotoButtonClick(_:)), for: .touchUpInside)
        return selectBut
    }()
    
    lazy var selectImageView:UIImageView = { [unowned self] in
        let selectImgV = UIImageView()
        selectImgV.frame = CGRect(x: self.lk_width - 27, y: 0, width: 27, height: 27)
        return selectImgV
    }()
    
    lazy var bottomView:UIView = { [unowned self] in
        let bottomView = UIView()
        bottomView.frame = CGRect(x: 0, y: self.lk_height - 17, width: self.lk_width, height: 17)
        bottomView.backgroundColor = UIColor.black
        bottomView.alpha = 0.8
        return bottomView
    }()
    
    lazy var videoImageView:UIImageView = {
        let videoImageView = UIImageView(frame: CGRect(x: 8, y: 0, width: 17, height: 17))
        videoImageView.image = UIImage.imageNamedFromMyBundle(name: Configuration.videoSendIconName)
        return videoImageView
    }()

    lazy var timeLabel:UILabel = { [unowned self] in
        let timeLable = UILabel()
        timeLable.frame = CGRect(x: self.videoImageView.lk_right, y: 0, width: self.lk_width - self.videoImageView.lk_right - 5, height: 17)
        timeLable.font = UIFont.systemFont(ofSize: 11)
        timeLable.textColor = UIColor.white
        timeLable.textAlignment = .center
        return timeLable
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        [pictureImageView,selectImageView,selectPhotoButton,bottomView].forEach {
            contentView.addSubview($0)
        }
        [videoImageView,timeLabel].forEach {
            bottomView.addSubview($0)
        }
        model = nil
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func selectPhotoButtonClick(_ sender:UIButton) {
        sender.isSelected = !sender.isSelected

        if let block = didSelectPhotoBlock {
            block(sender.isSelected)
        }
        
        selectImageView.image = sender.isSelected ? UIImage.imageNamedFromMyBundle(name: Configuration.photoSelImageName) : UIImage.imageNamedFromMyBundle(name: Configuration.photoDefImageName)
        if sender.isSelected {
            UIView.showOscillatoryAnimationWithLayer(layer: selectImageView.layer, type: .bigger)
        }
    }
    
}


public class LKPhotoPreviewCell: UICollectionViewCell,UIGestureRecognizerDelegate,UIScrollViewDelegate {
    
    var model: LKAssetModel? {
        willSet {
            if let new = newValue {
                scrollView.setZoomScale(1.0, animated: false)
                AssetManager.getPhoto(new.asset, shouldFixOrientation, completion: { (photo,info,isDegraded) -> Void in
                    self.imageView.image = photo
                    self.resizeSubViews()
                    }, progressHandler: nil, networkAccessAllowed: true)
            }
        }
    }
    
    var shouldFixOrientation:Bool = false
    var singleTapGestureBlock:(() -> ())? = nil
    
    lazy var scrollView: UIScrollView = { [unowned self] in
        let scrollView = UIScrollView()
        scrollView.frame = CGRect(x: 10, y: 0, width: self.lk_width - 20, height: self.lk_height)
        scrollView.delegate = self
        scrollView.bouncesZoom = true
        scrollView.maximumZoomScale = 2.5
        scrollView.minimumZoomScale = 1.0
        scrollView.isMultipleTouchEnabled = true
        scrollView.scrollsToTop = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.delaysContentTouches = false
        scrollView.canCancelContentTouches = true
        scrollView.alwaysBounceVertical = false
        return scrollView
    }()
    
    lazy var imageContainerView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor(white: 1.000, alpha: 0.500)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        model = nil

        addSubview(scrollView)
        scrollView.addSubview(imageContainerView)
        imageContainerView.addSubview(imageView)
        
        let tapOne = UITapGestureRecognizer(target: self, action: #selector(singleTap(_:)))
        let tapTwo = UITapGestureRecognizer(target: self, action: #selector(doubleTap(_:)))
        tapTwo.numberOfTapsRequired = 2
        tapOne.require(toFail: tapTwo)
        addGestureRecognizer(tapOne)
        addGestureRecognizer(tapTwo)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func recoverSubviews() {
        scrollView.setZoomScale(1.0, animated: false)
        resizeSubViews()
    }
    
    func resizeSubViews() {
        
        imageContainerView.setLk_origin(.zero)
        imageContainerView.setLk_width(scrollView.lk_width)
        
        let image = imageView.image!
        if image.size.height / image.size.width > lk_height / scrollView.lk_width {
            imageContainerView.setLk_height(floor(image.size.height / (image.size.width / scrollView.lk_width)))
        } else {
            var height = image.size.height / image.size.width * scrollView.lk_width
            if height < 1 || Double(height).isNaN { height = lk_height}
            height = floor(height)
            imageContainerView.setLk_height(height)
            imageContainerView.setLk_centerY(lk_height / 2)
        }
        
        if imageContainerView.lk_height > lk_height && imageContainerView.lk_height - lk_height <= 1 {
            imageContainerView.setLk_height(lk_height)
        }
        scrollView.contentSize = CGSize(width: scrollView.lk_width, height: max(imageContainerView.lk_height, lk_height))
        scrollView.scrollRectToVisible(bounds, animated: false)
        scrollView.alwaysBounceVertical = imageContainerView.lk_height <= lk_height ? false : true
        imageView.frame = imageContainerView.bounds
    }
    
    
    
    //MARK: - UITapGestureRecognizer Event
    
    func singleTap(_ tap:UITapGestureRecognizer){
        if let singleBlock = singleTapGestureBlock {
            singleBlock()
        }
    }
    
    func doubleTap(_ tap:UITapGestureRecognizer) {
        if scrollView.zoomScale > 1.0 {
            scrollView.setZoomScale(1.0, animated: true)
        } else {
            let touchPoint = tap.location(in: imageView)
            let newZoomScale = scrollView.maximumZoomScale
            
            let xsize = frame.size.width / newZoomScale
            let ysize = frame.size.width / newZoomScale
            scrollView.zoom(to: CGRect(x: touchPoint.x - xsize/2, y: touchPoint.y - ysize/2, width: xsize, height: ysize), animated: true)
        }
    }
    
    //MARK: - UIScrollViewDelegate
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageContainerView
    }
    
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = (scrollView.lk_width > scrollView.contentSize.width) ? (scrollView.lk_width - scrollView.contentSize.width) * 0.5 : 0.0
        let offsetY = (scrollView.lk_height > scrollView.contentSize.height) ? (scrollView.lk_height - scrollView.contentSize.height) * 0.5 : 0.0
        imageContainerView.center = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX, y: scrollView.contentSize.height * 0.5 + offsetY)
    }
}


public class LKAssetCameraCell: UICollectionViewCell {

    lazy var imageView:UIImageView = { [unowned self] in
        let imgV = UIImageView(frame:self.bounds)
        imgV.backgroundColor =  UIColor.init(white: 1.000, alpha: 0.500)
        imgV.contentMode = .scaleAspectFill
        return imgV
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(imageView)
        self.clipsToBounds = true
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}




