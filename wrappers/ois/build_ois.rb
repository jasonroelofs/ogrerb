require 'rbplusplus'
require 'fileutils'
include RbPlusPlus

OGRE_RB_ROOT = File.expand_path(File.join(File.dirname(__FILE__), "..", ".."))

OIS_DIR = File.join(OGRE_RB_ROOT, "lib", "ois")

HERE_DIR = File.join(OGRE_RB_ROOT, "wrappers", "ois")

Extension.new "ois" do |e|
  e.working_dir = File.join(OGRE_RB_ROOT, "generated", "ois")

  e.sources File.join(OIS_DIR, "include", "OIS", "OIS.h"),
    :include_source_files => [
      File.join(HERE_DIR, "code", "custom_to_from_ruby.cpp"), 
      File.join(HERE_DIR, "code", "custom_to_from_ruby.hpp")
    ],
    :includes => File.join(HERE_DIR, "code", "custom_to_from_ruby.hpp")

  e.module "OIS" do |m|
    node = m.namespace "OIS"

    # Uses crazy STL stuff, ignore for now
    node.classes("FactoryCreator").ignore

    # Hmm, InputManager has protected destructor, causing problems. Ignore them for now
    node.classes("Object").methods("getCreator").ignore

    # Crap, this isn't good, but I want to see it compile
    node.classes("InputManager").ignore
    
  end
end

# At completion, copy over the new ois extension
FileUtils.cp File.join(OGRE_RB_ROOT, "generated", "ois", "ois.so"), File.join(OGRE_RB_ROOT, "lib", "ois")
