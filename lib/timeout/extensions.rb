require 'timeout/version'
require 'timeout/extensions'

class Thread
  attr_accessor :timeout_handler
  attr_accessor :sleep_handler

  def self.enhance_for_concurrency!
    yield Thread.current if block_given?
  end
end

module Timeout::Extensions
  def self.extended(mod)
    mod.singleton_class.class_eval do
      alias_method :timeout_without_handler, :timeout
      alias_method :timeout, :timeout_with_handler
    end
  end

  def timeout_with_handler(*args, &block)
    if timeout_handler = Thread.current.timeout_handler
      timeout_handler.call(*args, &block)
    else
      timeout_without_handler(*args, &block)
    end
  end
  module_function :timeout_with_handler
  public :timeout_with_handler
end

module Kernel::Extensions
  def self.included(mod)
    mod.class_eval do
      alias_method :sleep_without_handler, :sleep
      alias_method :sleep, :sleep_with_handler
    end
  end

  def sleep_with_handler(*args)
    if sleep_handler = Thread.current.sleep_handler
      sleep_handler.call(*args)
    else
      sleep_without_handler(*args)
    end
  end
end

Timeout.extend Timeout::Extensions
include Kernel::Extensions

