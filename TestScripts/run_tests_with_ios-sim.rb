#!/usr/bin/env ruby

# Use ios-sim to trigger the unit test
# Reference: http://stackoverflow.com/questions/5403991/xcode-4-run-tests-from-the-command-line-xcodebuild

if ENV['TEST_VIA_CLI'] then
  launcher_path = `which ios-sim`.strip
  test_bundle_path= File.join(ENV['BUILT_PRODUCTS_DIR'], "#{ENV['PRODUCT_NAME']}.#{ENV['WRAPPER_EXTENSION']}")

  environment = {
    'DYLD_INSERT_LIBRARIES' => "/../../Library/PrivateFrameworks/IDEBundleInjection.framework/IDEBundleInjection",
    'XCInjectBundle' => test_bundle_path,
    'XCInjectBundleInto' => ENV["TEST_HOST"]
  }

  environment_args = environment.collect { |key, value| "--setenv #{key}=\"#{value}\"" }.join(" ")

  app_test_host = File.dirname(ENV["TEST_HOST"])

  cmd = "#{launcher_path} launch \"#{app_test_host}\" #{environment_args} --args -SenTest All #{test_bundle_path}"
  cmd.gsub! "iphoneos", "iphonesimulator"
  system(cmd)
end
