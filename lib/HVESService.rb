require 'helpers/file_loader'

Helpers::FileLoader.require_all('../../lib')

module HVESService
  Blog = Struct.new(:id, :title, :hidden) do
    def hidden?
      hidden
    end
  end

  def syn(blogs)
    Helpers::HvLog.log.info 'I like so I print'

    # blogs = []
    # blogs.push(Blog.new(1, 'Title blog hidden', true))
    # blogs.push(Blog.new(2, 'Title blog not hidden', false))

    @search_config = SearchServices::Config.for_blog
    SearchServices::Sync::Blogs.new(blogs, @search_config).process
    
    # SearchServices::Hi.new().process
  end

  module_function :syn
end
