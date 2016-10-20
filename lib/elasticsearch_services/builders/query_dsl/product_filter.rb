module ElasticsearchServices
  module Builders
    module QueryDsl
      class ProductFilter
        include Constants

        def initialize(taxon_id, options = {})
          @options = options
          @delivery = options[:estimated_delivery]
          @brand = options[:brand]
          @taxon_id = taxon_id
          @price_min = price_min
          @price_max = price_max
        end

        def filters
          filter = []
          filter << filter_delivery
          filter << filter_brand
          filter << filter_collection
          filter << filter_range_price
          filter.compact
        end

        def filter_delivery
          return nil if @delivery.blank? || @delivery == 'all'
          filter_term(MAPPING_PROPERTIES[:delivery], @delivery)
        end

        def filter_brand
          return nil if @brand.blank? || @brand == 'all'
          filter_term(MAPPING_PROPERTIES[:brand], @brand)
        end

        def filter_collection
          return nil if @taxon_id.blank?
          filter_term(MAPPING_PROPERTIES[:collection], @taxon_id)
        end

        def filter_range_price
          return nil if @options[:price_range].blank?
          filter_range(MAPPING_PROPERTIES[:price], @price_min, @price_max)
        end

        private

        def filter_range(field, min, max)
          { range: { field.to_sym => range(min, max) } }
        end

        def range(min, max)
          if min.nil?
            { lte: max.to_f }
          elsif max.nil?
            { gte: min.to_f }
          else
            { gte: min.to_f, lte: max.to_f }
          end
        end

        def filter_term(field, value)
          { term: { field.to_sym => value } }
        end

        def price_min
          return nil if @options[:price_range].blank?
          if @options[:price_range] == '-1.0-*'
            0
          else
            @options[:price_range].split('-')[0].to_f
          end
        end

        def price_max
          return nil if @options[:price_range].blank?
          if @options[:price_range] == '-1.0-*'
            nil
          else
            @options[:price_range].split('-')[1] == '*' ? nil : @options[:price_range].split('-')[1].to_f
          end
        end
      end
    end
  end
end
