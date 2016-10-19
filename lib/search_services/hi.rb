require 'elasticsearch'

module SearchServices
  class Hi
    def process
      # client = Elasticsearch::Client.new log: true
      # client.cluster.health
      # client.index index: 'my-index', type: 'my-document', id: 1, body: {title: 'Test', summary: 'test summary'}
      # client.indices.refresh index: 'my-index'
      # client.search index: 'my-index', body: {query: {match: {title: 'test'}}}
      'hello v3'
    end
  end
end