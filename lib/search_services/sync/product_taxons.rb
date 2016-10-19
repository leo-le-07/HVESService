module SearchServices
  module Sync
    class ProductTaxons < Sync::Base

      def initialize(product_taxons, config)
        @product_taxons = product_taxons
        super(config)
      end

      def documents
        @documents ||= SearchServices::Documents::ProductTaxon.new(@product_taxons)
      end
      
    end
  end
end
