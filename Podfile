platform :ios, '5.0'

gem 'cocoapods', '0.16.0'
pod 'AFNetworking', '1.1'
pod 'AFOAuth2Client', '0.1'
pod 'Orbiter'
pod 'Base64'
pod 'SVPullToRefresh', :head
pod 'SVProgressHUD', :head
pod 'HockeySDK'
pod 'YRDropdownView', :git => 'https://github.com/iOctocat/YRDropdownView.git'
pod 'ECSlidingViewController', :git => 'https://github.com/iOctocat/ECSlidingViewController.git'
pod 'Expecta', :git => 'https://github.com/github/expecta.git'

post_install do |installer|
  require 'fileutils'
  FileUtils.copy 'Pods/Pods-Acknowledgements.plist', 'Settings.bundle/CocoaPodsLicenses.plist'
end
