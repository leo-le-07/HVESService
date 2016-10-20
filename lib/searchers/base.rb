module Searchers
  class Base

    def initialize(device_type:, search_conditions:)
      @device_type = device_type
      @search_conditions = search_conditions
      @img_platform_factory = ImageServices::PlatformAdaptive::Factory
    end

    def process
      raw_data = search
      format_search_result_for(raw_data)
    end

    def search
      raise NotImplementedError
    end

    def format_search_result_for(raw_data)
      raise NotImplementedError
    end

  end
end
