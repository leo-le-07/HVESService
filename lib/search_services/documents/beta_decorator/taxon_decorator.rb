module SearchServices
  module Documents
    module BetaDecorator
      class TaxonDecorator < SimpleDelegator

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
            shopify_id: shopify_id,
            name: name,
            searchable_name: name.normalize,
            handle: self.handle.to_s,
            taxon_description_image_src: taxon_description_image_src,
            taxon_featured_image_src: taxon_featured_image_src,
            taxon_description_quote_image_src: taxon_description.try(:quote_image_src).to_s,
            relative_url: collection_relative_url,
            taxon_description_quote_intro: taxon_description.try(:quote_intro).to_s,
            taxon_description_quote_by: taxon_description.try(:quote_by).to_s,
            short_description: short_description,
            long_description: long_description,
            children_taxons: children_taxons,
            created_at: created_at,
            published_at: published_at,
            taxon_template_id: taxon_template_id,
            is_root_category: root_cat?,
            seo_data: taxon_seo_decorator.seo_data,
            taxon_banner: taxon_banner,
            rich_contents: custom_rich_contents
         }
        end

        def taxon_seo_decorator
          @taxon_seo_decorator ||= SEOServices::TaxonDecorator.new(self)
        end

        def taxon_description_image_src
          if (src = taxon_description.try(:image_src)).present?
            image_urls_builder.build_for(src)
          end
        end

        def taxon_featured_image_src
          image_urls_builder.build_for(taxon_image_src) if taxon_image_src.present?
        end

        def taxon_banner
          cdn_images_url_builder_for_collection_banner.build_for(banner_url.to_s) if banner_url.present?
        end

        def taxon_template_id
          taxon_description.try(:template_id).to_i
        end

        def root_cat?
          category.root_category?
        end

        def children_taxons
          category.children.map do |child_category|
            { position: child_category.position,
              hiptruck_collection_id: child_category.taxon.id }
          end
        end

        def collection_relative_url
          relative_url_for(self)
        end

        def relative_url_for(taxon)
          "collections/#{taxon.handle}"
        end

        def short_description
          ActionView::Base.full_sanitizer.sanitize(taxon_description.try(:short_description).to_s)
        end

        def long_description
          ActionView::Base.full_sanitizer.sanitize(taxon_description.try(:long_description).to_s)
        end

        def image_urls_builder
          @image_urls_builder ||= CDNServices::ImageUrlBuilderFactory.create
        end

        def cdn_images_url_builder_for_collection_banner
          @cdn_images_url_builder_for_collection_banner ||= CDNServices::ImageUrlBuilderFactory.create_builder_for_collection_banner
        end

        def custom_rich_contents
          rich_contents.sort_by_oldest_taxon_top.map { |rc| { position: rc.position, body_html: rc.body_html } }
        end
      end
    end
  end
end
