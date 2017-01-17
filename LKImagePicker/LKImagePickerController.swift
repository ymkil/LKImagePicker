//
//  LKImagePickerController.swift
//  LKImagePicker
//
//  Created by Mkil on 19/12/2016.
//  Copyright © 2016 黎宁康. All rights reserved.
//

import UIKit
import Photos

public class LKImagePickerController: UINavigationController {
    
    public var imageConfig = ImagePickerConfig()
    var selectedModels:[LKAssetModel] = []
    var didFinishPickingPhotosHandle:(([UIImage], [Any], Bool) -> Void)?
    weak var pickerDelegate:LKImagePickerControllerDelegate?
    
    var progressHUD:UIButton?
    var HUDContainer:UIView?
    var HUDIndicatorView:UIActivityIndicatorView?
    var HUDLable:UILabel?
    
    lazy var tipLable:UILabel = { [unowned self] in
        let tipLable = UILabel()
        tipLable.frame = CGRect(x: 8, y: 120, width: self.view.lk_width - 16, height: 60)
        tipLable.textAlignment = .center
        tipLable.numberOfLines = 0
        tipLable.font = Configuration.bigFont
        tipLable.textColor = UIColor.black
        var appName = Bundle.main.infoDictionary?["CFBundleDisplayName"]
        
        if appName == nil { appName = Bundle.main.infoDictionary?["CFBundleName"] }
        if let appName = appName {
            let tipText = String(format: Bundle.lk_localizedString(key: "Allow %@ to access your album in \"Settings -> Privacy -> Photos\""), appName as! String)
            tipLable.text = tipText
        }
        
        return tipLable
    }()
    
    lazy var settingBtn:UIButton = { [unowned self] in
        let setBtn = UIButton(type: .system)
        setBtn.frame = CGRect(x: 0, y: 180, width: self.view.lk_width, height: 44)
        setBtn.setTitle(Bundle.lk_localizedString(key: "Setting"), for: .normal)
        setBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        setBtn.addTarget(self, action: #selector(settingBtnClick), for: .touchUpInside)
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(observeAuthrizationStatusChange), userInfo: nil, repeats: true)
        return setBtn
    }()
    
    var timer:Timer? = nil
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        navigationBar.barStyle = .black
        navigationBar.isTranslucent = true
        
