module ElasticsearchServices
  class Product < Base
    def initialize(params)
      super(params)
      @params[:sort] = (@query[:terms] ? 'relevance' : 'featured_asc') if @params[:sort].blank?
      @highlight = params[:highlight]
      @source = params[:_source] || default_source
    end

    def process
      @body ||= body
      LoggerServices::Logger.info 'query product'
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

    private

    def default_source
      '*'
    end

    def body
      query_dsl = {
        from: (@current_page - 1) * @per_page,
        size: @per_page,
        highlight: @highlight,
        _source: @source
      }
      query_dsl[:query] = ElasticsearchServices::Builders::QueryDsl::ProductBody.new(condition_query).query_body
      query_dsl[:aggs] = if params[:aggs_type] == 'product_count'
                           ElasticsearchServices::Builders::Aggregations::ProductCount.new(@query[:taxon_hiptruck_ids]).aggs if @query[:taxon_hiptruck_ids]
                         else
                           ElasticsearchServices::Builders::Aggregations::Product.new.aggs if include_aggs?
                         end

      query_dsl[:sort] = sort_by(@taxon_id) if include_sort?
      query_dsl.compact
    end

    def sort_by(taxon_id)
      ElasticsearchServices::Builders::QueryDsl::ProductSort.new.sort(@params[:sort], taxon_id)
    end

    def condition_query
      @taxon_id ||= taxon_hiptruck_ids

      {
        taxon_id: @taxon_id,
        terms: @query[:terms],
        filter: @filter,
        handle: @query[:handle],
        hiptruck_ids: @query[:hiptruck_ids],
        vendor_ids: @query[:vendor_ids],
        taxon_hiptruck_ids: @query[:taxon_hiptruck_ids],
        all: @query[:all]
      }
    end

    def taxon_hiptruck_ids
      if @query[:taxon_hiptruck_id]
        @query[:taxon_hiptruck_id]
      elsif @query[:collection_handle].nil?
        nil
      else
        search_taxon_by_handle
      end
    end

    def search_taxon_by_handle
      search = ElasticsearchServices::Taxon.new(
        query: { handle: @query[:collection_handle] },
        page: 0,
        per_page: 1
      )
      search.process

      if search.error
        -1
      else
        sources = ElasticResultServices::Extractor.new(search.response).sources
        sources.first.try(:hiptruck_id) || -1
      end
    end
  end
end
