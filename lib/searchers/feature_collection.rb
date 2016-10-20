module Searchers
  class FeatureCollection
    DIMENSION = {
      desktop_web: { w: 400, h: 275, q: 85 },
      tablet_web: { w: 400, h: 275, q: 85 },
      mobile_web: { w: 400, h: 275, q: 60 },
      mobile_app: { w: 400, h: 275, q: 60 }
    }
    def initialize(device_type)
      @device_type = device_type
      @handles = Settings.static_data.home_page.featured_collection_handle
    end

    def process
      product_aggregations_by_taxon
    end

    private

    def product_aggregations_by_taxon
      @data = taxons.data
      @data.map! do |taxon|
        taxon.product_count = products_aggregations["#{taxon.hiptruck_id}"]['doc_count']
        taxon.image = crop_image(hard_code_image_for(taxon.handle))
        taxon
      end
      @data.sort_by{ |collection| @handles.index(collection.handle) }
    end

    def taxons
      @search_taxons ||= Searchers::TaxonSearcher.new(@device_type, params_search_taxon).search
    end

    def products_aggregations
      @aggregations ||= Searchers::ProductSearcher.new(
        device_type: @device_type, 
        search_conditions: params_search_product
      ).search.response.aggregations
    end

    def taxon_ids
      taxons.data.map(&:hiptruck_id)
    end

    def params_search_taxon
      {
        query: {
          handles: @handles
        },
        page: 0,
        per_page: @handles.count
      }
    end

    def params_search_product
      {
        query: {
          taxon_hiptruck_ids: taxon_ids
        },
        page: 0,
        per_page: 0,
        aggs_type: 'product_count'
      }
    end

    def crop_image(url)
      uri = URI.parse(url)
      params = Rack::Utils.parse_query(uri.query)
      params['w'] = DIMENSION[@device_type][:w]
      params['h'] = DIMENSION[@device_type][:h]
      params['q'] = DIMENSION[@device_type][:q]
      query = Rack::Utils.build_query(params)
      URI::HTTPS.build(
        host: uri.host,
        path: uri.path,
        query: query
      ).to_s
    end

    def hard_code_image_for(hanlde)
      Settings.static_data.home_page.featured_collection_images[hanlde.underscore]
    end
  end
end
