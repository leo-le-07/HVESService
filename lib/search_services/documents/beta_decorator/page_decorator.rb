module SearchServices
  module Documents
    module BetaDecorator
      class PageDecorator < SimpleDelegator

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
            page_title: name,
            handle: handle,
            published_at: published_at,
            visibility: visibility,
            body_html: body_html,
            searchable_body: searchable_body,
            user_id: user_id,
            author: user.name,
            created_at: created_at,
            updated_at: updated_at,
            seo_data: {},
            main_image: main_image
          }
        end

        def searchable_body
          # ActionView::Base.full_sanitizer.sanitize(body_html)
          {}
        end

        def main_image
          # main_picture.present? ? image_urls_builder.build_for(main_picture.src) : {}
          {}
        end

        def image_urls_builder
          @image_urls_builder ||= CDNServices::ImageUrlBuilderFactory.create
        end

        def page_seo_decorator
          @page_seo_decorator ||= SEOServices::PageDecorator.new(self.seo_info)
        end

      end
    end
  end
end
