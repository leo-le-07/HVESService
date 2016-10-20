module ElasticResultServices
  class Variant < Base
    def data
      formatted_product_variant_data
    end

    # [ product_variant_hiptruck_id: { product_variant_data }, ...]
    def simple_format_data
      data.inject({}) do |result, pv|
        result[pv[:hiptruck_id]] = pv
        result
      end
    end

    private

    def product_variant_data
      @data ||= @response.hits.hits.map(&:_source)
    end

    def formatted_product_variant_data
      product_variant_data.each do |data|
        data[:only_left] = should_show_only_left_for(data)
        data[:installment_info] = installment_info_for(data)
      end
    end

    def should_show_only_left_for(product_variant)
      product_variant.stock <= Settings.product_detail.only_left_thresold
    end

    def installment_info_for(product_variant)
      should_enable = InstallmentPolicies::ProductVariant.new(product_variant).installment_plan?
      {}.tap do |installment_info|
        if should_enable
          price_per_month = (product_variant.price / 12).round(2)
          installment_info[:installment_12] = price_per_month
          installment_info[:price_per_month] = price_per_month
        end
      end
    end
  end
end
