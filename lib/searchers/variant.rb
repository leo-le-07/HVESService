module Searchers
  class Variant < Base

    def search
      search_service.process
      search_service.response
    end

    def format_search_result_for(raw_data)
      ElasticResultServices::Variant.new(raw_data)
    end

    def search_service
      @search_service ||= ElasticsearchServices::Variant.new(@search_conditions)
    end

  end
end
