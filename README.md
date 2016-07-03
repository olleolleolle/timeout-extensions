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
require 'timeout/extensions'

Timeout.new(30) do
  # Times out after 30 seconds raising Timeout::Error
end
```

However, where `timeout.rb` provides one implementation, the Timeout Gem
provides support for multiple, swappable backends:

```ruby
require 'timeout/extensions'

module MyTimeoutThingy
  # WARNING: don't use this. It's just a strawman example
  def self.timeout(secs)
    current = Thread.current
    sleeper = Thread.start do
      begin
        sleep secs
      rescue => ex
        current.raise ex
      else
        current.raise Timeout::Error, "execution expired" 
      end
    end
    return yield(secs)
  ensure
    if sleeper
      sleeper.kill
      sleeper.join
    end
  end
end

Timeout.backend(MyTimeoutThingy) do
  Timeout.new(30) do
    # Manage timeouts with MyTimeoutThingy instead of timeout.rb
    # Plug in your own backend just this easily!
  end
end
```

# Contributing

* Fork this repository on github
* Make your changes and send us a pull request
* If we like them we'll merge them
* If we've accepted a patch, feel free to ask for commit access

# License

Copyright (c) 2014-2016 Tony Arcieri, Tiago Cardoso
Distributed under the MIT License. See LICENSE.txt for further details.
