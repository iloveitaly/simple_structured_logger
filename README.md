[![Ruby](https://github.com/iloveitaly/simple_structured_logger/actions/workflows/ruby.yml/badge.svg)](https://github.com/iloveitaly/simple_structured_logger/actions/workflows/ruby.yml)
[![gem](https://img.shields.io/gem/v/simple_structured_logger.svg)](https://rubygems.org/gems/simple_structured_logger)

# SimpleStructuredLogger

Dead-simple structured logging in ruby with a dead-simple codebase. No dependencies, everything logs to stdout, and simple hooks to customize. That's it.

```ruby
gem 'simple_structured_logger'
```

## Usage

You can use this logger anywhere. Class methods, instance methods, use it as a logger for libraries, etc.

Some examples:

```ruby
# in a console or simple script
include SimpleStructuredLogger
log.info 'core message', key: Time.now.to_i

# in class & instance methods
class LoggingInModule
  include SimpleStructuredLogger

  def self.log_something
    log.info 'including the module enables a class and instance method', key: Time.now.to_i
  end

  def log_something_else
    log.info 'the class and instance method share the same logging context', key: Time.now.to_i
  end
end

# So, how do I set the context? How can I customize how it's set?
SimpleStructuredLogger.configure do
  expand_context do |context|
    # you can pass in a object and use `expand_context` to extract the relevant keys
    if context[:user]
      context[:user_id] = context[:user].id
      context[:user_name] = context[:user].name
    end

    context
  end
end

class ExampleJob
  def perform(user_id)
    user = get_user(user_id, job_argument)
    log.set_context(user: user, job: self.class, job_argument: job_argument)
    log.info 'the log will contain the user_id, job_argument, and job class'

    # you can also add additional default pairs without resetting context
    log.default_tags[:something] = 'else'
  end
end

# Can you pass object arguments as values and automatically expand them? Well, yes, you can!
SimpleStructuredLogger.configure do
  expand_log do |tags, default_tags|
    if tags[:stripe_resource] && tags[:stripe_resource].respond_to?(:id)
      stripe_resource = tags.delete(:stripe_resource)
      tags[:stripe_resource_id] = stripe_resource.id
      tags[:stripe_resource_type] = stripe_resource.class.to_s
    end

    # this is a really nice pattern I like to use. The `metric` key can trigger a call out to your observability tooling
    if tags[:metric]
      dimensions = default_tags.slice(:stripe_user_id, :other_default_tag)
      metrics.track_counter(tags[:metric], dimensions: dimensions)
    end

    tags
  end
end

# want simple formatting? You got it!
SimpleStructuredLogger.logger.formatter = proc do |severity, _datetime, _progname, msg|
  "#{severity}: #{msg}\n"
end

# Configure the logger directly if you need to
SimpleStructuredLogger.logger.level(Logger::INFO)
```

Want to change the log level quickly? Without modifying source?

```shell
LOG_LEVEL=DEBUG ruby your_script.rb

# case does not matter
LOG_LEVEL=info ruby your_script.rb
```

## Design Goals

* Extremely simple codebase that's easy to read and override
* Structured logging that reads nicely and is easy to filter using grep or something like Papertrail
* Ability to easily set context, and expand context with user-configurable hook
* Ability to easily add structured log pre-processing. I want to be able to pass
  in an object specific to my application and for the relevant important keys to
  be expanded automatically.
* `Rails.logger = SimpleStructuredLogger.new(STDOUT)`
* Not designed around massive systems or scale: no JSON logging, multiple log destinations, and other fanciness.
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

## Related

* https://github.com/roidrage/lograge

## Why is structured logging important?

* https://engineering.linkedin.com/distributed-systems/log-what-every-software-engineer-should-know-about-real-time-datas-unifying
* http://juliusdavies.ca/logging.html

## What about Rail's tagged logging?

Tagged logging is not structured logging. I want to be able to search through
PaperTrail/Splunk/etc and easily grab an audit trail for a specific context, i.e. `the_job=FailingJob the_user=1`.

## Testing

```
bundle exec rake
```

## TODO

- [ ] Support logs as blocks?