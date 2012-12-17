#!/usr/bin/env ruby

# Adapted from this post:
# http://baolei.tumblr.com/post/32428168156/ios-unit-test-from-command-line-ios6-xcode4-5

# error output gets send to /dev/null because xcodebuild has some annoying extra output in
# case xcactivitylog is missing and exits with success status code all the time anyways
log = File.expand_path('../test.log', __FILE__)
cmd = "TEST_VIA_CLI=YES xcodebuild -workspace iOctocat.xcworkspace -scheme 'iOctocat Unit Tests' -sdk iphonesimulator -arch i386 ONLY_ACTIVE_ARCH=NO TEST_AFTER_BUILD=YES build > #{log} 2>/dev/null"
system(cmd)

result = ''
File.open(log, 'r') { |f| result = f.read }
result.gsub!("\n[DEBUG] ", '')

fails = result.scan /iOctocatUnitTests\/.*: [\w\s]+:.*/
passes = result.scan /Test Case .* passed/

if fails.length > 0
  puts 'Unit Tests failed:'
  puts fails
  exit false
else
  if passes.length > 0
    puts 'Unit Tests passed :)'
  else
    puts 'Unit Test setup problem:'
    puts result
    exit false
  end
end
