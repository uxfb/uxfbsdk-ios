Pod::Spec.new do |s|

  s.name          = "UXFBSDK"
  s.version       = "4.6.0"
  s.summary       = "Collect feedback from your users"
  s.description   = "With UXFeedbackSDK you can collect feedback from your users"
  s.homepage      = "https://github.com/uxfb/uxfbsdk-ios"
  s.license       = { :type => "Apache License, Version 2.0", :text => "Licensed under the Apache License, Version 2.0. See https://www.apache.org/licenses/LICENSE-2.0" }
  s.author        = { "Team SDK" => "info@uxfeedback.ru" }
  s.platform      = :ios, "12.0"
  s.swift_version = "5.7"
  s.source        = { :http => "https://github.com/uxfb/uxfbsdk-ios/releases/download/v4.6.0/UXFeedbackSDK.xcframework.zip" }
  s.ios.vendored_frameworks = 'UXFeedbackSDK.xcframework'
  s.frameworks = "Foundation", "UIKit", "SystemConfiguration", "CoreTelephony"
end
