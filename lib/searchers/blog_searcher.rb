module Searchers
  class BlogSearcher
    def initialize(device_type, search_conditions)
      @device_type = device_type
      @search_conditions = search_conditions
    end

    def search
      search = ElasticsearchServices::Blog.new(@search_conditions)
      search.process

      if search.error
        nil
      else
        response = ElasticResultServices::Blog.new(search.response, blog_image_adapters, current_page: search.current_page, per_page: search.per_page)
        response
      end
    end

    private

    def blog_image_adapters
      _PLATFORM_FACTORY = ImageServices::PlatformAdaptive::Factory
      @image_adapter ||= ElasticResultServices::Blog::ImageAdapters.new(
        _PLATFORM_FACTORY.get(@device_type, _PLATFORM_FACTORY::BLOG_ITEM_GRID),
        _PLATFORM_FACTORY.get(@device_type, _PLATFORM_FACTORY::BLOG_POPULAR)
      )
    end
  end
end
