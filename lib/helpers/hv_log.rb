require 'logger'

module Helpers
  module HvLog
    def log
      @logger ||= create_logger
    end

    module_function :log

    private

    def create_logger
      logger = Logger.new(STDOUT)
      logger.level = Logger::DEBUG
      logger.datetime_format = '%Y-%m-%d %H:%M:%S '
      logger
    end

    module_function :create_logger
  end
end