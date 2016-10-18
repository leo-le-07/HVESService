module SearchServices
  module Documents
    class Base

      def initialize(documents)
        @documents = documents
      end

      def decorator_for_beta
        raise NotImplementedError
      end

      def for_destroy_beta
        for_destroy(decorator_for_beta)
      end

      def for_create_or_update_beta
        for_create_or_update(decorator_for_beta)
      end

      private

      def for_destroy(decorator)
        @documents.reject(&:visible?).map{ |document| decorator.new(document).to_json_for_delete }
      end

      def for_create_or_update(decorator)
        @documents.select(&:visible?).map{ |document| decorator.new(document).to_json_for_create }
      end

    end
  end
end
