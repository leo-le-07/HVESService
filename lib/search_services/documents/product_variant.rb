module SearchServices
  module Documents
    class ProductVariant < Documents::Base
      
      def initialize(product_variants)
        super(product_variants)
      end

      def decorator_for_beta
        BetaDecorator::ProductVariantDecorator
      end

    end
  end
end
