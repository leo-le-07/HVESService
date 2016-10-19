module SearchServices
  module Documents
    class ProductTaxon < Documents::Base

      def initialize(product_taxons)
        super(product_taxons)
      end

      def decorator_for_beta
        BetaDecorator::ProductTaxonDecorator
      end

    end
  end
end
