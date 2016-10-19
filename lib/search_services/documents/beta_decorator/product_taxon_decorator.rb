module SearchServices
  module Documents
    module BetaDecorator
      class ProductTaxonDecorator < SimpleDelegator

        def to_json_for_create
          { index: { _id: id, data: fields } }
        end

        def to_json_for_delete
          { delete: { _id: id } }
        end
        
        private

        def fields
          { hiptruck_id: id,
            product_id: product_id,
            collection_id: taxon_id,
            featured_position: position,
            sold_in_the_last: product.sold_in_the_last_60_days }
        end

      end 
    end
  end
end
