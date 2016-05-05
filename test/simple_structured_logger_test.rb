require 'test_helper'

class SimpleStructuredLoggerTest < Minitest::Test
  include SimpleStructuredLogger

  def test_logging_stdout
    log.info("hey", foo: "bar")
    log.error("hey", foo: "bar")
    log.debug("hey", foo: "bar")
    log.warn("hey", foo: "bar")
  end

  def text_expand_context
    #code
  end

  def test_expand_log
    #code
  end
end
