module SearchServices
  module Sync
    class Products < Sync::Base

      def initialize(products, config)
        @products = products
        super(config)
      end

      def documents
        @documents ||= SearchServices::Documents::Product.new(@products)
      end
      
    end
  end
end
