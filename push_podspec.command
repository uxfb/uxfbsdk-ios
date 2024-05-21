cd "$(dirname "$0")/UXFeedbackSDKFramework"
pod repo remove uxfeedback-sdk-ios
#pod repo update uxfeedback-sdk-ios
pod repo add uxfeedback-sdk-ios https://github.com/uxfb/uxfeedback-sdk-ios.git
pod repo push uxfeedback-sdk-ios  UXFeedbackSDK.podspec  --allow-warnings --use-libraries
