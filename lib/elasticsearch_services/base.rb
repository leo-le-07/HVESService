module ElasticsearchServices
  class Base
    attr_reader :response, :params, :query, :current_page, :per_page, :error
    MAX_SIZE = 500
    DEFAUT_SIZE = 25
    MIN_PAGE_NUMBER = 1

    def initialize(params)
      @client = Elasticsearch::Client.new(
        host: SEARCH_HOST,
        retry_on_failure: false,
        log: false,
        trace: false,
        request_timeout: 10
      )
      @params = params
      @response = ''
      @query = params[:query] || {}
      @filter = params[:filter] || {}
      @per_page = [MAX_SIZE, params.fetch(:per_page, DEFAUT_SIZE).to_i].min

      @current_page = [MIN_PAGE_NUMBER, params[:page].to_i].max
      @error = nil
    end

    def process
      LoggerServices::Logger.info "query #{search_type}"
      LoggerServices::Logger.info body
      @response = @client.search(index: SEARCH_INDEX,
                                 type:  search_type,
                                 body:  body
                                )
      LoggerServices::Logger.info "took #{@response['took']} ms"
      @response
    rescue StandardError => e
      @error = e.message
      LoggerServices::Logger.fatal(e)
    end

    def search_type
      fail NotImplementedError
    end

    def body
      fail NotImplementedError
    end

    def include_aggs?
      @params[:excludes].nil? ||
        !@params[:excludes].include?('aggregations')
    end

    def include_sort?
      @params[:sort].present?
    end
  end
end
