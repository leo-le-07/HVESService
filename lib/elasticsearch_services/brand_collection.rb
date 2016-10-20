module ElasticsearchServices
  class BrandCollection
    def initialize(product_elasticsearch)
      @brand_collection_ids = brand_collection_id(product_elasticsearch)
    end

    def brand
      if @brand_collection_ids.size >= 1 #@brand_collection_ids.size == 1
        search_brand(@brand_collection_ids)
      # elsif @brand_collection_ids.size >= 2
      #   response = ElasticsearchServices::Product.new(params_search).process
      #   response.aggregations
      #
      else
        nil
      end
    end

    def search_brand(brand_ids)
      response = Searchers::TaxonSearcher.new('', {
        query: {
          hiptruck_ids: brand_ids,
        }
      }).search
      response.data.first
    end

    def params_search
      {
        query: {
          taxon_hiptruck_ids: @brand_collection_ids
        },
        page: 0,
        per_page: 0,
        excludes: ['sort'],
        platform: 'desktop-web'
      }
    end

    private
    def brand_collection_id(product_elasticsearch)
      product_elasticsearch.product_taxons.select { |x| x.brand_collection }.map {|x| x.hiptruck_collection_id }.presence ||
      [product_elasticsearch.product_taxons[0].try(:hiptruck_collection_id)].compact
    end

  end
end
