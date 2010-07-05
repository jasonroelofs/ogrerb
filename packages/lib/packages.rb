require 'package'

class Packages
  class << self

    def add(key, package)
      @packages ||= {}
      @packages[key] = package
    end

    def find(key)
      @packages[key]
    end

    # Find and load all package .rb files
    def load_packages
      pattern = File.expand_path(File.join("..", "*.rb"), File.dirname(__FILE__)) 
      Dir[pattern].each {|f| load f}
    end
  end
end
