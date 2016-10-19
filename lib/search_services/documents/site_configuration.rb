module SearchServices
  module Documents
    class SiteConfiguration < Documents::Base

      CONFIG_KEYS = {
        home_link_list: "home-link-lists",
        home_banner: "home-banner"
      }

      def initialize(site_config)
        @site_config = site_config
      end

      def decorator
        BetaDecorator::SiteConfigurationDecorator
      end
      
      def for_destroy
        [SearchServices::Documents::SiteConfigurationDecorator.new(@site_config).to_json_for_delete]
      end

      def for_create_or_update
        [SearchServices::Documents::SiteConfigurationDecorator.new(@site_config).to_json_for_create]
      end
      
    end
  end
end
