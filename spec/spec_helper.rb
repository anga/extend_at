require 'rubygems'
require 'bundler/setup'
require 'rspec'

require 'database_cleaner/active_record/base'
require 'database_cleaner'

# ENV["RAILS_ENV"] = "test"
require 'app/config/environment'

require 'rubygems'
require 'bundler/setup'

require 'extend_at'


# Bundler.require(:default)


RSpec.configure do |config|
#   config.before(:suite) do
#     DatabaseCleaner.strategy = :truncation
#   end
# 
#   config.before(:each) do
#     DatabaseCleaner.start
#   end
# 
#   config.after(:each) do
#     DatabaseCleaner.clean
#   end
end
