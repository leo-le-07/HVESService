module SearchServices
  module Documents
    module BetaDecorator
      class ProductVariantDecorator < SimpleDelegator
        def to_json_for_create
          { index: { _id: id, data: fields } }
        end

        def to_json_for_delete
          { delete: { _id: id } }
        end

        private

        def fields
          { hiptruck_id: id,
            searchable_name: name.normalize,
            name: name,
            searchable_title: full_name.normalize,
            title: full_name,
            sku: sku,
            position: position,
            stock: stock,
            product_id: product.id,
            price: formatted_price,
            compare_at_price: formatted_compare_at_price,
            shipping_duration: custom_shipping_duration
          }
        end

        def custom_shipping_duration
          ProductVariantServices::CalculateEstimatedArrival.new(self.product.shipping_info, self).get
        end

        def formatted_price
          price.try(:to_f)
        end

        def formatted_compare_at_price
          compare_at_price.try(:to_f)
        end
      end
    end
  end
end
