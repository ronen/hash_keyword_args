if RUBY_VERSION > "1.9"
  require 'simplecov'
  require 'simplecov-gem-adapter'
  SimpleCov.start 'gem'
end

require 'rspec'
require 'enumerable_hashify'
require 'hash_keyword_args'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  
end
