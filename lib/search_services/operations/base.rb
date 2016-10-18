module SearchServices
  module Operations
    class Base

      def initialize(documents, index_type, elastic_client)
        @documents = documents
        @index_type = index_type
        @elastic_client = elastic_client
      end

      def process
        raise NotImplementedError
      end
      
    end
  end
end
