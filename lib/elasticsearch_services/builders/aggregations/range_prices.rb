module ElasticsearchServices
  module Builders
    module Aggregations
      class RangePrices
        include Constants
        def ranges
          price_ranges = []
          PRICE_FILTER_OPTIONS.each_with_index do |price, index|
            price_ranges << range(index, price)
          end
          price_ranges
        end

        def range(index, price)
          return { from: price } if price == -1
          PRICE_FILTER_OPTIONS[index + 1].nil? ? { from: price } : { from: price, to: PRICE_FILTER_OPTIONS[index + 1] }
        end
      end
    end
  end
end
