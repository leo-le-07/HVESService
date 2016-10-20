module ElasticsearchServices
  class Variant < Base
    def process
      @body ||= body
      LoggerServices::Logger.info 'query product variant'
      LoggerServices::Logger.info @body
      @response = @client.search(index: SEARCH_INDEX,
                                 type: SEARCH_PRODUCT_VARIANT_INDEX,
                                 body: @body
                                )
      LoggerServices::Logger.info "took #{@response['took']} ms"
      @response
    rescue StandardError => e
      @error = e.message
      LoggerServices::Logger.fatal(e)
    end

    private

    def body
      {
        query: ElasticsearchServices::Builders::QueryDsl::VariantBody.new(@query).query_body,
        from: (@current_page - 1) * @per_page,
        size: @per_page,
        _source: default_source
      }
    end

    def default_source
      %w(hiptruck_id product_id name title sku position stock price compare_at_price only_left shipping_duration)
    end
  end
end
