module ElasticsearchServices
  module Builders
    module Aggregations
      class RangeAgg
        def initialize(field_name, keyed, ranges)
          @field_name = field_name
          @keyed = keyed
          @ranges = ranges
        end

        def aggs
          {
            range: {
              field: @field_name,
              keyed: @keyed,
              ranges: @ranges
            }
          }
        end
      end
    end
  end
end
