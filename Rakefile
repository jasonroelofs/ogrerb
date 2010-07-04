#!/usr/bin/env ruby

$: << File.expand_path(File.join("packages"), File.dirname(__FILE__))
$: << File.expand_path(File.join("packages", "lib"), File.dirname(__FILE__))

require 'rake/contrib/sshpublisher'
require 'packages/lib/packages'

# Setup some global Ogre.rb information
OGRE_RB_ROOT = File.expand_path(File.dirname(__FILE__))

# Need to run through the 'packages' dir, running the package definitions
# and building rake tasks as needed
Packages.load_packages

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
