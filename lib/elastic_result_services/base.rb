module ElasticResultServices
  class Base
    attr_reader :response
    def initialize(response)
      @response = Hashie::Mash.new(response)
    end

    def data
      @response.hits.hits.map(&:_source)
    end

    def hits
      @response.hits.hits
    end

    def total
      @response.hits.total
    end

    def max_score
      @response.max_score
    end

    def aggregations
      @response.aggregations
    end

    def took
      @response.took
    end

    def current_page
      @current_page
    end

    def per_page
      @per_page
    end

    def paging_data
      {
        current_page: current_page,
        per_page: per_page,
        total: total
      }
    end
  end
end
