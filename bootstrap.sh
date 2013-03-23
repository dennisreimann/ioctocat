#!/bin/bash
set -e

# Install the submodules
git submodule update --init

# Install the dependencies
gem install bundler
bundle
bundle exec pod install

# Create the iOctocatAPI.plist file by copying the sample
cp iOctocatAPI{.sample,}.plist

# Create the HockeySDK.plist file by copying the sample:
cp HockeySDK{.sample,}.plist

echo "Done, now open iOctocat.xcworkspace :)"
