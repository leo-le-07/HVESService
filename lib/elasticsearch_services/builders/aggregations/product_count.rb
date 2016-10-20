module ElasticsearchServices
  module Builders
    module Aggregations
      class ProductCount
        attr_reader :field_name, :size

        def initialize(taxon_ids)
          @taxon_ids = taxon_ids
        end

        def aggs
          @taxon_ids.each_with_object({}) do |taxon_id, aggs_taxons|
            aggs_taxons[taxon_id] = aggs_item(taxon_id)
          end
        end

        private

        def aggs_item(taxon_id)
          {
            filter: { term: { taxon_hiptruck_ids: taxon_id } },
            aggs: {
              product_count: { value_count: { field: 'hiptruck_id' } }
            }
          }
        end
      end
    end
  end
end
