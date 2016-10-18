module SearchServices
  module Sync 
    class Base

      def initialize(config)
        @config = config
      end

      def process
        sync_to_beta
      end

      def documents
        raise NotImplementedError
      end

      private

      def sync_to_beta
        SearchServices::Operations::BulkUpdate.new(for_destroy_beta, @config.index_type, @config.beta_client).process if for_destroy_beta.present?
        SearchServices::Operations::BulkUpdate.new(for_create_or_update_beta, @config.index_type, @config.beta_client).process if for_create_or_update_beta.present?
      end

      def for_destroy_beta
        @for_destroy ||= documents.for_destroy_beta
      end

      def for_create_or_update_beta
        @for_create_or_update_beta ||= documents.for_create_or_update_beta
      end

    end
  end
end
