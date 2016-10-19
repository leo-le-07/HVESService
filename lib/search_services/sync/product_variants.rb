module SearchServices
  module Sync
    class ProductVariants < Sync::Base

      def initialize(variants, config)
        @variants = variants
        super(config)
      end

      def documents
        @documents ||= SearchServices::Documents::ProductVariant.new(@variants)
      end
      
    end
  end
end
