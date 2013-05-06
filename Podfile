platform :ios, '5.0'

gem 'cocoapods', '0.19.1'

pod 'AFNetworking', '1.2'
pod 'AFOAuth2Client', '0.1'
pod 'Base64'
pod 'SVPullToRefresh', '0.4.1'
pod 'SVProgressHUD', '0.9.0'
pod 'TTTAttributedLabel'
pod 'HockeySDK'
pod 'TPKeyboardAvoiding'
pod 'NSStringEmojize', :git => 'https://github.com/iOctocat/NSStringEmojize.git'
pod 'YRDropdownView', :git => 'https://github.com/iOctocat/YRDropdownView.git'
pod 'ECSlidingViewController', :git => 'https://github.com/iOctocat/ECSlidingViewController.git'
pod 'Expecta', '~> 0.2.1'

post_install do |installer|
  require 'fileutils'
  FileUtils.copy 'Pods/Pods-Acknowledgements.plist', 'Settings.bundle/CocoaPodsLicenses.plist'
end
