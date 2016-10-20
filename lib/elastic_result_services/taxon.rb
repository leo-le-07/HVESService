module ElasticResultServices
  class Taxon < Base
    ImageAdapters = Struct.new(:taxon_detail, :taxon_children, :product_item_grid, :taxon_banner)

    def initialize(response, image_adapters, options = {})
      @image_adapters = image_adapters
      @current_page = options[:current_page]
      @per_page = options[:per_page]
      super(response)
    end

    def data
      @data = raw_data
      @data.each do |taxon|
        feature_image_srcs = taxon.taxon_featured_image_src
        taxon.image = @image_adapters.taxon_detail.select(feature_image_srcs)
        taxon.child_image_url = @image_adapters.taxon_children.select(feature_image_srcs)
        taxon.taxon_banner = @image_adapters.taxon_banner.select(taxon.taxon_banner) if taxon.taxon_banner.present?
      end
      @data
    end

    def hiptruck_id
      data.first.try(:hiptruck_id) || -1
    end

    def hash_brand_names
      Hash[raw_data.map { |x| [x.hiptruck_id, x.name] }]
    end

    def raw_data
      ElasticResultServices::Extractor.new(@response).sources
    end
  end
end
