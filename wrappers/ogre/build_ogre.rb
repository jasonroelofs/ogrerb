# Wrap Ogre!

require 'rubygems'
require 'rbplusplus'
require 'fileutils'
include RbPlusPlus

OGRE_RB_ROOT = File.expand_path(File.join(File.dirname(__FILE__), "..", ".."))

OGRE_DIR = File.join(OGRE_RB_ROOT, "lib", "ogre")

HERE_DIR = File.join(OGRE_RB_ROOT, "wrappers", "ogre")

Extension.new "ogre" do |e|

  e.working_dir = File.join(OGRE_RB_ROOT, "generated", "ogre")

  e.sources File.join(OGRE_DIR, "include", "OGRE", "Ogre.h"),
    :include_paths => File.join(OGRE_RB_ROOT, "lib", "ogre", "include", "OGRE"),
    :library_paths => File.join(OGRE_RB_ROOT, "lib", "ogre", "lib"),
    :include_source_dir => File.join(HERE_DIR, "code"),
    :libraries => "OgreMain",

    # Special define for hiding tr1 includes for gcc 4.3 which gccxml doesn't like
    :cxxflags => "-D__OGRERB_BUILD" 

  e.module "ogre" do |ogre|
    node = ogre.namespace "Ogre"

    # Methods on the Ogre namespace we don't need
    node.functions("any_cast").ignore
    node.functions("findCommandLineOpts").ignore
    node.functions("intersect").ignore

    # How I'm going about this massive task:
    #  1) Ignore *everything*
    node.classes.ignore

    #  2) Start unignoring only the parts I need for a given demo I'm working on

    # Unignore classes for the sky_plane demo, application / application_frame_listener classes

    ##
    #  Root
    ##
    root = node.classes("Root")
    root.unignore 

    # Plugin architecture is for dll plugins. Maybe Ruby-written plugins will come, but much laster
    root.methods("installPlugin").ignore
    root.methods("uninstallPlugin").ignore

    # Ignore methods that use STL containers for now
    root.methods("getSceneManagerIterator").ignore
    root.methods("getSceneManagerMetaDataIterator").ignore
    root.methods("getMovableObjectFactoryIterator").ignore
  end
end

# At completion, copy over the new noise extension
FileUtils.cp File.join(OGRE_RB_ROOT, "generated", "ogre", "ogre.so"), File.join(OGRE_RB_ROOT, "lib", "ogre")
