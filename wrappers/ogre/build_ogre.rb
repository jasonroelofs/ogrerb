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

  e.module "Ogre" do |ogre|
    ogre = ogre.namespace "Ogre"

    # Methods on the Ogre namespace we don't need
    ogre.functions("any_cast").ignore
    ogre.functions("findCommandLineOpts").ignore
    ogre.functions("intersect").ignore

    # How I'm going about this massive task:
    #  1) Ignore *everything*
    ogre.classes.ignore
    ogre.structs.ignore

    #  2) Start unignoring only the parts I need for a given demo I'm working on

    # Unignore classes for the sky_plane demo, application / application_frame_listener classes

    ##
    # Global
    ##

    # All 'getSingleton' methods to be wrapped as 'instance' to fit Ruby's Singleton method choice
    # TODO: This nice way of working on methods
#    ogre.methods.find(:all, :name => "getSingleton").wrap_as("instance") 
#    ogre.methods.find(:all, :name => "getSingletonPtr").ignore

    ##
    #  Root
    ##
    root = ogre.classes("Root")
    root.unignore 

    root.methods("getSingleton").wrap_as("instance")
    root.methods("getSingletonPtr").ignore

    # Plugin architecture is for dll plugins. Maybe Ruby-written plugins will come, but much laster
    root.methods("installPlugin").ignore
    root.methods("uninstallPlugin").ignore

    # Ignore methods that use STL containers for now
    root.methods("getSceneManagerIterator").ignore
    root.methods("getSceneManagerMetaDataIterator").ignore
    root.methods("getMovableObjectFactoryIterator").ignore

    ##
    # ResourceGroupManager
    ##
    rgm = ogre.classes("ResourceGroupManager")
    rgm.unignore

    rgm.methods("getSingleton").wrap_as("instance")
    rgm.methods("getSingletonPtr").ignore

    # STL container methods
    rgm.methods("getResourceDeclarationList").ignore
    rgm.methods("getResourceGroups").ignore
    rgm.methods("findResourceNames").ignore
    rgm.methods("listResourceNames").ignore
    rgm.methods("findResourceFileInfo").ignore
    rgm.methods("listResourceFileInfo").ignore
    rgm.methods("openResource").ignore
    rgm.methods("openResources").ignore
    rgm.methods("getResourceManagerIterator").ignore

    # Weird use case here. These methods both have overloads, one of which uses a protected type
    # as an argument. Ignore for now, figure out how to have rb++ handle this case
    rgm.methods("resourceModifiedTime").ignore
    rgm.methods("resourceExists").ignore

    # Not sure what's up with these. Ruby + linker can't find them, and python-ogre also excludes them,
    # so ignore
    rgm.methods("_notifyWorldGeometryPrepareStageStarted").ignore
    rgm.methods("_notifyWorldGeometryPrepareStageEnded").ignore

    ##
    # RenderWindow
    ##
    rw = ogre.classes("RenderWindow")
    rw.unignore

    ##
    # SceneManager
    ##
    scene_manager = ogre.classes("SceneManager")
    scene_manager.unignore

    scene_manager.methods("getOption").ignore
    scene_manager.methods("setOption").ignore

    # STL Interators, as usual
    scene_manager.methods.find(:name => /Iterator$/).ignore

    ##
    # ViewPoint (needed by SceneManager)
    ##
    viewpoint = ogre.structs("ViewPoint")
    viewpoint.unignore
  end
end

# At completion, copy over the new noise extension
FileUtils.cp File.join(OGRE_RB_ROOT, "generated", "ogre", "ogre.so"), File.join(OGRE_RB_ROOT, "lib", "ogre")
