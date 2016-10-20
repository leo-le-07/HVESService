module ElasticResultServices
  class ProductAggregation
    include ActionView::Helpers::NumberHelper

    ImageAdapters = Struct.new(:product_item_grid, :taxon_children)

    def initialize(response, image_adapters)
      @default_option = { title: 'All', value: 'all' }
      @image_adapters = image_adapters
      @response = response
    end

    def aggregations
      [filter_estimate_delivery, filter_price, filter_collection_brand, max_price]
    end

    private

    def filter_estimate_delivery
      {
        key: 'estimated_delivery',
        name: 'Estimated Delivery',
        options: delivery_options
      }
    end

    def filter_collection_brand
      {
        key: 'brand',
        name: 'Brand',
        options: collection_options
      }
    end

    def filter_price
      {
        key: 'price_range',
        name: 'Price',
        options: price_options
      }
    end

    def max_price
      {
        key: 'max_price',
        name: 'Max Price',
        options: @response.aggregations.try(:max_price)
      }
    end

    def delivery_options
      options = [@default_option]
      return options if @response.aggregations.nil?

      sort_option = sort_delivery_options(@response.aggregations.delivery_options.buckets)
      sort_option.map do |item|
        options << {
          title: item[:key],
          value: item[:key],
          doc_count: item[:doc_count]
        } if item[:doc_count] > 0 && item[:key].present?
      end
      options
    end

    # sort delivery string
    # day -> week
    # small -> large
    def sort_delivery_options(delivery_options)
      delivery_options.sort! do |x, y|
        arrange_string(x['key']) <=> arrange_string(y['key'])
      end
    rescue
      delivery_options
    end

    # arrange for sort
    # '1 - 2 days' -> 'days1 -2 '
    # '2 - 3 weeks' -> 'weeks2 - 3 '
    def arrange_string(string)
      string.gsub(/(.*)(weeks|days)/, '\2\1')
    end

    def collection_options
      options = [@default_option]
      collection_names.each do |k, v|
        options << {
          title: v,
          value: k
        }
      end
      options
    end

    def collection_names
      @brand_names ||= begin
        return {} if @response.aggregations.nil?

        taxon_ids = @response.aggregations.collection_options.buckets.map { |x| x[:key] }
        params_search = { query: { hiptruck_ids: taxon_ids, taxon_template_id: 2 }, per_page: taxon_ids.size }
        search = ElasticsearchServices::Taxon.new(params_search)
        search.process
        if search.error
          {}
        else
          results = ElasticResultServices::Taxon.new(search.response, taxon_image_adapters)
          results.hash_brand_names
        end
      end
    end

    def taxon_image_adapters
      @taxon_image_adapters ||= ElasticResultServices::Taxon::ImageAdapters.new( nil, @image_adapters.taxon_children, @image_adapters.product_item_grid )
    end

    def price_options
      ranges = []
      return ranges if @response.aggregations.nil?

      @response.aggregations.price_ranges.buckets.each do |k, v|
        ranges << {
          title: format_range(v[:from_as_string], v[:to_as_string]),
          value: k,
          doc_count: v[:doc_count]
        } if v[:doc_count] > 0
      end
      ranges
    end

    def format_range(from_as_string, to_as_string)
      return '' if from_as_string.nil? && to_as_string.nil?

      if from_as_string.to_f == -1.0
        'All'
      elsif to_as_string.nil?
        "Over #{currency_string(from_as_string)}"
      elsif from_as_string.to_f == 0.0
        "Under #{currency_string(to_as_string)}"
      elsif from_as_string && to_as_string
        "#{currency_string(from_as_string)} to #{currency_string(to_as_string)}"
      end
    end

    def currency_string(price)
      number_to_currency(price, precision: 2)
    end

  end
end
