module Helpers
  module FileLoader
    def require_all(_dir)
      Dir[_dir + "/**/*.rb"].each do |file|
        require file
      end
    end

    module_function :require_all
  end
end