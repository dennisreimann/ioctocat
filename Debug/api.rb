#!/usr/bin/env ruby

# Script to check the returned JSON of the GitHub.com API.
# Authentication is optional and is done via HTTP Basic Auth
# in case a username and password are provided.
#
# Usage: Debug/api.rb PATH [USERNAME] [PASSWORD]
#
# This scripts writes the output and additional debugging
# information to a log file in the Debug directory.

require "rubygems"
require "net/https"
require "uri"
require "json"

path = ARGV[0]
user = ARGV[1]
pass = ARGV[2]

date = Time.now.utc
uri  = URI.parse("https://api.github.com/#{path}")
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE

req = Net::HTTP::Get.new(uri.request_uri)
req.add_field("Accept", "application/vnd.github+json")
req.basic_auth(user, pass) if user && pass

res = http.request(req)
json = JSON.parse(res.body)

out  = "Date:        #{date}\n"
out += "Request URL: #{uri}\n"
out += "Username:    #{user}\n" if user && pass
out += "\n"
out += "Raw response:\n\n#{res.body}\n\n=====\n\n"
out += "Prettified JSON:\n\n#{JSON.pretty_generate(json)}\n\n=====\n\n"
out += "Status:                #{res['status']}\n"
out += "Last-Modified:         #{res['last-modified']}\n"
out += "Cache-Control:         #{res['cache-control']}\n"
out += "X-Poll-Interval:       #{res['x-poll-interval']}\n"
out += "X-RateLimit-Limit:     #{res['x-ratelimit-limit']}\n"
out += "X-RateLimit-Remaining: #{res['x-ratelimit-remaining']}\n"

timestamp = date.to_s.gsub(/-|:/, '').gsub(' ', '-')
pathname  = uri.path.gsub(/:|\/|\?|&/, '_')
filename  = "#{File.dirname __FILE__}/#{timestamp}-#{pathname}.log"

File.open(filename, 'w+') { |file| file.write(out) }

puts out
