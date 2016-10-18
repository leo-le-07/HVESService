require 'require_all'
require "HVESService/version"
require 'byebug'

require_all 'lib/search_services'


module HVESService
  def syn(blogs)
    @search_config = SearchServices::Config.for_blog
    SearchServices::Sync::Blogs.new(blogs, @search_config).process
  end

  module_function :syn
end
