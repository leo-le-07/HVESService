module ElasticsearchServices
  class Taxon < Base
    def initialize(params)
      super(params)
      @per_page =  @query[:hiptruck_ids].size if @query[:hiptruck_ids]
      @highlight = params[:highlight]
      @source = params[:_source] || default_source
    end

    def process
      @body ||= body
      LoggerServices::Logger.info 'query taxon'
      LoggerServices::Logger.info @body
      @response = @client.search(index: SEARCH_INDEX,
                                 type: SEARCH_TAXONS_INDEX,
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
        query: ElasticsearchServices::Builders::QueryDsl::TaxonBody.new(@query).query_body,
        from: (@current_page - 1) * @per_page,
        size: @per_page,
        highlight: @highlight,
        _source: @source
      }.compact
    end

    def default_source
      '*'
    end
  end
end
