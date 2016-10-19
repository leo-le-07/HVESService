module SearchServices
  module Sync
    class SiteConfigurations < Sync::Base

      def initialize(site_config, search_config)
        @site_config = site_config
        super(search_config)
      end

      def documents
        @site_config_documents ||= SearchServices::Documents::SiteConfiguration.new(@site_config)
      end

    end
  end
end
