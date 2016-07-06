require "timeout/extensions"
require "celluloid"
module Celluloid
  # Reopening the thread class to define the time handlers and pointing them to celluloid respective methodsx
  class Thread < ::Thread
    def initialize(*)
      self.timeout_handler = Celluloid.method(:timeout).to_proc
      self.sleep_handler = Celluloid.method(:sleep).to_proc
      super
    end
  end

  ####################
  #
  # Celluloid Monkey-Patch Alert!!!!
  # I would really like to remove this but, but I first need this pull request accepted:
  # https://github.com/celluloid/celluloid/pull/491
  #
  # These methods have kept the same functionality for quite some time, therefore are quite stable,
  # I just moved the locations and updated/corrected the method signatures.
  #
  ###################

  def self.timeout(duration, klass = nil)
    bt = caller
    task = Task.current
    klass ||= TaskTimeout
    timers = Thread.current[:celluloid_actor].timers
    timer = timers.after(duration) do
      exception = klass.new("execution expired")
      exception.set_backtrace bt
      task.resume exception
    end
    yield
  ensure
    timer.cancel if timer
  end

  class Actor
    # Using the module method now instead of doing everything by itself.
    def timeout(*args)
      Celluloid.timeout(*args) { yield }
    end
    private :timeout
  end
end
