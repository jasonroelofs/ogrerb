# Wrap Ogre!

require 'rbplusplus'
require 'fileutils'
include RbPlusPlus

puts "Yeah, xml parsing is still REALLY slow with datasets as large as with Ogre"
puts "I highly recommend NOT running this yet"
exit(0)

OGRE_RB_ROOT = File.expand_path(File.join(File.dirname(__FILE__), "..", ".."))

OGRE_DIR = File.join(OGRE_RB_ROOT, "lib", "ogre")

HERE_DIR = File.join(OGRE_RB_ROOT, "wrappers", "noise")

Extension.new "ogre" do |e|

  e.working_dir = File.join(OGRE_RB_ROOT, "generated", "ogre")

  e.sources File.join(OGRE_DIR, "include", "OGRE", "Ogre.h")

  e.module "Ogre" do |ogre|
    ogre.namespace "Ogre"
  end
end
