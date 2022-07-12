require_relative 'test_helper'
require 'ostruct'

class SimpleStructuredLoggerTest < Minitest::Test
  include SimpleStructuredLogger

  def teardown
    SimpleStructuredLogger.configure do
      @expand_context = nil
      @expand_log = nil
    end

    ENV.delete('LOG_LEVEL')
  end

  def capture_logs(&block)
    out = StringIO.new
    log.logger.reopen(out)

    yield

    log.logger.reopen(STDOUT)
    out.string
  end

  def test_logging_stdout
    log.info("hey", foo: "bar")
    log.error("hey", foo: "bar")
    log.debug("hey", foo: "bar")
    log.warn("hey", foo: "bar")
  end

  def test_expand_context
    SimpleStructuredLogger.configure do
      expand_context do |context|
        # you can pass in a object and use `expand_context` to extract the relevant keys
        if context[:user]
          context[:user_id] = context[:user].id
          context[:user_name] = context[:user].name
          context.delete(:user)
        end

        context
      end
    end

    user = OpenStruct.new(id: 1, name: "mike")
    log.set_context(user: user, other: 'argument')

    out = capture_logs do
      log.info "core"
    end

    assert_match("user_id=1", out)
    assert_match("user_name=mike", out)
    assert_match("other=argument", out)
  end

  def test_expand_log
    SimpleStructuredLogger.configure do
      expand_log do |tags, default_tags|
        if tags[:stripe_resource] && tags[:stripe_resource].respond_to?(:id)
          stripe_resource = tags.delete(:stripe_resource)
          tags[:stripe_resource_id] = stripe_resource.id
          tags[:stripe_resource_type] = stripe_resource.class.to_s
        end

        tags
      end
    end

    stripe_resource = OpenStruct.new(id: 'cus_123')

    out = capture_logs do
      log.error "core", stripe_resource: stripe_resource
    end

    assert_match("core: stripe_resource_id=cus_123 stripe_resource_type=OpenStruct\n", out)
  end

  def test_environment_level
    log.logger.level = Logger::ERROR

    out = capture_logs do
      log.debug 'should be empty'
    end

    assert_empty(out)

    ENV['LOG_LEVEL'] = 'DEBUG'

    log.set_log_level_from_environment

    out = capture_logs do
      log.debug 'should exist'
    end

    assert_match('should exist', 'should exist')

    # we don't care about case
    ENV['LOG_LEVEL'] = 'error'
    log.set_log_level_from_environment
    assert_equal(Logger::ERROR, log.logger.level)
  end
end
