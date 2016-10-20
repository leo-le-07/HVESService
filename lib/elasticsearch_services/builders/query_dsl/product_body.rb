module ElasticsearchServices
  module Builders
    module QueryDsl
      class ProductBody
        attr_reader :query
        include Constants
        def initialize(query)
          @query = query
          @query_fields = ['searchable_name^10', 'searchable_vendor_name^2', 'searchable_description']
        end

        def query_body
          if filter? && @query[:taxon_id]
            filter_by_taxon_id(@query[:taxon_id], @query[:filter])
          elsif @query[:taxon_id]
            query_by_taxon_id(@query[:taxon_id])
          elsif @query[:terms]
            query_by_term(@query[:terms], @query[:filter])
          elsif @query[:handle]
            query_by_handle(@query[:handle])
          elsif @query[:hiptruck_ids]
            query_by_ids(@query[:hiptruck_ids])
          elsif @query[:vendor_ids]
            query_by_vendor_ids(@query[:vendor_ids])
          elsif @query[:taxon_hiptruck_ids]
            query_by_taxon_hiptruck_ids(@query[:taxon_hiptruck_ids])
          elsif @query[:all]
            { match_all: {} }
          else
            { term: { hiptruck_id: '-1' } }
          end
        end

        private

        def filter?
          @query[:filter] &&
            ((@query[:filter][:brand] != 'all') ||
            (@query[:filter][:price_range] != '-1.0-*') ||
            (@query[:filter][:estimated_delivery] != 'all'))
        end

        def query_by_handle(handle)
          {
            term: {
              handle: handle
            }
          }
        end

        def query_by_taxon_id(taxon_id)
          {
            function_score: {
              query: {
                filtered: {
                  filter: {
                    bool: {
                      must: [
                        {
                          terms: {
                            taxon_hiptruck_ids: taxon_id.is_a?(Array) ? taxon_id : [taxon_id]
                          }
                        }
                      ]
                    }
                  }
                }
              }
            }
          }
        end

        def filter_by_taxon_id(taxon_id, filter)
          {
            function_score: {
              query: {
                filtered: {
                  filter: {
                    bool: {
                      must: ElasticsearchServices::Builders::QueryDsl::ProductFilter.new(taxon_id, filter).filters
                    }
                  }
                }
              }
            }
          }
        end

        def query_by_term(query_string, filter)
          {
            function_score: {
              query: {
                filtered: {
                  query: {
                    multi_match: {
                      query: query_string,
                      type: 'best_fields',
                      fuzziness: 2,
                      prefix_length: [query_string.to_s.length - 1, 0].max,
                      fields: @query_fields
                    }
                  },
                  filter: {
                    bool: {
                      must: ElasticsearchServices::Builders::QueryDsl::ProductFilter.new(nil, filter).filters
                    }
                  }
                }
              },
              functions: [
                {
                  filter: {
                    query: {
                      query_string: {
                        query: query_string,
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

        def query_by_ids(hiptruck_ids)
          {
            filtered: {
              filter: {
                terms: {
                  hiptruck_id: hiptruck_ids
                }
              }
            }
          }
        end

        def query_by_vendor_ids(vendor_ids)
          {
            filtered: {
              filter: {
                terms: {
                  vendor_id: vendor_ids
                }
              }
            }
          }
        end

        def query_by_taxon_hiptruck_ids(taxon_ids)
          {
            filtered: {
              filter: {
                terms: {
                  taxon_hiptruck_ids: taxon_ids
                }
              }
            }
          }
        end

      end
    end
  end
end
