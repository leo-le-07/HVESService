module ElasticsearchServices
  module Builders
    module Aggregations
      class Product
        include Constants
        def initialize(aggregations = [])
          @aggregations = aggregations.blank? ? default_aggregations : aggregations
        end

        def aggs
          @aggregations.each_with_object({}) do |item, aggregation_names|
            aggregation_names[item] = send(item)
          end
        end

        private

        def delivery_options
          Term.new(MAPPING_PROPERTIES[:delivery], 200).aggs
        end

        def price_ranges
          ranges = RangePrices.new.ranges
          RangeAgg.new(MAPPING_PROPERTIES[:price], true, ranges).aggs
        end

        def collection_options
          Term.new(MAPPING_PROPERTIES[:collection], 200).aggs
        end

        def brand_options
          Term.new(MAPPING_PROPERTIES[:brand], 200).aggs
        end

        def max_price
          MaxPrice.new(MAPPING_PROPERTIES[:price]).aggs
        end

        def default_aggregations
          %w(price_ranges delivery_options collection_options max_price)
        end
      end
    end
  end
end
