module ElasticsearchServices
  module Builders
    module QueryDsl
      class SuggestProduct
        include Constants
        # {  terms: 'table'}
        attr_reader :query
        def initialize(query = {})
          @query = query
          @term = query[:term]
          @query_fields = ['searchable_name^4', 'searchable_vendor_name^2', 'searchable_description']
        end

        def query_body
          {
            function_score: {
              query: {
                filtered: {
                  query: {
                    multi_match: {
                      query: @term,
                      type: 'best_fields',
                      fuzziness: 2,
                      prefix_length: [@term.to_s.length - 1, 0].max,
                      fields: @query_fields
                    }
                  },
                  filter: {
                    bool: {
                      must: []
                    }
                  }
                }
              },
              functions: [
                {
                  filter: {
                    query: {
                      query_string: {
                        query: @term,
                        fields: @query_fields
                      }
                    }
                  },
                  weight: 2
                }
              ]
            }
          }
         end
      end
    end
  end
end
