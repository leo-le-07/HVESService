module SearchServices
  module Sync
    class Blogs < Sync::Base

      def initialize(blog, config)
        @blog = blog
        super(config)
      end

      def documents
        @documents ||= SearchServices::Documents::Blog.new(@blog)
      end

    end
  end
end
