cd "$(dirname "$0")/YoHeSDKFramework"
pod repo remove yohe-sdk-ios
#pod repo update yohe-sdk-ios
pod repo add YoHeSDK https://potemka@github.com/yohe-io/yohe-sdk-ios.git
pod repo push YoHeSDK YoHeSDK.podspec   --allow-warnings --use-libraries
