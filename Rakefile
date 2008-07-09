#!/usr/bin/env ruby

# Setup some global Ogre.rb information
OGRE_RB_ROOT = File.expand_path(File.dirname(__FILE__))

# Need to run through the 'wrappers' dir, looking for wrapping projects
# and setup rake tasks as needed

def build_tasks_for(lib, path)
  namespace lib do
    desc "Build the #{lib} wrapper"
    task :build do
      ruby File.join(path, "build_#{lib}.rb")
    end
  end
end

Dir["wrappers/**/*.rake"].each do |f| 
  load f 

  build_tasks_for File.basename(f, ".rake"), File.dirname(f)
end
