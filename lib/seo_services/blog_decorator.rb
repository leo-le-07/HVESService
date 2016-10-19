module SEOServices
  class BlogDecorator < SimpleDelegator
    def seo_data
      {
        seo_title: seo_title,
        seo_meta_description: seo_meta_description,
        og_url: og_url,
        og_title: og_title,
        og_description: og_description,
        og_image: seo_image[:cdn_full_size]
      }
    end

    private

    def seo_image
      return {} if og_image.blank?
      image_urls_builder.build_for(og_image)
    end

    def image_urls_builder
      @image_urls_builder ||= CDNServices::ImageUrlBuilderFactory.create_builder_for_blog
    end
  end
end
