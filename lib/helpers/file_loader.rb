module Helpers
  module FileLoader
    def require_all(_dir)
      Dir[File.expand_path(File.join(File.dirname(File.absolute_path(__FILE__)), _dir)) + "/**/*.rb"].each do |file|
        require file
      end
    end

    module_function :require_all
  end
end