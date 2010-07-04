require 'package'

class Packages
  class << self

    # Find and load all package .rb files
    def load_packages
      pattern = File.expand_path(File.join("..", "*.rb"), File.dirname(__FILE__)) 
      Dir[pattern].each {|f| puts "Found #{f}"; load f}
    end
  end
end
