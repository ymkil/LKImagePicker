Pod::Spec.new do |s|
  s.name             = 'LKImagePicker'
  s.version          = '0.1.0'
  s.summary          = 'An image selector'
 
  s.description      = <<-DESC
A clone of UIImagePickerController, support picking multiple photos、original photo、video, also allow preview photo and video, fitting iOS8910 system.
                       DESC
 
  s.homepage         = 'https://github.com/ymkil/LKImagePicker'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '<Mkil>' => '<w3cylk@163.com>' }
  s.source           = { :git => 'https://github.com/ymkil/LKImagePicker.git', :tag => s.version.to_s }
 
  s.ios.deployment_target = '8.0'
  s.source_files = 'LKImagePicker/LKImagePicker/*'
 
end