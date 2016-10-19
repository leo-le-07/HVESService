module SearchServices
  module Documents
    module BetaDecorator
      class BuyerDecorator < SimpleDelegator
        def data_for_product_document
          {
            id: id,
            email: email,
            image_url: image_url,
            name: buyer_name,
            name_normalize: buyer_name_normalize
          }
        end

        private

        def buyer_name
          buyer_name_replace[name] || name
        end

        def buyer_name_replace
          {
            'Archive' => 'Audree',
            'archive' => 'Audree',
            'Purchasing' => 'Elaine Sitoh',
            'purchasing' => 'Elaine Sitoh'
          }
        end

        def buyer_name_normalize
          buyer_name.to_s.downcase.strip
        end
      end
    end
  end
end
