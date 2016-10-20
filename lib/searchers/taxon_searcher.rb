module Searchers
  class TaxonSearcher

    def initialize(device_type, search_conditions)
      @device_type = device_type
      @search_conditions = search_conditions
    end

    def search
      search = ElasticsearchServices::Taxon.new(@search_conditions)
      search.process

      if search.error
        nil
      else
        response = ElasticResultServices::Taxon.new(search.response, taxon_image_adapters, { current_page: search.current_page, per_page: search.per_page })
        response
      end
    end

    private

    def taxon_image_adapters
      _PLATFORM_FACTORY = ImageServices::PlatformAdaptive::Factory
      @image_adapter ||= ElasticResultServices::Taxon::ImageAdapters.new(
        _PLATFORM_FACTORY.get(@device_type, _PLATFORM_FACTORY::TAXON_DETAIL),
        _PLATFORM_FACTORY.get(@device_type, _PLATFORM_FACTORY::TAXON_CHILDREN),
        _PLATFORM_FACTORY.get(@device_type, _PLATFORM_FACTORY::PRODUCT_ITEM_GRID),
        _PLATFORM_FACTORY.get(@device_type, _PLATFORM_FACTORY::TAXON_BANNER)
      )
    end

  end
end
