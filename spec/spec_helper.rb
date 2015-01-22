require 'rubygems'
require 'bundler/setup'
require 'logger'
require 'timeout'
require 'timeout/extensions'
require 'celluloid/autostart'
require 'celluloid/rspec'

logfile = File.open(File.expand_path("../../log/test.log", __FILE__), 'a')
logfile.sync = true

logger = Celluloid.logger = Logger.new(logfile)

Celluloid.shutdown_timeout = 1 


class Celluloid::Actor
  # Important that these two are left out, or else
  # timeout calls inside the actor scope will never propagate
  # to the proper extensions
  # TODO: eventually remove this if celluloid adopts the gem
  undef_method :timeout if instance_methods(false).include?(:timeout)
  undef_method :sleep if instance_methods(false).include?(:sleep)
end


RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  config.before do
    Celluloid.logger = logger
    if Celluloid.running?
      Celluloid.shutdown
      sleep 0.01
      Celluloid.internal_pool.assert_inactive
    end

    Celluloid.boot

    FileUtils.rm("/tmp/cell_sock") if File.exist?("/tmp/cell_sock")
    include Timeout::Extensions
  end

  config.order = 'random'
end

class ExampleActor
  include Celluloid
  execute_block_on_receiver :wrap

  def wrap
    yield
  end
end

def within_actor(&block)
  actor = ExampleActor.new
  actor.wrap(&block)
ensure
  actor.terminate if actor and actor.alive?
end


