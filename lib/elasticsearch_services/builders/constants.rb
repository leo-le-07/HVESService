module ElasticsearchServices
  module Builders
    module Constants
      PRICE_FILTER_OPTIONS = [-1, 0, 50, 70, 100, 150, 250, 500, 750, 1000]

      MAPPING_PROPERTIES = {
        price: 'min_price_of_product_variant',
        relevance: '_score',
        delivery: 'shipping_duration',
        collection: 'taxon_hiptruck_ids',
        brand: 'taxon_hiptruck_ids',
        hiptruck_id: 'hiptruck_id',
        collection_get_id: 'shopify_id',
        collection_filter_id: 'hiptruck_id',
        featured: 'product_taxons.featured_position',
        best_selling: 'product_taxons.sold_in_the_last'
      }

      DELIVERY_TIME_RANGE = {
        'all': [],
        '3-5-days': ['3 - 5 days'],
        '5-7-days': ['5 - 7 days'],
        '1-2-weeks': ['1 - 2 weeks', '10 - 14 days'],
        '2-3-weeks': ['2 - 3 weeks'],
        '3-4-weeks': ['3 - 4 weeks'],
        '4-5-weeks': ['4 - 5 weeks'],
        '5-6-weeks': ['5 - 6 weeks']
      }
    end
  end
end
