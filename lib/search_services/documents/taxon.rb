module SearchServices
  module Documents
    class Taxon < Documents::Base
      
      def initialize(taxons)
        super(taxons)
      end

      def decorator_for_beta
        BetaDecorator::TaxonDecorator
      end

    end
  end
end
