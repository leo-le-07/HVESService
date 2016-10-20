module ElasticsearchServices
  class SuggestProduct < Base
    DEFAUT_FROM = 0
    DEFAUT_SIZE = 3
    def process
      @body ||= body
      LoggerServices::Logger.info 'suggest product'
      LoggerServices::Logger.info @body
      @response = @client.search(index: SEARCH_INDEX,
                                 type: SEARCH_PRODUCT_INDEX,
                                 body: @body
                                )
      LoggerServices::Logger.info "took #{@response['took']} ms"
      @response
    rescue StandardError => e
      @error = e.message
      LoggerServices::Logger.fatal(e)
    end

    def body
      {
        query: ElasticsearchServices::Builders::QueryDsl::SuggestProduct.new(@query).query_body,
        from: DEFAUT_FROM,
        size: DEFAUT_SIZE
      }
    end
  end
end
