module ElasticsearchServices
  class UrlRedirect < Base

    def process
      @body ||= body
      LoggerServices::Logger.info 'query taxon'
      LoggerServices::Logger.info @body
      @response = @client.search(index: SEARCH_INDEX,
                                 type: SEARCH_URL_REDIRECTS_INDEX,
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
        query: query_params,
        _source: [:new_url]
      }.compact
    end

    def query_params
      {
        filtered: {
          filter: {
            term: {
              old_url: old_url_param
            }
          }
        }
      }
    end

    def old_url_param
      @query[:old_url]
    end
  end
end
