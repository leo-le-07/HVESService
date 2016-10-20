module ElasticsearchServices
  class SuggestTaxon < Base
    DEFAUT_FROM = 0
    DEFAUT_SIZE = 6
    def process
      @body ||= body
      LoggerServices::Logger.info 'suggest taxon'
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

    def body
      {
        query: ElasticsearchServices::Builders::QueryDsl::SuggestTaxon.new(@query).query_body,
        from: DEFAUT_FROM,
        size: DEFAUT_SIZE,
        highlight: highlight
      }
    end

    private

    def highlight
      {
        pre_tags: ['<b>'],
        post_tags: ['</b>'],
        fields: { searchable_name: { number_of_fragments: 3 } }
      }
    end
  end
end
