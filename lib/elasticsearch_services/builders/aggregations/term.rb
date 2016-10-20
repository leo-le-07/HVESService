module ElasticsearchServices
  module Builders
    module Aggregations
      class Term
        attr_reader :field_name, :size

        def initialize(field_name, size)
          @field_name = field_name
          @size = size
        end

        def aggs
          {
            terms: {
              field: field_name,
              size: size
            }
          }
        end
      end
    end
  end
end
