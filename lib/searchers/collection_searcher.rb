module Searchers
  class CollectionSearcher
    def initialize(device_type, search_conditions, current_customer = nil)
      @device_type = device_type
      @search_conditions = search_conditions
      @current_customer = current_customer
      @taxon ||= find_taxon
      breadcrumbs if @taxon
    end

    def search
      if @taxon.nil?
        nil
      else
        {
          collection_banner: @taxon.taxon_banner,
          breadcrumb: breadcrumbs,
          taxon: @taxon,
          children_taxons: children_taxons,
          paging_data: product_search[:paging_data],
          products: product_search[:products],
          aggregations: product_aggregations,
          total_orders: OrderServices::TotalOrders.new.count,
          rich_contents: @taxon.rich_contents
        }
      end
    end

    private

    def product_search
      @products ||= begin
        Rails.logger.info params_search_product
        response = Searchers::ProductSearcher.new(
          device_type: @device_type,
          search_conditions: params_search_product,
          current_customer: @current_customer
        ).search
        {
          paging_data: response.nil? ? {} : response.paging_data,
          products: response.nil? ? [] : response.data
        }
      end
    end

    def product_aggregations
      response = Searchers::ProductSearcher.new(
        device_type: @device_type,
        search_conditions: params_aggregations_products
      ).search
      response.aggregations
    end

    def breadcrumbs
      @breadcrumbs ||= ElasticsearchServices::TaxonBreadcrumb.new(@taxon).breadcrumbs
    end

    def children_taxons
      response = Searchers::TaxonSearcher.new(@device_type, params_children_taxons).search
      # sort by position taxon
      data = response.data.each do |x|
        x.position = hash_children_taxons_positions[x.hiptruck_id]
      end
      data.sort! { |x, y| x.position <=> y.position }
      data
    end

    def find_taxon
      response = Searchers::TaxonSearcher.new(@device_type, params_search_taxon).search
      response.nil? ? nil : response.data.first
    end

    def params_search_taxon
      {
        query: { handle: @search_conditions[:query][:handle] }
      }
    end

    def params_search_product
      {
        query: { taxon_hiptruck_id: @taxon.hiptruck_id },
        sort: @search_conditions[:sort],
        page: @search_conditions[:page],
        per_page: @search_conditions[:per_page] || ElasticsearchServices::Base::DEFAUT_SIZE,
        filter: @search_conditions[:filter],
        excludes: ['aggregations']
      }
    end

    def params_aggregations_products
      {
        query: { taxon_hiptruck_id: @taxon.hiptruck_id },
        page: 0,
        per_page: 0
      }
    end

    def params_children_taxons
      {
        query: { hiptruck_ids: hash_children_taxons_positions.keys },
        page: 0,
        per_page: hash_children_taxons_positions.size
      }
    end

    def hash_children_taxons_positions
      @children_taxons_positions ||= begin
        if @taxon.children_taxons.present?
          Hash[@taxon.children_taxons.map { |x| [x[:hiptruck_collection_id], x.position] }]
        elsif @breadcrumbs[-2][:children_taxons] && @device_type != PlatformServices::DeviceType::MOBILE_APP
          Hash[@breadcrumbs[-2][:children_taxons].map { |x| [x[:hiptruck_collection_id], x.position] }]
        else
          { -1 => -1 }
        end
      end
    end
  end
end
