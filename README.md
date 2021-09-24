[![Ruby](https://github.com/iloveitaly/simple_structured_logger/actions/workflows/ruby.yml/badge.svg)](https://github.com/iloveitaly/simple_structured_logger/actions/workflows/ruby.yml)
[![gem](https://img.shields.io/gem/v/simple_structured_logger.svg)](https://rubygems.org/gems/simple_structured_logger)

# SimpleStructuredLogger

Dead-simple structured logging in ruby with a dead-simple codebase. No dependencies, everything logs to stdout, and simple hooks to customize. That's it.

```ruby
gem 'simple_structured_logger'
```

## Design Goals

* Extremely simple codebase that's easy to read and override
* Structured logging that reads nicely
* Ability to easily set context, and expand context with user-configurable hook
* Ability to easily add structured log pre-processing. I want to be able to pass
  in an object specific to my application and for the relavent important keys to
  be expanded automatically.
* `Rails.logger = SimpleStructuredLogger.new(STDOUT)`
* Not designed around massive systems or scale
* Don't support multiple log destinations
* Don't build in fancy pre-processing for errors or other common ruby objects

### Opinionated Devops Setup

* Errors are tracked using Rollbar, Airbrake, Sentry, etc.
* Log to STDOUT
* Pipe STDOUT to PaperTrail, Loggly, etc
* Great for Heroku or [dokku/docker](http://mikebian.co/sending-dokku-container-logs-to-papertrail/) hosted system

## Alternatives

* https://github.com/jordansissel/ruby-cabin
* https://github.com/asenchi/scrolls
* https://github.com/stripe/chalk-log
* https://github.com/nishidayuya/structured_logger
* https://github.com/rocketjob/semantic_logger

## Why is structured logging important?

* https://engineering.linkedin.com/distributed-systems/log-what-every-software-engineer-should-know-about-real-time-datas-unifying
* http://juliusdavies.ca/logging.html

## What about Rail's tagged logging?

Tagged logging is not structured logging. I want to be able to search through
PaperTrail and easily grab an audit trail for a specific context, i.e. `the_job=FailingJob the_user=1`.

## Usage

```ruby
# config/initializers/logger.rb
if Rails.env.development? || Rails.env.test?
  SimpleStructuredLogger::Writer.instance.logger = Rails.logger
end

# models/order.rb
class Order
  include SimpleStructuredLogger

  def initialize
    log.reset_context!
    log.default_tags[:global] = 'key'
  end

  def do_something
    log.info 'simple structured logging', key: value, shopify_id: 123
  end
end
```

## Testing

```
bundle exec rake
```
