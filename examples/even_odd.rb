require 'timeout/extensions'

module MyAwesomeJob 
  def self.perform
    timeout(2) do
      sleep 3 # perform incredibly heavy job
    end
  rescue => e
    puts "job failed: #{e.message}"
  end
end

module MyOwnTimeout
  CustomTimeoutError = Class.new(RuntimeError)
  def self.call(sec, *)
    puts "pretending to wait for #{sec} seconds..."
    yield
  end
end


5.times.map do |i|
  Thread.start do
    Thread.current.timeout_handler = MyOwnTimeout if i.odd?
    MyAwesomeJob.perform
  end
end.map(&:join)

