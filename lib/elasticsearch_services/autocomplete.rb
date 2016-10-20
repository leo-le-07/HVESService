module ElasticsearchServices
  class Autocomplete < Base
    def process
      @body ||= body
      puts "\e[32m query taxon \e[0m"
      puts "\e[32m#{@body}\e[0m"
      @response = @client.search(index: SEARCH_INDEX,
                                 type: [SEARCH_TAXONS_INDEX, SEARCH_PRODUCT_INDEX],
                                 body: @body
                                )

    rescue Faraday::ConnectionFailed => e
      @error = e.message
      puts "\e[31m#{e.backtrace}\e[0m"
    end

    def body
      {
        query: ElasticsearchServices::Builders::QueryDsl::Autocomplete.new(@query).query_body,
        from: (@current_page - 1) * @per_page,
        size: @per_page
      }
    end
  end
end
