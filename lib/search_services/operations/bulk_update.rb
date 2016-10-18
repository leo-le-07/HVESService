module SearchServices
  module Operations
    class BulkUpdate < Operations::Base

      def process
        puts @documents
        puts "index_type = #{@index_type}. host = #{@elastic_client.transport.hosts}"
        @elastic_client.bulk({
          index: 'hv-test',
          type: @index_type,
          body: @documents })
      end

    end
  end
end
