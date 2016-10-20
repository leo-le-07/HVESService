module ElasticResultServices
  class Page < Base
    def initialize(response, image_adapters, options = {})
      @image_adapters = image_adapters
      @current_page = options[:current_page]
      @per_page = options[:per_page]
      super(response)
    end

    def data
      @raw_data ||= @response.hits.hits.map(&:_source)
    end

  end
end
