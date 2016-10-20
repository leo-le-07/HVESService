module ElasticsearchServices
  class Blog < Base
    def initialize(params)
      super(params)
    end

    def search_type
      SEARCH_BLOGS_INDEX
    end

    def body
      @body ||= begin
        query_dsl = { from:   (@current_page - 1) * @per_page,
                      size:    @per_page,
                      _source: sources
                    }
        query_dsl[:query] = ElasticsearchServices::Builders::QueryDsl::BlogBody.new(@query, @params).query_body
        query_dsl[:sort] = ElasticsearchServices::Builders::QueryDsl::BlogSort.new(@params[:sort]).sort if sortable?
        query_dsl.compact
      end
    end

    private

    def sources
      '*'
    end

    def sortable?
      @query.fetch(:exclude_handle, nil).nil?
    end
  end
end
