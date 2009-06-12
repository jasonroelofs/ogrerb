#!/usr/bin/env ruby
require 'rake/contrib/sshpublisher'
require 'lib/rake/wrapper'

# Setup some global Ogre.rb information
OGRE_RB_ROOT = File.expand_path(File.dirname(__FILE__))

# Need to run through the 'wrappers' dir, looking for wrapping projects
# and setup rake tasks as needed
Dir["wrappers/**/*.rake"].each { |f| load f }

# Global ogre.rb tasks
namespace :ogrerb do

  # Make sure the build and install directory structure we expect exists
  task :bootstrap do
    mkdir_p ogrerb_path("tmp", "downloads")
    mkdir_p ogrerb_path("lib", "usr")
  end

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
