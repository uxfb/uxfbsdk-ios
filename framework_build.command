#!/bin/sh
#  Created by Dmitry on 25.03.2019.
#  Copyright (c) 2013 Dmitry Kudryavcev. All rights reserved.

IOS_TARGET_NAME="UXFeedbackSDK"

MAIN_DIR="$(dirname "$0")"
cd "$MAIN_DIR"

CONFIGURATION="Release"

IOS_PLATFORMS=(
"iphoneos"
"iphonesimulator"
)

xcodebuild clean

for PLATFORM in "${IOS_PLATFORMS[@]}"; do
 echo "Build for $CONFIGURATION $PLATFORM"
xcodebuild -target "$IOS_TARGET_NAME" ONLY_ACTIVE_ARCH=NO -configuration "$CONFIGURATION" -sdk "$PLATFORM" build
done

BUILD_PRODUCTS="$MAIN_DIR/build"

UNIVERSAL_OUTPUTFOLDER=${BUILD_PRODUCTS}/${CONFIGURATION}-universal
# Make sure the output directory exists
mkdir -p "${UNIVERSAL_OUTPUTFOLDER}"
# Next, work out if we're in SIM or DEVICE

# Step 2. Copy the framework structure (from iphoneos build) to the universal folder

cp -R "${BUILD_PRODUCTS}/${CONFIGURATION}-iphoneos/$IOS_TARGET_NAME.framework" "${UNIVERSAL_OUTPUTFOLDER}/"

# Step 3. Copy Swift modules from iphonesimulator build (if it exists) to the copied framework directory

cp -R "${BUILD_PRODUCTS}/${CONFIGURATION}-iphonesimulator/${IOS_TARGET_NAME}.framework/Modules/${IOS_TARGET_NAME}.swiftmodule/." "${UNIVERSAL_OUTPUTFOLDER}/${IOS_TARGET_NAME}.framework/Modules/${IOS_TARGET_NAME}.swiftmodule"

# Step 4. Create universal binary file using lipo and place the combined executable in the copied framework directory
lipo -create -output "${UNIVERSAL_OUTPUTFOLDER}/${IOS_TARGET_NAME}.framework/${IOS_TARGET_NAME}" "${BUILD_PRODUCTS}/${CONFIGURATION}-iphonesimulator/${IOS_TARGET_NAME}.framework/${IOS_TARGET_NAME}" "${BUILD_PRODUCTS}/${CONFIGURATION}-iphoneos/${IOS_TARGET_NAME}.framework/${IOS_TARGET_NAME}"

# Step 5. Convenience step to copy the framework to the project's directory
FRAMEWORK_REPO_DIR="UXFeedbackSDKFramework//${IOS_TARGET_NAME}.framework"
#rm -rf "$FRAMEWORK_REPO_DIR"
rm "UXFeedbackSDKFramework"
mkdir -p "UXFeedbackSDKFramework"

cp -R "${UNIVERSAL_OUTPUTFOLDER}/${IOS_TARGET_NAME}.framework" "$FRAMEWORK_REPO_DIR"

# Step 6. Convenience step to open the project's directory in Finder
open "$FRAMEWORK_REPO_DIR"
#fi
