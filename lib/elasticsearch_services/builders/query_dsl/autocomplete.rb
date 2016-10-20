module ElasticsearchServices
  module Builders
    module QueryDsl
      class Autocomplete
        include Constants
        attr_reader :query
        def initialize(query = {})
          @query = query
          @terms = query[:terms]
        end

        def query_body
        end

        private

        def query_suggester
        end
      end
    end
  end
end
