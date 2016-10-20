module ElasticResultServices
  class Blog < Base
    ImageAdapters = Struct.new(:blog_item_grid, :blog_detail)

    def initialize(response, image_adapters, options = {})
      @image_adapters = image_adapters
      @current_page = options[:current_page]
      @per_page = options[:per_page]
      super(response)
    end

    def data
      build_images_url
      raw_data
    end

    def raw_data
      @raw_data ||= @response.hits.hits.map(&:_source)
    end

    private

    def build_images_url
      return unless @image_adapters.blog_item_grid
      raw_data.each do |blog|
        image = blog.main_image
        blog.thumbnail_image = @image_adapters.blog_item_grid.select(image)
        blog.compact_image = @image_adapters.blog_detail.select(image)
      end
    end
  end
end
