require 'byebug'
require 'helpers/file_loader'

ROOT_PATH = File.expand_path '../..', __FILE__

Helpers::FileLoader.require_all(ROOT_PATH + '/lib')

module HVESService
  Blog = Struct.new(:id, :title, :hidden) do
    def hidden?
      hidden
    end
  end

  def syn(blogs)
    Helpers::LogHelper.info 'I like so I print'

    # blogs = []
    # blogs.push(Blog.new(1, 'Title blog hidden', true))
    # blogs.push(Blog.new(2, 'Title blog not hidden', false))

    @search_config = SearchServices::Config.for_blog
    SearchServices::Sync::Blogs.new(blogs, @search_config).process
    
    # SearchServices::Hi.new().process
  end

  module_function :syn
end
