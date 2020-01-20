require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = package["name"]
  s.version      = package["version"]
  s.summary      = package["title"]
  s.description  = package["description"]
  s.homepage     = "https://github.com/classapp/react-native-video-helper"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = package['author']
  s.platforms    = { :ios => "8.0" }
  s.source       = { :git => "https://github.com/classapp/react-native-video-helper.git", :tag => "#{s.version}" }

  s.source_files = "ios/*.{h,m}"
  
  s.dependency "React"

end
