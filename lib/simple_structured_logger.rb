require 'logger'
require 'singleton'

module SimpleStructuredLogger
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

    def expand_context(&block)
      if block.nil?
        @expand_context = block
      else
        @expand_context
      end
    end

    def expand_log(&block)
      if block.nil?
        @expand_log = block
      else
        @expand_log
      end
    end
  end

  class Writer
    include Singleton

    attr_reader :default_tags

    def initialize
      @l = ::Logger.new(STDOUT)
      @default_tags = {}
    end

    def reset_context!
      @default_tags = {}
    end

    def set_context(context)
      reset_context!

      if self.respond_to?(:expand_context)
        context = self.expand_context(context)
      end

      @default_tags.merge!(context)
    end

    def error(msg, opts={})
      @l.error("#{msg}: #{stringify_tags(opts)}")
    end

    def info(msg, opts={})
      @l.info("#{msg}: #{stringify_tags(opts)}")
    end

    def debug(msg, opts={})
      @l.debug("#{msg}: #{stringify_tags(opts)}")
    end

    def warn(msg, opts={})
      @l.warn("#{msg}: #{stringify_tags(opts)}")
    end

    private

      def stringify_tags(additional_tags)
        additional_tags = additional_tags.dup

        if self.respond_to?(:expand_log)
          additional_tags = self.expand_log(additional_tags)
        end

        @default_tags.merge(additional_tags).map { |k,v| "#{k}=#{v}" }.join(' ')
      end

  end
end
