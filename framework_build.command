#!/bin/sh
#  Created by Alexander on 25.03.2021.
#  Copyright (c) 2021 Alexander Potemka. All rights reserved.

SDK_TARGET_NAME="UXFeedbackSDK"

MAIN_DIR="$(dirname "$0")"
cd "$MAIN_DIR"

# set framework folder name
FRAMEWORK_FOLDER_NAME="${SDK_TARGET_NAME}_XCFramework"
# set framework name or read it from project by this variable
FRAMEWORK_NAME="${SDK_TARGET_NAME}"
#xcframework path
FRAMEWORK_PATH="${MAIN_DIR}/${FRAMEWORK_FOLDER_NAME}/${FRAMEWORK_NAME}.xcframework"
# set path for iOS simulator archive
SIMULATOR_ARCHIVE_PATH="./build/ios_simulator.xcarchive"
# set path for iOS device archive
IOS_DEVICE_ARCHIVE_PATH="./build/ios.xcarchive"

rm -rf "${MAIN_DIR}/${FRAMEWORK_FOLDER_NAME}"
mkdir -p "$SIMULATOR_ARCHIVE_PATH"
mkdir -p "$IOS_DEVICE_ARCHIVE_PATH"
mkdir -p "$FRAMEWORK_PATH"

echo "Archiving ${FRAMEWORK_NAME}"
xcodebuild archive -scheme ${FRAMEWORK_NAME} -destination="iOS Simulator" -archivePath "${SIMULATOR_ARCHIVE_PATH}" -sdk iphonesimulator SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES
xcodebuild archive -scheme ${FRAMEWORK_NAME} -destination="iOS" -archivePath "${IOS_DEVICE_ARCHIVE_PATH}" -sdk iphoneos SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES
#Creating XCFramework
echo "Creating XCFramework"
xcodebuild -create-xcframework -framework ${SIMULATOR_ARCHIVE_PATH}/Products/Library/Frameworks/${FRAMEWORK_NAME}.framework -framework ${IOS_DEVICE_ARCHIVE_PATH}/Products/Library/Frameworks/${FRAMEWORK_NAME}.framework -output "${FRAMEWORK_PATH}"

echo "Clean archives"
#rm -rf "${SIMULATOR_ARCHIVE_PATH}"
#rm -rf "${IOS_DEVICE_ARCHIVE_PATH}"
#open "${MAIN_DIR}/${FRAMEWORK_FOLDER_NAME}"
