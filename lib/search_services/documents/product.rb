module SearchServices
  module Documents
    class Product < Documents::Base
      def initialize(products)
        super(products)
      end

      def decorator_for_beta
        BetaDecorator::ProductDecorator
      end

    end
  end
end
