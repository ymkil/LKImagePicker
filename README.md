# LKImagePicker
A multi-select, select the original image and video picture selector, while preview function, fit the iOS8910 system.
一个支持多选、选原图和视频(年后添加)的图片选择器，同时有预览功能，适配了iOS8910系统。

 在Xcode8环境下将项目运行在iOS10的设备/模拟器中，访问相册和相机需要额外配置info.plist文件。分别是Privacy - Photo Library Usage Description和Privacy - Camera Usage Description字段。

 ![image](http://mkiltech.com/images/LKImagePicker/Pikcer1.jpg)

 ![image](http://mkiltech.com/images/LKImagePicker/Picker2.jpg)

## 一. Installation 安装

  * CocoaPods：`由于各种原因pod search搜索不到`，请直接pod 'LKImagePicker', '~> 1.0'，pod install 是能下载的。导入模块：import LKImagePicker
  * 手动导入：将LKImagePicker文件夹拽入项目中

## 二. Example 例子
``` swift
// MARK: 这些参数都可以不传，此时会走默认设置, 也可以通过代理回调
let imagePickerVC =  LKImagePickerController(maxImagesCount: 9, columnNumber: 4, delegate: self, true) {
    (images, assets, isSelectOriginalPhoto) in
    
}

self.present(imagePickerVC, animated: true, completion: nil)
``` swift
## 三. Requirements 要求
   iOS 8 or later. Requires ARC  
   iOS8及以上系统可使用. ARC环境.
## 四. More 更多 

  If you find a bug, please create a issue.  
  Welcome to pull requests.   
  如果你发现了bug，请提一个issue。  
  欢迎给我提pull requests。
