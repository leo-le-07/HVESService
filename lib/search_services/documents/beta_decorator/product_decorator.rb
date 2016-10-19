module SearchServices
  module Documents
    module BetaDecorator
      class ProductDecorator < SimpleDelegator

        def to_json_for_create
          { index: { _id: id, data: fields } }
        end

        def to_json_for_delete
          { delete: { _id: id } }
        end

        private

        def fields
          { hiptruck_id: id,
            searchable_name: name.normalize,
            name: name,
            more_details: more_details,
            description: description,
            searchable_description: searchable_description,
            handle: handle,
            video: video.to_s,
            relative_url: relative_url,
            total_variants_stock: total_variants_stock,
            inventory_consigned: inventory_consigned,
            searchable_vendor_name: hipvan_vendor.try(:name).try(:normalize),
            vendor_name: hipvan_vendor.try(:name),
            vendor_id: hipvan_vendor.try(:id),
            tags: tag_list,
            taxon_hiptruck_ids: taxon_hiptruck_ids,
            images: images,
            product_variants_ids: product_variants_ids,
            product_properties: product_properties_json,
            product_type: product_type,
            fast_shipping: fast_shipping?,
            sold_out: sold_out?,
            sale_off: sale_off,
            shipping_duration: custom_shipping_duration,
            min_price_of_product_variant: min_price_of_product_variant,
            product_variant_default_id: default_product_variant.id,
            compare_at_price_of_product_variant: compare_at_price_of_product_variant,
            product_taxons: nested_product_taxons,
            seo_data: product_seo_decorator.seo_data,
            option_name: option_name,
            rich_content_enabled: rich_content_enabled,
            rich_content: rich_content,
            buyer_info: buyer_info,
            brand_or_first_taxon_handle: brand_or_first_taxon_handle,
            brand_collection: brand_collection
          }
        end

        def option_name
          product_options.map(&:option_name).join("-")
        end

        def custom_shipping_duration
          ProductServices::CalculateEstimatedArrival.new(self).get
        end

        def product_seo_decorator
          @product_seo_decorator ||= SEOServices::ProductDecorator.new(self)
        end

        def searchable_description
          ActionView::Base.full_sanitizer.sanitize(description)
        end

        def nested_product_taxons
          product_taxons.select(&:visible?).map do |product_taxon|
            { hiptruck_collection_id: product_taxon.taxon_id,
              featured_position: product_taxon.position,
              sold_in_the_last:  sold_in_the_last_60_days,
              brand_collection: product_taxon.taxon.present? ? product_taxon.taxon.brand_taxon? : false
            } if product_taxon.taxon.try(:visible?)
          end.compact
        end

        def relative_url
          "products/#{handle}"
        end

        def total_variants_stock
          @total_variants_stock ||= visible_product_variants.sum(&:stock)
        end

        def sale_off
          compare_at_price = default_product_variant.compare_at_price
          return 0.0 if compare_at_price.blank? || compare_at_price == 0
          sale_off_percentage = (((compare_at_price - default_product_variant.price).to_f/compare_at_price.to_f) * 100)
          (sale_off_percentage / 5).round * 5 #round to the closest 5
        end

        def fast_shipping?
          ProductPolicies::ShippingDuration.new(visible_product_variants).fast_shipping?
        end

        def sold_out?
          total_variants_stock == 0 ? true : false
        end

        def inventory_consigned
          @inventory_consigned ||= inventory_of_visible_variants.sum{ |inv| inv.stock + inv.consigned }
        end

        def default_product_variant
          @default_product_variant ||= visible_product_variants.min_by{ |variant| variant.price }
        end

        def min_price_of_product_variant
          default_product_variant.price.try(:to_f)
        end

        def compare_at_price_of_product_variant
          default_product_variant.compare_at_price.try(:to_f)
        end

        def images
          live_product_images.select {|pi| pi.src.present? }.map do |pi|
            image_urls_builder.build_for(pi.src)
          end
        end

        def taxon_hiptruck_ids
          taxons.select(&:visible?).map(&:id)
        end

        def product_properties_json
          @product_properties ||= product_properties.each_with_object({}) do |product_property, hash|
            hash[product_property.property_key] = product_property.value
          end
        end

        def product_variants_ids
          visible_product_variants.map(&:id)
        end

        def image_urls_builder
          @image_urls_builder ||= CDNServices::ImageUrlBuilderFactory.create
        end

        def visible_product_variants
          ProductVariantServices::FetchVisibleProductVariants.new(product_variants).get
        end

        def inventory_of_visible_variants
          visible_product_variants.map(&:inventory).compact
        end

        def buyer_info
          buyer = hipvan_vendor.try(:hipvan_buyer)
          return {} if buyer.blank?
          SearchServices::Documents::BetaDecorator::BuyerDecorator
            .new(buyer)
            .data_for_product_document
        end

        def brand_or_first_taxon_handle
          (taxons.find(&:brand_taxon?) || taxons.first).try(:handle).to_s
        end

        def brand_collection
          brand_taxons = taxons.select(&:brand_taxon?)
          return {} if brand_taxons.blank?
          brand_collection = CollectionServices::BrandCollectionFinder
                             .new(brand_taxons, product_properties_json[:brand])
                             .get
          return {} if brand_collection.blank?
          {
            name: brand_collection.name,
            brand_url: "/collections/#{brand_collection.handle}"
          }
        end
      end
    end
  end
end
