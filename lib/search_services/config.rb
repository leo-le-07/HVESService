module SearchServices
  module Config
    SearchConfig = Struct.new(:index_type, :beta_client) do
      search_beta_config = {
        host: 'http://localhost:9200',
        retry_on_failure: true,
        log: true,
        trace: true,
        transport_options: { request: { timeout: 250 } }
      }

      def beta_client
        Elasticsearch::Client.new(search_beta_config)
      end
    end

    module_function

    def for_blog
      @config_blog ||= "blogs"
    end
  end
end
