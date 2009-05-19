#!/usr/bin/env ruby
require 'rake/contrib/sshpublisher'

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

RUBYFORGE_USERNAME = "jameskilton"
PROJECT_WEB_PATH = "/var/www/gforge-projects/ogrerb"

namespace :web do
  desc "Build website"
  task :build do |t|
    mkdir_p "publish"
    sh "jekyll --pygment website publish/"
  end

  desc "Update the website" 
  task :upload => "web:build"  do |t|
    Rake::SshDirPublisher.new("#{RUBYFORGE_USERNAME}@rubyforge.org", PROJECT_WEB_PATH, "publish").upload
  end

  desc "Clean up generated website files" 
  task :clean do
    rm_rf "publish"
  end
end
