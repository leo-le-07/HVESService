module ElasticResultServices
  class SuggestProduct < Base

    def suggester
      data.map do |item|
        {
          name: item.name,
          url: format_product_url(item.relative_url),
          image: (item.images[0].thumbnail rescue ''),
          price: item.min_price_of_product_variant
        }
      end
    end

    def format_product_url(url)
      url.to_s.start_with?('/') ? url : "/#{url}"
    end

  end
end