        navigationBar.barTintColor = Configuration.navBarBackgroundColor
        navigationBar.tintColor = UIColor.white
        automaticallyAdjustsScrollViewInsets = false
    }
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public init(maxImagesCount: Int = 9, columnNumber: Int = 4, delegate: LKImagePickerControllerDelegate? = nil, _ pushPicturePickerVc: Bool = true, finishPickingPhotosHandle:(([UIImage], [Any], Bool) -> Void)? = nil) {
        
        let rootVC = LKAlbumPickerController()
        super.init(rootViewController: rootVC)
        
        pickerDelegate = delegate
        imageConfig.maxImagesCount = maxImagesCount
        imageConfig.columnNumber = columnNumber
        imageConfig.pushPicturePickerVc = pushPicturePickerVc
        
        didFinishPickingPhotosHandle = finishPickingPhotosHandle
        
        if !AssetManager.authorizationStatusAuthorized() {
            [tipLable,settingBtn].forEach {
                view.addSubview($0)
            }
        } else {
            pushPhotoPickerVc()
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func pushPhotoPickerVc() {
        var didPushPhotoPickerVc = false
        
        if !didPushPhotoPickerVc && imageConfig.pushPicturePickerVc {
            let photoPickerVC = LKPhotoPickerController()
            didPushPhotoPickerVc = true
            self.pushViewController(photoPickerVC, animated: true)
        }
    }
    
    func settingBtnClick()  {
        UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
    }
    
    func observeAuthrizationStatusChange() {
        if AssetManager.authorizationStatusAuthorized() {
            tipLable.removeFromSuperview()
            settingBtn.removeFromSuperview()
            if let timer = timer {
                timer.invalidate()
                self.timer = nil
            }
            pushPhotoPickerVc()
        }
    }
    
    //MARK: -  Private Method
    
    func showAlertWithTitle(title: String) {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: Bundle.lk_localizedString(key: "OK"), style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showProgressHUD() {
        
        if progressHUD == nil {
            progressHUD = UIButton(type: .custom)
            progressHUD?.backgroundColor = UIColor.clear
            
            HUDContainer = UIView()
            HUDContainer?.frame = CGRect(x: (self.view.lk_width - 120) / 2, y: (self.view.lk_height - 90) / 2, width: 120, height: 90)
            HUDContainer?.layer.cornerRadius = 8
            HUDContainer?.clipsToBounds = true
            HUDContainer?.backgroundColor = UIColor.darkGray
            HUDContainer?.alpha = 0.7
            
            HUDIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .white)
            HUDIndicatorView?.frame = CGRect(x: 45, y: 15, width: 30, height: 30)
            
            HUDLable = UILabel(frame: CGRect(x: 0, y: 40, width: 120, height: 50))
            HUDLable?.textAlignment = .center
            HUDLable?.text = Bundle.lk_localizedString(key: "Processing...")
            HUDLable?.font = Configuration.middleFont
            HUDLable?.textColor = UIColor.white
            
            HUDContainer?.addSubview(HUDLable!)
            HUDContainer?.addSubview(HUDIndicatorView!)
            progressHUD?.addSubview(HUDContainer!)
        }
        HUDIndicatorView?.startAnimating()
        
        UIApplication.shared.keyWindow?.addSubview(progressHUD!)
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + .seconds(imageConfig.timeout)) {
            DispatchQueue.main.async {
                self.hideProgressHUD()
            }
        }
        
    }
    
    func hideProgressHUD() {
        if let _ = progressHUD {
            HUDIndicatorView?.stopAnimating()
            progressHUD?.removeFromSuperview()
        }
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

internal class LKAlbumPickerController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var albumArr: [LKAlbumModel] = []
    
    lazy var tableView: UITableView = { [unowned self] in
        let tableView = UITableView(frame: CGRect(x: 0, y: Configuration.NavBarHeight, width: Configuration.ScreenWinth, height: Configuration.ScreenHeight - Configuration.NavBarHeight), style: .plain)
        tableView.rowHeight = 70
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(LKAlbumCell.self, forCellReuseIdentifier: "LKAlbumCell")
        return tableView
    }()
    
    override internal func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        view.backgroundColor = UIColor.white
        navigationItem.title = Bundle.lk_localizedString(key: "Photos")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: Bundle.lk_localizedString(key: "Cancel"), style: .plain, target: self, action: #selector(cancel))
        navigationItem.backBarButtonItem = UIBarButtonItem(title: Bundle.lk_localizedString(key: "Back"), style: .plain, target: nil, action: nil)
        
        view.addSubview(self.tableView)
        configTableView()
    }
    
    override internal func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    func configTableView() {
        let imagePickerVc = navigationController as! LKImagePickerController
        AssetManager.getAllAlbums(false, imagePickerVc.imageConfig.allowPickingImage, imagePickerVc.imageConfig.sortAscendingByModificationDate) {
            (models) -> Void in
            self.albumArr = models
            self.tableView.reloadData()
        }
    }

    //MARK: - UITableViewDelegate,UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albumArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let imagePickerVc = navigationController as! LKImagePickerController
        let cell = tableView.dequeueReusableCell(withIdentifier: "LKAlbumCell") as! LKAlbumCell
        cell.selectedCount = refreshCellSelectedCount(model: albumArr[indexPath.row])
        cell.model = albumArr[indexPath.row]
        cell.initConfiguration(sortDate: imagePickerVc.imageConfig.sortAscendingByModificationDate, shouldFixorientation: imagePickerVc.imageConfig.shouldFixOrientation)
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let photoPickerVC = LKPhotoPickerController()
        photoPickerVC.model = albumArr[indexPath.row]
        navigationController?.pushViewController(photoPickerVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func refreshCellSelectedCount(model:LKAlbumModel) -> Int {
        let imagePickerVc = navigationController as! LKImagePickerController
        var count = 0
        
        for itemModel in model.models {
            for selectedModel in imagePickerVc.selectedModels {
                if itemModel.asset.localIdentifier == selectedModel.asset.localIdentifier {
                    count += 1
                }
            }
        }
        return count
    }
    
    func cancel() {
        navigationController?.dismiss(animated: true, completion: nil)
        let imagePickerVc = navigationController as! LKImagePickerController
        imagePickerVc.pickerDelegate?.imagePickerControllerDidCancel?(imagePickerVc)
    }
}
