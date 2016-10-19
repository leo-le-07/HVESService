module SearchServices
  module Documents
    class Page < Documents::Base
      def initialize(page)
        super(page)
      end

      def decorator_for_beta
        BetaDecorator::PageDecorator
      end

      def for_destroy_beta
        for_destroy(decorator_for_beta)
      end

      def for_create_or_update_beta
        for_create_or_update(decorator_for_beta)
      end

      private

      def for_destroy(decorator)
        @documents.reject(&:visibility?).map { |document| decorator.new(document).to_json_for_delete }
      end

      def for_create_or_update(decorator)
        @documents.select(&:visibility?).map { |document| decorator.new(document).to_json_for_create }
      end
    end
  end
end
