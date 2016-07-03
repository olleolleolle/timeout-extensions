require 'rubygems'
require 'bundler/setup'
require 'logger'
require 'timeout'
require 'timeout/extensions'


RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  config.before do
    include Timeout::Extensions
  end

  config.order = 'random'
end



def within_thread(&block)
  Thread.new do
    yield
  end.join
end


