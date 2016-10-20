module ElasticsearchServices
  module Builders
    module QueryDsl
      class ProductSort
        include Constants

        def sort(type, collection_id = nil)
          case type.to_s.to_sym
          when :best_selling
            sort_by_best_seller(collection_id)
          when :price_asc
            sort_by_price('asc')
          when :price_desc
            sort_by_price('desc')
          when :featured_desc
            sort_by_feature(collection_id, 'desc')
          when :featured_asc
            sort_by_feature(collection_id, 'asc')
          when :fast_shipping
            sort_by_fast_shipping(collection_id, 'desc')
          else
            ['_score']
          end
        end

        private

        def sort_by_best_seller(collection_id, order = 'desc')
          if collection_id
            [
              {
                'product_taxons.sold_in_the_last': {
                  order: order,
                  nested_path: 'product_taxons',
                  nested_filter: {
                    term: {
                      'product_taxons.hiptruck_collection_id': collection_id
                    }
                  }
                }
              },
              '_score'
            ]
          else
            [
              {
                'product_taxons.sold_in_the_last': {
                  order: order,
                  nested_path: 'product_taxons'
                }
              },
              '_score'
            ]
          end
        end

        def sort_by_feature(collection_id, order = 'asc')
          if collection_id
            [
              {
                'product_taxons.featured_position': {
                  order: order,
                  nested_path: 'product_taxons',
                  nested_filter: {
                    term: {
                      'product_taxons.hiptruck_collection_id': collection_id
                    }
                  }
                }
              },
              '_score'
            ]
          else
            [
              {
                'product_taxons.featured_position': {
                  order: order,
                  nested_path: 'product_taxons'
                }
              },
              '_score'
            ]
          end
        end

        def sort_by_price(order)
          [
            { min_price_of_product_variant: order },
            '_score'
          ]
        end

        def sort_by_fast_shipping(collection_id, order)
          if collection_id
            [
              { fast_shipping: order },
              {
                'product_taxons.sold_in_the_last': {
                  order: 'asc',
                  nested_path: 'product_taxons',
                  nested_filter: {
                    term: {
                      'product_taxons.hiptruck_collection_id': collection_id
                    }
                  }
                }
              },
              '_score'
            ]
          else
            [
              { fast_shipping: order },
              {
                'product_taxons.sold_in_the_last': {
                  order: 'asc',
                  nested_path: 'product_taxons'
                }
              },
              '_score'
            ]
          end
        end
      end
    end
  end
end
