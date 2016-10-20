module ElasticsearchServices
  module Builders
    module QueryDsl
      class VariantBody
        include Constants
        # { handle: 'mid-century-modern-furniture', terms: 'table'}
        attr_reader :query

        def initialize(query = {})
          @query = query
          @hiptruck_ids = query[:hiptruck_ids]
        end

        def query_body
          if @hiptruck_ids
            query_by_ids
          else
            { "match_all": {} }
          end
        end

        private

        def query_by_ids
          {
            filtered: {
              filter: {
                terms: {
                  hiptruck_id: @hiptruck_ids
                }
              }
            }
          }
        end
      end
    end
  end
end
