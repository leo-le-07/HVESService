module ElasticsearchServices
  module Builders
    module QueryDsl
      class PageBody
        attr_reader :query

        def initialize(query)
          @query = query
        end

        def query_body
          if @query[:handle]
            query_by_handle(@query[:handle])
          else
            query_default
          end
        end

        private

        def query_by_handle(handle)
          {
            filtered: {
              query: {
                terms: {
                  handle: Array(handle)
                }
              },
              filter: [
                bool: {
                  must: [
                    { range: { published_at: { lte: Time.current.end_of_day } } }
                  ]
                }
              ]
            }
          }
        end

        def query_default
          { match_all: {} }
        end
      end
    end
  end
end
