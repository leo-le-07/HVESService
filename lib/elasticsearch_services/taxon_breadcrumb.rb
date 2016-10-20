module ElasticsearchServices
  class TaxonBreadcrumb
    MAX_SEARCH = 2

    def initialize(taxon)
      @breadcrumb = []
      @taxon = taxon
    end

    def breadcrumbs
      if @taxon.is_root_category
        @breadcrumb << { name: @taxon.name, url: format_taxon_url(@taxon.relative_url) }
      else
        build_breadcrumbs
      end
      @breadcrumb << { name: 'Home', url: '/' }
      @breadcrumb.reverse!
      ref_url
    end

    private

    def build_breadcrumbs
      @breadcrumb << breadcrumb(@taxon)
      (0..MAX_SEARCH).each do |_i|
        find_taxon_by_hiptruck_id
        @breadcrumb << breadcrumb(@parent_taxon) if @parent_taxon
        break if @parent_taxon.blank? || @parent_taxon.is_root_category
      end
    end

    def find_taxon_by_hiptruck_id
      @parent_taxon ||= @taxon
      search = ElasticsearchServices::Taxon.new(query: {
                                                  children_taxons: [@parent_taxon.hiptruck_id]
                                                })
      search.process
      @parent_taxon = ElasticResultServices::Extractor.new(search.response).sources.first
    end

    def format_taxon_url(url)
      url.to_s.start_with?('/') ? url : "/#{url}"
    end

    def breadcrumb(taxon)
      {
        name: taxon.name,
        url: format_taxon_url(taxon.relative_url),
        children_taxons: taxon.children_taxons,
        hiptruck_id: taxon.hiptruck_id,
        handle: taxon.handle
      }
    end

    def ref_url
      @breadcrumb[1][:url] = "#{@breadcrumb[1][:url]}?ref=brcrumb_root" if @breadcrumb[1]
      @breadcrumb[2][:url] = "#{@breadcrumb[2][:url]}?ref=brcrumb_main" if @breadcrumb[2]
      @breadcrumb[3][:url] = "#{@breadcrumb[3][:url]}?ref=brcrumb_sub" if @breadcrumb[3]
      @breadcrumb
    end
  end
end
