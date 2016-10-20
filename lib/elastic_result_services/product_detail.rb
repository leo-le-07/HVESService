module ElasticResultServices
  class ProductDetail < Base
    ImageAdapters = Struct.new(:product_detail, :product_item_grid)

    def initialize(response, image_adapters, current_customer = nil, device_type = PlatformServices::DeviceType::MOBILE_APP)
      @product_setting = Settings.product_detail
      @image_adapters = image_adapters
      @current_customer = current_customer
      @device_type = device_type
      super(response)
    end

    def data
      format_product_data
    end

    def collection_brand
      ElasticsearchServices::BrandCollection.new(@response.hits.hits.map(&:_source).first).brand
    end

    private

    def product_data
      @product_data ||= @response.hits.hits.map(&:_source).first
    end

    def format_product_data
      format_shipping_info
      format_product_variants
      format_product_same_vendors
      format_product_images
      format_product_zoom_image
      generate_social_share_link
      add_wishlist_info
      product_data
    end

    def format_product_images
      product_data.detail_images = product_data
                                   .images
                                   .map { |img| @image_adapters.product_detail.select(img) }.uniq
    end

    def format_product_zoom_image
      product_data.zoom_images = product_data
                                 .images
                                 .map { |img| img['cdn_full_size'] }.uniq
    end

    def format_product_same_vendors
      product_data.products_same_vendor = recommended_products
    end

    def format_product_variants
      product_data.product_variants = search_product_variant
    end

    def format_shipping_info
      product_data.shipping_info = ProductDetailServices::ShippingInfo.new(product_data, @device_type).get
    end

    def add_wishlist_info
      product_data.is_added_to_wishlist = begin
        @current_customer ? CustomerServices::Wishlist.new(@current_customer).include?(product_data.product_variants_ids) : false
      end
    end

    def search_product_variant
      product_variants_params = product_variants_params_for(product_data.product_variants_ids)
      search = ElasticsearchServices::Variant.new(product_variants_params)
      search.process
      product_variants = ElasticResultServices::Variant.new(search.response).data
      product_variants.sort_by(&:position)
    end

    def recommended_products
      return search_product_same_vendor unless Settings.mad_street_dens.enable
      if (product_id = product_id_for(product_data)).present?
        sorted_recommended_result =
          RecommendationServices::MadStreetDens::SortedResult.new(product_id, @current_customer.try(:uid), search_product_image_adapters).get
        return sorted_recommended_result if sorted_recommended_result.present?
      end
      search_product_same_vendor
    end

    def product_id_for(product_data)
       product_data.product_variants.try(:first).try(:product_id)
    end

    def search_product_same_vendor
      @search_product_same_vendor ||= begin
        search = ElasticsearchServices::Product.new(products_same_vendor_params)
        search.process
        ElasticResultServices::Product.new(search.response, search_product_image_adapters, current_customer: @current_customer).data
      end
    end

    def search_product_image_adapters
      @search_product_image_adapters ||= ElasticResultServices::Product::ImageAdapters.new(
        @image_adapters.product_item_grid, nil, @image_adapters.product_detail
      )
    end

    def generate_social_share_link
      product_data.share_link = "#{Settings.store_url}/#{product_data.relative_url}"
    end

    def product_variants_params_for(variant_ids)
      {
        query: {
          hiptruck_ids: variant_ids
        }
      }
    end

    def products_same_vendor_params
      {
        query: {
          vendor_ids: [product_data.vendor_id]
        }
      }
    end
  end
end
