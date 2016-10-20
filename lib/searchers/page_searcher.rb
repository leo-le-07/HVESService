module Searchers
  class PageSearcher
    def initialize(device_type, search_conditions)
      @device_type = device_type
      @search_conditions = search_conditions
    end

    def search
      search = ElasticsearchServices::Page.new(@search_conditions)
      search.process

      if search.error
        nil
      else
        response = ElasticResultServices::Page.new(search.response, nil, current_page: search.current_page, per_page: search.per_page)
        response
      end
    end
  end
end
