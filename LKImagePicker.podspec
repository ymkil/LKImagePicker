Pod::Spec.new do |s|
  s.name         = "LKImagePicker"
  s.version      = "0.1.2"
  s.summary      = "A clone of TZImagePickerController, support picking multiple photos、original photo and video"
  s.homepage     = "https://github.com/ymkil/LKImagePicker"
  s.license      = "MIT"
  s.author       = { "Mkil" => "w3cylk@163.com" }
  s.platform     = :ios
  s.ios.deployment_target = "8.0"
  s.source       = { :git => "https://github.com/ymkil/LKImagePicker.git", :tag => "0.1.2" }
  s.requires_arc = true
  s.source_files = "LKImagePicker/LKImagePicker/*"
end
