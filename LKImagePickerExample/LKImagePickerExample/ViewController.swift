//
//  ViewController.swift
//  LKImagePicker
//
//  Created by Mkil on 19/12/2016.
//  Copyright © 2016 黎宁康. All rights reserved.
//

import UIKit
import Photos
import LKImagePicker

protocol delegate {
    
}

class ViewController: UIViewController , UICollectionViewDelegate,UICollectionViewDataSource,LKImagePickerControllerDelegate{

    
    var photos:[UIImage] = []
    
    
    @IBOutlet weak var showInsideTakePhotoSwitch: UISwitch!
    
    
    @IBOutlet weak var timeSortSwitch: UISwitch!
    
    
    @IBOutlet weak var selectedVideoSwitch: UISwitch!
    
    @IBOutlet weak var selectedPhotoSwitch: UISwitch!
    
    
    @IBOutlet weak var selectedOriginalPhotoSwitch: UISwitch!
    
    
    @IBOutlet weak var selectedMaxNumberTF: UITextField!

    
    @IBOutlet weak var showRowNumberTF: UITextField!
    
    lazy var collectionView: UICollectionView = { [unowned self] in
        let layout = UICollectionViewFlowLayout()
        let margin:CGFloat = 4
        let itemH = (self.view.frame.size.width - 2 * margin - 4) / 3 - margin
        layout.itemSize = CGSize(width: itemH, height: itemH)
        layout.minimumInteritemSpacing = margin
        layout.minimumLineSpacing = margin
        
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 245 + 45, width: self.view.frame.size.width, height: self.view.frame.size.height - 245 - 45), collectionViewLayout: layout)
        let rgb:CGFloat = 244 / 255.0
        
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = UIColor(red: rgb, green: rgb, blue: rgb, alpha: 1.0)
        collectionView.contentInset = UIEdgeInsetsMake(4, 4, 4, 4)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.keyboardDismissMode = .onDrag
        collectionView.register(LKTestCell.self, forCellWithReuseIdentifier: "LKTestCell")
        
        return collectionView
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collectionView)
    }

    
    //MARK: - UICollectionViewDelegate UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"LKTestCell", for: indexPath) as! LKTestCell
        
        if indexPath.row == photos.count {
            cell.imageView.image = UIImage(named: "AlbumAddBtn")
            cell.deleteBtn.isHidden = true
        } else {
            cell.imageView.image = photos[indexPath.row]
            cell.deleteBtn.isHidden = false
        }
        
        cell.deleteBtn.tag = indexPath.row
        cell.deleteBtn.addTarget(self, action: #selector(deleteBtnClik(_:)), for: .touchUpInside)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == photos.count {
            
            // MARK: 这些参数都可以不传，此时会走默认设置, 也可以通过代理回调
            let imagePickerVC =  LKImagePickerController(maxImagesCount: 9, columnNumber: 4, delegate: self, true) {
                (images, assets, isSelectOriginalPhoto) in
                
                self.photos = self.photos + images
                
                self.collectionView.reloadData()
            }
            // 在内部显示拍照按钮
            imagePickerVC.imageConfig.allowTakePicture = showInsideTakePhotoSwitch.isOn
            // 照片排列按修改时间升序
            imagePickerVC.imageConfig.sortAscendingByModificationDate = timeSortSwitch.isOn
            
            // 设置是否可以选择视频/图片/原图
            imagePickerVC.imageConfig.allowPickingVideo = selectedVideoSwitch.isOn
            imagePickerVC.imageConfig.allowPickingImage = selectedPhotoSwitch.isOn
            imagePickerVC.imageConfig.allowPickingOriginImage = selectedOriginalPhotoSwitch.isOn
            
            // 设置最大选择张数和每行显示个数
            imagePickerVC.imageConfig.maxImagesCount = (selectedMaxNumberTF.text?.toInt)!
            imagePickerVC.imageConfig.columnNumber = (showRowNumberTF.text?.toInt)!
            
            self.present(imagePickerVC, animated: true, completion: nil)
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - LKImagePickerControllerDelegate
    
    // 如果isSelectOriginalPhoto为YES，表明用户选择了原图
    // 你可以通过一个asset获得原图，通过这个方法：AssetManager.getOriginalPhoto(asset: PHAsset, _ shouldFixOrientation: Bool, completion: ((UIImage?, [AnyHashable : Any]?) -> Void)?)
    // photos数组里的UIImage对象，默认是828像素宽，你可以通过设置photoWidth属性的值来改变它
    
    func imagePickerControllerDidFinish(_ picker: LKImagePickerController, _ photos: [UIImage], _ assets: [Any], _ isSelectOriginalPhoto: Bool) {
        

        
    }
    

    /// User click cancel button
    /// 用户点击了取消
    func imagePickerControllerDidCancel(_ picker: LKImagePickerController) {
        print("cancel")
    }
    
    // MARK: - Click Event
    
    
    func deleteBtnClik(_ sender:UIButton) {
        
        photos.remove(at: sender.tag)
        collectionView.reloadData()
    }
    
    @IBAction func showInsideTakePhoto(_ sender: UISwitch) {
    }

    @IBAction func timeSort(_ sender: UISwitch) {
    }
    
    @IBAction func selectedVideo(_ sender: UISwitch) {
        
        if !sender.isOn {
            selectedPhotoSwitch.setOn(true, animated: true)
        }
    }
    
    @IBAction func selectedPhoto(_ sender: UISwitch) {
        if !sender.isOn {
            selectedVideoSwitch.setOn(true, animated: true)
        }
    }
    
    @IBAction func selectedOriginalPhoto(_ sender: UISwitch) {
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
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

