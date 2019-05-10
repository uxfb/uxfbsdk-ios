source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '10.0'
use_frameworks!
inhibit_all_warnings!

def all_pods 
#pod 'CodableAlamofire'
pod 'Nuke'
pod 'ReachabilitySwift'
pod 'AlamofireNetworkActivityLogger'
pod 'UIColor_Hex_Swift', '~> 4.2.0'
#pod 'SVGKit', :git => 'https://github.com/SVGKit/SVGKit.git', :branch => '2.x'
end

target 'UX Feedback Demo' do
  pod 'CocoaLumberjack/Swift'
  all_pods
  #pod 'Usabilla'
end

target 'UXFeedbackSDK' do
  all_pods
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        puts target.name
    end
end