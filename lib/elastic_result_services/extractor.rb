module ElasticResultServices
  class Extractor

    def initialize(response)
      @response = Hashie::Mash.new(response)
    end

    def sources
      @response.hits.hits.map(&:_source)
    end

  end
end
