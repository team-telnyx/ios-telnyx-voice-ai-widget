#!/bin/bash
# This script updates the SDK version in the required files
# Example of usage: sh scripts/setup_version.sh -v "1.0.0"

while getopts v: flag
do
    case "${flag}" in
        v) version=${OPTARG};;
    esac
done
echo "New version: $version";

# Replace version in podspec file (handles multiple spaces)
sed -i '' 's/spec\.version[[:space:]]*=[[:space:]]*".*"/spec.version      = "'$version'"/' TelnyxVoiceAIWidget.podspec

# Replace version in TelnyxVoiceAIWidget Xcode project
sed -i '' 's/MARKETING_VERSION = .*/MARKETING_VERSION = '"$version"';/' TelnyxVoiceAIWidget/TelnyxVoiceAIWidget.xcodeproj/project.pbxproj

# Replace version in SampleApp Xcode project
sed -i '' 's/MARKETING_VERSION = .*/MARKETING_VERSION = '"$version"';/' SampleApp/SampleApp.xcodeproj/project.pbxproj
