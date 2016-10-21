require 'logger'

module Helpers
  module LogHelper
    COLORS = {
      black: 30,
      blue:  34,
      yellow: 33,
      cyan: 36,
      green: 32,
      magenta: 35,
      red: 31,
      white: 37
    }

    def info(message, code = nil)
      color = COLORS.fetch(code.to_s.to_sym, 32)
      log.info "\e[#{color}m#{cover_message(message)}\033[0m"
    end

    def fatal(e, options = {})
      log.fatal "\e[#{COLORS[:red]}m#{e.message}\033[0m"
      log.fatal "\e[#{COLORS[:red]}m#{e.backtrace}\033[0m"
    end

    module_function :info, :fatal

    private

    def log
      @logger ||= create_logger
    end

    def create_logger
      logger = ::Logger.new(STDOUT)
      logger.level = ::Logger::DEBUG
      logger.datetime_format = '%Y-%m-%d %H:%M:%S '
      logger
    end

    def cover_message(message)
      if message.is_a?(String)
        message
      elsif message.is_a?(Hash)
        message.to_json
      else
        message.inspect
      end
    end

    module_function :log, :create_logger, :cover_message
  end
end