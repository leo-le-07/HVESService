module SearchServices
  module Sync
    class Taxons < Sync::Base

      def initialize(taxons, config)
        @taxons = taxons
        super(config)
      end

      def documents
        @taxon_documents ||= SearchServices::Documents::Taxon.new(@taxons)
      end

    end
  end
end
