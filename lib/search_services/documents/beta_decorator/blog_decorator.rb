module SearchServices
  module Documents
    module BetaDecorator
      class BlogDecorator < SimpleDelegator

        def to_json_for_create
          { index: { _id: id, data: fields } }
        end

        def to_json_for_delete
          { delete: { _id: id } }
        end

        private

        def fields
          {
            hiptruck_id: id,
            blog_title: title,
            handle: handle,
            blog_relative_url: relative_url,
            published_at: published_at,
            visibility: visibility,
            body_html: body_html,
            searchable_body: searchable_body,
            user_id: user_id,
            author: user.name,
            created_at: created_at,
            updated_at: updated_at,
            seo_data: {},
            main_image: main_image,
            categories: categories
          }
        end

        def relative_url
          "/blog/#{handle}"
        end

        def searchable_body
          # ActionView::Base.full_sanitizer.sanitize(body_html)
          body_html
        end

        def categories
          {}
          # category_list.map{ |item| name_for(item) }
          #               .compact
          #               .map{ |name| json_format_for(name) }
        end

        # def name_for(category)
        #   categories = Cms::Blogs::BlogCategoriesPresenter.categories_object
        #   categories[category.to_sym]
        # end

        def json_format_for(name)
          {
            name: name,
            handle: name.parameterize,
            relative_url: "/blog/#{name.parameterize}"
          }
        end

        def main_image
          {}
          # main_picture.present? ? image_urls_builder.build_for(main_picture.src) : {}
        end

        # def image_urls_builder
        #   @image_urls_builder ||= CDNServices::ImageUrlBuilderFactory.create_builder_for_blog
        # end

        # def blog_seo_decorator
        #   @blog_seo_decorator ||= SEOServices::BlogDecorator.new(self.seo_info)
        # end

      end
    end
  end
end
