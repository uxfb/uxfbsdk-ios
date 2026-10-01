Pod::Spec.new do |s|

  s.name          = "UXFBSDK"
  s.version       = "4.0.2"
  s.summary       = "Collect feedback from your users"
  s.description   = "With UXFeedbackSDK you can collect feedback from your users"
  s.homepage      = "https://github.com/uxfb/uxfbsdk-ios"
  s.license       = "Apache License, Version 2.0"
  s.author        = { "Team SDK" => "info@uxfeedback.ru" }
  s.platform      = :ios, "12.0"
  s.swift_version = "5.7"
  s.source        = { :git => "https://github.com/uxfb/uxfbsdk-ios.git", :tag => "v4.0.2" }
  s.ios.vendored_frameworks = 'UXFeedbackSDK.xcframework'
  s.frameworks = "Foundation", "UIKit", "SystemConfiguration", "CoreTelephony"
end
