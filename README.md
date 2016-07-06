Timeout::Extensions
===================

[![Gem Version](https://badge.fury.io/rb/timeout-extensions.svg)](http://rubygems.org/gems/timeout-extensions)
[![Build Status](https://secure.travis-ci.org/celluloid/timeout-extensions.svg?branch=master)](http://travis-ci.org/celluloid/timeout-extensions)
[![Code Climate](https://codeclimate.com/github/celluloid/timeout-extensions.svg)](https://codeclimate.com/github/celluloid/timeout-extensions)

The Timeout::Extensions Gem augments Ruby's `timeout.rb` API with support for
multiple timeout backends which can be mixed and matched within a single app.

It supports pluggable timeout implementations which can selectively hook
into multiple backend schedulers rather than resorting to running code in a
separate thread to implement timeouts when there's a better backend available.

## Installation

Add this line to your application's Gemfile:

    gem 'timeout-extensions'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install timeout-extensions

## Usage

The Timeout::Extensions gem enhances the Ruby standard library's
`timeout.rb` API:

```ruby
require 'timeout'

Timeout.timeout(30) do
  # Times out after 30 seconds raising Timeout::Error
end
```

However, where `timeout.rb` provides one implementation, the Timeout Gem
provides support for multiple, swappable backends:

```ruby
require 'timeout/extensions'

module MyAwesomeJob
  def self.perform
    timeout(5) do
      sleep 5 # perform incredibly heavy job
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
    Thread.current.timeout_handler = MyOwnTimeout
    MyAwesomeJob.perform
  end
end.join(&:join)
__END__

pretending to wait for 2 seconds...
pretending to wait for 2 seconds...
job failed: execution expired
job failed: execution expired
job failed: execution expired

```

You can also setup a timeout backend temporarily, for the duration of a block:

```ruby
Timeout.backend(MyTimeoutThingy) do
  Timeout.timeout(30) do
    # Manage timeouts with MyTimeoutThingy instead of timeout.rb
    # MyTimeoutThingy just responds to #call(sec, ex)
    # Plug in your own backend just this easily!
  end
end
```

This library also supports setting your own sleep implementation:

```ruby

Thread.start do
  Thread.current.sleep_handler = YourSleepHandler # must also respond to #call(Integer or nil)
....
```


## Celluloid Support

This gem provides celluloid support out of the box. 

Celluloid has its own actor timeout and sleep methods, which are implemented using the ```timer``` gem and do not block its mailbox. These have to be called inside your celluloid actor context however, thereby limiting the scope of your code:

```ruby
require 'celluloid'

module MyJob
  def self.perform
    puts "performing"
    sleep 5
    puts "performed!"
  end
end

class Worker
  include Celluloid
  
  def develop
    MyJob.perform
  end

  def ten_times_developer
    10.times.each { async(:develop) }
  end
end

Worker.new.async(:ten_times_developer)

sleep
__END__
performing
performed!
performing
performed!
performing
performed!
performing
performed!
performing
performed!
...
```

But if your had the extension in the first line:
```
require 'timeout/extensions/celluloid'
....
__END__
performing
performing
performing
performing
performing
performing
performing
performing
performing
performing
performed!
performed!
performed!
performed!
performed!
....
```

## Supported Ruby Versions

This library aims to support and is [tested against][travis] the following Ruby
versions:

* Ruby 2.1
* Ruby 2.2
* Ruby 2.3
* JRuby 9.1

If something doesn't work on one of these versions, it's a bug.

# Contributing

* Fork this repository on github
* Make your changes and send us a pull request
* If we like them we'll merge them
* If we've accepted a patch, feel free to ask for commit access

# License

Copyright (c) 2014-2016 Tony Arcieri, Tiago Cardoso
Distributed under the MIT License. See LICENSE.txt for further details.
