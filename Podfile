platform :ios, '5.0'
pod 'AFNetworking', '1.1'
pod 'AFOAuth2Client', '0.1'
pod 'Base64'
pod 'SVPullToRefresh'
pod 'SVProgressHUD'
pod 'HockeySDK'
pod 'YRDropdownView', :git => 'https://github.com/iOctocat/YRDropdownView.git'
pod 'ECSlidingViewController', :git => 'https://github.com/iOctocat/ECSlidingViewController.git'
pod 'Expecta', '~> 0.2.0'

post_install do |installer|
  require 'fileutils'
  FileUtils.copy 'Pods/Pods-Acknowledgements.plist', 'Settings.bundle/CocoaPodsLicenses.plist'
end
