module ElasticsearchServices
  module Builders
    module Aggregations
      class MaxPrice
        def initialize(field_name)
          @field_name = field_name
        end

        def aggs
          {
            max: {
              field: @field_name
            }
          }
        end
      end
    end
  end
end
