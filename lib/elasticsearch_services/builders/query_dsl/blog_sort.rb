module ElasticsearchServices
  module Builders
    module QueryDsl
      class BlogSort
        def initialize(type)
          @type = type.to_s.to_sym
        end

        def sort
          case @type
          when :published_date
            sort_by_published_date
          else
            [{ published_at: 'desc' }]
          end
        end

        private

        def sort_by_published_date
          [{ published_at: 'desc' }]
        end
      end
    end
  end
end
