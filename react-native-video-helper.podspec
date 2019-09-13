require "json"
package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |spec|

  spec.name                   = "react-native-video-helper"
  spec.version                = package['version']
  spec.summary                = "React Native video helper library, to compress and trim videos."
  spec.description            = "React Native video helper library, to compress and trim videos using AVFoundation in iOS and MediaCodec in Android"
  spec.homepage               = "https://github.com/classapp/react-native-video-helper/"
  spec.license                = { :type => "MIT", :file => "LICENSE" }
  spec.author                 = package['author']
  spec.source                 = { :git => "https://github.com/classapp/react-native-video-helper.git", :tag => "#{spec.version}" }
  spec.source_files           = "ios", "ios/*.{h,m}"
  spec.platform               = :ios, "8.0"
  spec.dependency 'React'
  
end