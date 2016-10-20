module ElasticsearchServices
  module Builders
    module QueryDsl
      class BlogBody
        attr_reader :query

        def initialize(query, params = {})
          @query = query
          @search_type = params[:type]
          puts @query.inspect
        end

        def query_body
          if @query[:handle]
            query_by_handle(@query[:handle])
          elsif @query[:category_handle]
            query_by_categories(@query[:category_handle])
          elsif @query[:exclude_handle]
            query_by_exclude_handle(@query[:exclude_handle])
          elsif @search_type == :sitemap
            all_blogs_query
          else
            query_default
          end
        end

        private

        def query_by_handle(handle)
          {
            terms: {
              handle: Array(handle)
            }
          }
        end

        def query_by_categories(category_handle)
          {
            filtered: {
              query: {
                nested: {
                  path: 'categories',
                  query: {
                    bool: {
                      must: [ { terms: { 'categories.handle': Array(category_handle) } } ]
                    }
                  }
                }
              },
              filter: [
                bool: {
                  must: [
                    { range: { published_at: { lte: Time.current.end_of_day }} },
                    { term: { visibility: 'visible' } }
                  ]
                }
              ]
            }
          }
        end

        def query_by_exclude_handle(handle)
          {
            function_score: {
              query: {
                bool: {
                  must: {
                    nested: {
                      path: 'categories',
                      query: {
                        terms: {
                          'categories.handle': [
                            Settings.static_data.blog_categories.live_better.popular_posts.handle
                          ]
                        }
                      }
                    }
                  },
                  must_not: {
                    term: { handle: handle }
                  }
                }
              },
              functions: [
                {
                  random_score: {}
                }
              ]
            }
          }
        end

        def all_blogs_query
          {
            filtered: {
              filter: [
                bool: {
                  must: [
                    { range: { published_at: { lte: Time.current.end_of_day }} },
                    { term: { visibility: 'visible' } }
                  ]
                }
              ]
            }
          }
        end

        def query_default
          {
            filtered: {
              query: {
                bool: {
                  must_not: {
                    nested: {
                      path: 'categories',
                      query: {
                        terms: {
                          'categories.handle': excluded_category_handles
                        }
                      }
                    }
                  }
                }
              },
              filter: [
                bool: {
                  must: [
                    { range: { published_at: { lte: Time.current.end_of_day }} },
                    { term: { visibility: 'visible' } }
                  ]
                }
              ]
            }
          }
        end

        def excluded_category_handles
          [
            Settings.static_data.blog_categories.live_better.interior_designers.handle,
            Settings.static_data.blog_categories.live_better.find_pros.handle
          ]
        end
      end
    end
  end
end
