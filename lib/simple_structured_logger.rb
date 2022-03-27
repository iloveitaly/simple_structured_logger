require 'logger'
require 'singleton'

module SimpleStructuredLogger
  def self.configure(&block)
    SimpleStructuredLogger::Configuration.instance_eval(&block)
  end

  def self.logger
    SimpleStructuredLogger::Writer.instance.logger
  end

  def log
    SimpleStructuredLogger::Writer.instance
  end

  def self.included(klass)
    # TODO there's got to be a cleaner way to add a class method from `include`
    klass.class_eval do
      def self.log
        SimpleStructuredLogger::Writer.instance
      end
    end
  end

  module Configuration
    extend self

    @expand_context = nil
    @expand_log = nil

    def expand_context(&block)
      if block.nil?
        @expand_context
      else
        @expand_context = block
      end
    end

    def expand_log(&block)
      if block.nil?
        @expand_log
      else
        @expand_log = block
      end
    end
  end

  class Writer
    include Singleton

    attr_accessor :default_tags, :logger

    def initialize
      @logger = ::Logger.new(STDOUT)
      @default_tags = {}

      set_log_level_from_environment
    end

    # returns true if log level is set from env
    def set_log_level_from_environment
      env_log_level = ENV['LOG_LEVEL']

      if !env_log_level.nil? && Logger::Severity.const_defined?(env_log_level.upcase)
        @logger.level = Logger::Severity.const_get(env_log_level.upcase)
        true
      else
        false
      end
    end

    def reset_context!
      @default_tags = {}
    end

    def set_context(context)
      reset_context!

      if SimpleStructuredLogger::Configuration.expand_context
        context = SimpleStructuredLogger::Configuration.expand_context.call(context)
      end

      @default_tags.merge!(context)
    end

    def error(msg, opts={})
      @logger.error("#{msg}: #{stringify_tags(opts)}")
    end

    def info(msg, opts={})
      @logger.info("#{msg}: #{stringify_tags(opts)}")
    end

    def debug(msg, opts={})
      @logger.debug("#{msg}: #{stringify_tags(opts)}")
    end

    def warn(msg, opts={})
      @logger.warn("#{msg}: #{stringify_tags(opts)}")
    end

    private def stringify_tags(additional_tags)
      additional_tags = additional_tags.dup

      if SimpleStructuredLogger::Configuration.expand_log
        additional_tags = SimpleStructuredLogger::Configuration.expand_log.call(additional_tags, self.default_tags)
      end

      @default_tags.merge(additional_tags).map {|k, v| "#{k}=#{v}" }.join(' ')
    end

  end
end
