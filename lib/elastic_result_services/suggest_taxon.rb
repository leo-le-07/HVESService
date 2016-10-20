module ElasticResultServices
  class SuggestTaxon < Base
    def data
      @response.hits.hits
    end

    def suggester(reference)
      data.map do |item|
        {
          name: highlight_name(item),
          url: "/collections/#{item._source.handle}?ref=#{reference}",
          handle: item._source.handle
        }
      end
    end

    def highlight_name(item)
      item.highlight.searchable_name.first.to_s.downcase.presence || item._source.name.to_s.downcase
    rescue
      item._source.name.to_s.downcase
    end
  end
end
