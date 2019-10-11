require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "react-native-video-helper"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.description  = "React Native video helper library, to compress and trim videos in Android and IOS."
  s.homepage     = "https://github.com/classapp/react-native-video-helper"
  s.license      = "MIT"
  s.license      = { :type => "MIT", :file => "LICENCE" }
  s.authors      = package['author']
  s.platforms    = { :ios => "9.0" }
  s.source       = { :git => "https://github.com/classapp/react-native-video-helper.git", :tag => "#{s.version}" }

  s.source_files = "ios/*.{h,m}"
  
  s.dependency "React"

end
