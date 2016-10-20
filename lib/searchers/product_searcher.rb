module Searchers
  class ProductSearcher

    def initialize(device_type: PlatformServices::DeviceType::DESKTOP, search_conditions: , current_customer: nil)
      @device_type = device_type
      @search_conditions = search_conditions
      @current_customer = current_customer
    end

    def search
      search = ElasticsearchServices::Product.new(search_conditions_with_default_params)
      search.process

      if search.error
        nil
      else
        response = ElasticResultServices::Product.new(search.response, product_image_adapters, { current_page: search.current_page, per_page: search.per_page, current_customer: @current_customer, device_type: @device_type })
        response
      end
    end


    private

    def product_image_adapters
      _PLATFORM_FACTORY = ImageServices::PlatformAdaptive::Factory

      @product_image_adapters ||= ElasticResultServices::Product::ImageAdapters.new(
        _PLATFORM_FACTORY.get(@device_type, _PLATFORM_FACTORY::PRODUCT_ITEM_GRID),
        nil,
        _PLATFORM_FACTORY.get(@device_type, _PLATFORM_FACTORY::PRODUCT_DETAIL)
      )
    end

    def search_conditions_with_default_params
      conditions_with_default = @search_conditions.clone
      conditions_with_default[:sort] = conditions_with_default[:sort].presence || 'featured_asc'
      conditions_with_default[:filter] = Hash(conditions_with_default[:filter].presence)
      conditions_with_default[:filter][:estimated_delivery] = conditions_with_default[:filter][:estimated_delivery].presence || 'all'
      conditions_with_default[:filter][:price_range] = conditions_with_default[:filter][:price_range].presence || '-1.0-*'
      conditions_with_default[:filter][:brand] = conditions_with_default[:filter][:brand].presence || 'all'
      conditions_with_default
    end

  end
end
