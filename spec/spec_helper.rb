require 'rspec'
require 'rspec/its'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.syntax = [:should, :expect]
  end
end

# class Time
#   # Convert timezone
#   # from "Ruby Cookbook"
#   def convert_zone(to_zone)
#     original_zone = ENV["TZ"]
#     utc_time = dup.gmtime
#     ENV["TZ"] = to_zone
#     to_zone_time = utc_time.localtime
#     ENV["TZ"] = original_zone
#     return to_zone_time
#   end
# end
