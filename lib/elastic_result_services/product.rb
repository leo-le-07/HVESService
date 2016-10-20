module ElasticResultServices
  class Product < Base
    ImageAdapters = Struct.new(:product_item_grid, :taxon_children, :product_detail)

    def initialize(response, image_adapters, options = {})
      @image_adapters = image_adapters
      @current_page = options[:current_page]
      @per_page = options[:per_page]
      @current_customer = options[:current_customer]
      @device_type = options[:device_type]
      super(response)
    end

    def data
      build_images_url
      build_zoom_images_url
      build_detail_images_url
      add_wishlist_info
      build_product_variants
      build_product_shipping_info
      raw_data
    end

    def raw_data
      @raw_data ||= @response.hits.hits.map(&:_source)
    end

    def aggregations
      ElasticResultServices::ProductAggregation.new(@response, product_aggregration_image_adapters).aggregations
    end

    def product_aggregration_image_adapters
      @product_aggregration_image_adapters ||= ElasticResultServices::ProductAggregation::ImageAdapters.new(
        @image_adapters.product_item_grid, @image_adapters.taxon_children )
    end

    private

    def build_product_shipping_info
      raw_data.each do |product|
        product.shipping_info = ProductDetailServices::ShippingInfo.new(product, @device_type).get
      end
    end

    def build_product_variants
      raw_data.each do |product|
        product.product_variants = product[:product_variants_ids].map { |id| product_variant_data[id] }.compact.uniq
      end
    end

    def product_variant_data
      @product_variant_data ||= begin
        search = ElasticsearchServices::Variant.new(product_variants_params)
        search.process
        ElasticResultServices::Variant.new(search.response).simple_format_data
      end
    end

    def product_variants_params
      {
        query: {
          hiptruck_ids: raw_data_product_variants_ids
        },
        per_page: raw_data_product_variants_ids.size
      }
    end

    def raw_data_product_variants_ids
       @product_variants_id ||= raw_data.map(&:product_variants_ids).flatten
    end

    def build_images_url
      return unless @image_adapters.product_item_grid
      raw_data.each do |product|
        product.detail_images = product.images
        product.zoom_images = product.images
        product
          .images
          .map! { |image_sizes_map| @image_adapters.product_item_grid.select(image_sizes_map) }
          .uniq!
      end
    end

    def build_zoom_images_url
      raw_data.each do |product|
        product.zoom_images.map! { |img| img['cdn_full_size'] }
      end
    end

    def build_detail_images_url
      raw_data.each do |product|
        product.detail_images.map! { |image_sizes_map| @image_adapters.product_detail.select(image_sizes_map) }
      end
    end

    def add_wishlist_info
      raw_data.each do |product|
        product.is_added_to_wishlist = begin
          @current_customer ? customer_wishlist.include?(product.product_variants_ids) : false
        end
      end
    end

    def customer_wishlist
      @customer_wishlist ||= CustomerServices::Wishlist.new(@current_customer)
    end
  end
end
