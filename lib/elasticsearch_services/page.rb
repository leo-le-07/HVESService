module ElasticsearchServices
  class Page < Base
    def initialize(params)
      super(params)
    end

    def search_type
      SEARCH_PAGES_INDEX
    end

    def body
      @body ||= begin
        query_dsl = { from:   (@current_page - 1) * @per_page,
                      size:    @per_page,
                      _source: '*'
                    }
        query_dsl[:query] = ElasticsearchServices::Builders::QueryDsl::PageBody.new(condition_query).query_body
        query_dsl.compact
      end
    end

    private

    def condition_query
      {
        handle: @query[:handle]
      }
    end

  end
end
