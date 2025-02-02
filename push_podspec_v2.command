cd "$(dirname "$0")/UXFeedbackSDKFramework_v2"
pod repo remove uxfbsdk
#pod repo update uxfbsdk-ios
pod repo add uxfbsdk https://potemka@github.com/uxfb/uxfbsdk.git
pod repo push uxfbsdk UXFBSDK.podspec  --allow-warnings --use-libraries
