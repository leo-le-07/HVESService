module SearchServices
  module Documents
    class Blog < Documents::Base
      def initialize(blog)
        super(blog)
      end

      def decorator_for_beta
        BetaDecorator::BlogDecorator
      end

      def for_destroy_beta
        for_destroy(decorator_for_beta)
      end

      def for_create_or_update_beta
        for_create_or_update(decorator_for_beta)
      end

      private

      def for_destroy(decorator)
        @documents.select(&:hidden?).map{ |document| decorator.new(document).to_json_for_delete }
      end

      def for_create_or_update(decorator)
        @documents.reject(&:hidden?).map{ |document| decorator.new(document).to_json_for_create }
      end

    end
  end
end
