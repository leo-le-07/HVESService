module SearchServices
  module Sync
    class Pages < Sync::Base
      def initialize(page, config)
        @page = page
        super(config)
      end

      def documents
        @documents ||= SearchServices::Documents::Page.new(@page)
      end
    end
  end
end
