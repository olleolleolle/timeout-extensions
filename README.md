The Ruby Timeout Gem
====================

Ruby provides `timeout.rb` in its standard library. It provides an elegant API
for timeouts. Unfortunately, it provides only one, nasty backend
implementation with dangerous semantics on any Ruby VM which isn't MRI.

The Timeout Gem attempts to resolve this problem by providing pluggable timeout
implementations which can potentially implement safe timeout semantics by
selectively hooking into backend schedulers rather than resorting to running
code in a separate thread to implement timeouts.

## Installation

Add this line to your application's Gemfile:

    gem 'timeout'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install timeout

## Usage

The Ruby Timeout Gem implements extensions to the Ruby standard library's
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

Copyright (c) 2014 Tony Arcieri. Distributed under the MIT License. See
LICENSE.txt for further details.
