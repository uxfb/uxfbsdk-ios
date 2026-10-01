#!/bin/sh
set -eu

VERSION="$1"

case "$VERSION" in
  [0-9]*.[0-9]*.[0-9]*) ;;
  *) echo "apply_version: '$VERSION' is not X.Y.Z"; exit 1 ;;
esac

CONSTS="Core/UXFeedback/UXFeedbackConsts.swift"
PODSPEC="UXFBSDK.podspec"

sed -i '' -E "s/static let version: String = \"[^\"]*\"/static let version: String = \"$VERSION\"/" "$CONSTS"
sed -i '' -E "s/(s\.version[[:space:]]*=[[:space:]]*)\"[^\"]*\"/\1\"$VERSION\"/" "$PODSPEC"
sed -i '' -E "s/:tag => \"v[^\"]*\"/:tag => \"v$VERSION\"/" "$PODSPEC"

echo "Applied version $VERSION:"
grep "static let version" "$CONSTS"
grep -E "s\.version|:tag" "$PODSPEC"
