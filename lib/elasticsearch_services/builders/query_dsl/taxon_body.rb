module ElasticsearchServices
  module Builders
    module QueryDsl
      class TaxonBody
        attr_reader :query
        def initialize(query = {})
          @query = query
          @handle = query[:handle] || query[:handles]
          @terms = query[:terms]
          @hiptruck_ids = query[:hiptruck_ids]
          @children_taxons = query[:children_taxons]
          @taxon_template_id = query[:taxon_template_id]

          @query_fields = ['searchable_name^2', 'long_description']
        end

        def query_body
          if @handle.present?
            query_by_handle
          elsif @terms
            query_by_term
          elsif @taxon_template_id && @hiptruck_ids
            query_brands_by_ids
          elsif @hiptruck_ids
            query_by_ids
          elsif @children_taxons
            query_by_childrent_taxons
          else
            { match_all: {} }
          end
        end

        private

        def query_by_term
          {
            function_score: {
              query: {
                filtered: {
                  query: {
                    multi_match: {
                      query: @terms,
                      type: 'best_fields',
                      fuzziness: 2,
                      prefix_length: [@terms.length - 1, 0].max,
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
                        query: @terms,
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

        def query_by_handle
          {
            filtered: {
              filter: {
                terms: {
                  handle: @handle.is_a?(Array) ? @handle : [@handle]
                }
              }
            }
          }
        end

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

        def query_by_childrent_taxons
          {
            nested: {
              path: 'children_taxons',
              query: {
                terms: {
                  hiptruck_collection_id: @children_taxons
                }
              }
            }
          }
        end

        def query_brands_by_ids
          {
            filtered: {
              filter: {
                bool: {
                  must: [
                    { term: { taxon_template_id: @taxon_template_id } },
                    { terms: { hiptruck_id: @hiptruck_ids } }
                  ]
                }
              }
            }
          }
        end
      end
    end
  end
end
