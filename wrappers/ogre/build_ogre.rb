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

    # Plugin architecture is for dll plugins. Maybe Ruby-written plugins will come, but much later
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

    rgm.variables.ignore

    rgm.methods("getSingleton").wrap_as("instance")
    rgm.methods("getSingletonPtr").ignore

    rgm.structs("ResourceDeclaration").variables.ignore

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
    # RenderTarget (Superclass of RenderWindow)
    ##
    rt = ogre.classes("RenderTarget")
    rt.unignore

    # void* is bad for Ruby wrapping, so we build our own
    # here.
    rt.methods("getCustomAttribute").ignore
    decl = <<-END
int RenderTarget_getCustomAttributeInt(Ogre::RenderTarget* self, const std::string& name) {
  int value(0);
  self->getCustomAttribute(name, &value);
  return value;
}
END
    wrapping = "<class>.define_method(\"get_custom_attribute_int\", &RenderTarget_getCustomAttributeInt);"

    rt.add_custom_code(decl, wrapping)

    ##
    # RenderWindow
    ##
    rw = ogre.classes("RenderWindow")
    rw.unignore

    rw.methods("isClosed").wrap_as("closed?")
    rw.methods("isActive").wrap_as("active?")
    rw.methods("isPrimary").wrap_as("primary?")

    rw.methods("isFullScreen").wrap_as("full_screen?")
    rw.methods("setFullscreen").wrap_as("full_screen=")

    rw.methods("isDeactivatedOnFocusChange").wrap_as("deactivated_on_focus_change?")
    rw.methods("setDeactivateOnFocusChange").wrap_as("deactivate_on_focus_change=")

    rw.methods("isVisible").wrap_as("visible?")
    rw.methods("setVisible").wrap_as("visible=")

    ##
    # SceneManager
    ##
    scene_manager = ogre.classes("SceneManager")
    scene_manager.unignore

    scene_manager.methods("getOption").ignore
    scene_manager.methods("setOption").ignore

    # STL Interators, as usual
    scene_manager.methods.find(:name => /Iterator$/).ignore

    # Returns an Enum? Need to figure out the to_ruby for that 
    scene_manager.methods("getSpecialCaseRenderQueueMode").ignore 

    ##
    # ViewPoint (needed by SceneManager)
    ##
    viewpoint = ogre.structs("ViewPoint")
    viewpoint.unignore

    ##
    # Viewport
    ##
    viewport = ogre.classes("Viewport")
    viewport.unignore

    viewport.methods("_getRenderQueueInvocationSequence").ignore

    ## 
    # Frustum (superclass of Camera)
    ##
    frustum = ogre.classes("Frustum")
    frustum.unignore

    ##
    # Camera
    ##
    camera = ogre.classes("Camera")
    camera.unignore

    # STL
    camera.methods("getWindowPlanes").ignore

    ##
    # ColourValue
    ##
    ogre.classes("ColourValue").unignore

    ##
    # PlaneBoundedVolume (Camera)
    ##
    pbv = ogre.classes("PlaneBoundedVolume")
    pbv.unignore

    pbv.methods("intersects").ignore

    ##
    # Vector3
    ##
    vec3 = ogre.classes("Vector3")
    vec3.unignore

    # Ignore all but the 3-argument constructor
    vec3.use_constructor vec3.constructors.find(:arguments => [nil,nil,nil])

    radian = ogre.classes("Radian")
    radian.unignore
    radian.use_constructor radian.constructors.find(:arguments => ["Real"])

    degree = ogre.classes("Degree")
    degree.unignore
    degree.use_constructor degree.constructors.find(:arguments => ["Real"])


    ##
    # TextureManager
    ##
    tex_man = ogre.classes("TextureManager")
    tex_man.unignore

    tex_man.methods("getSingleton").wrap_as("instance")
    tex_man.methods("getSingletonPtr").ignore

    # std::pair
    tex_man.methods("createOrRetrieve").ignore

    ##
    # Plane
    ##
    plane = ogre.classes("Plane")
    plane.unignore

    # TODO When system supports multiple constructors, undo this
    # Just use the default constructor for now
    plane.use_constructor plane.constructors.find(:arguments => [])

    ##
    # Light
    ##
    light = ogre.classes("Light")
    light.unignore

    # Trying to include as few classes as necessary right now
    light.methods("createAnimableValue").ignore

    ##
    # Entity
    ##
    entity = ogre.classes("Entity")
    entity.unignore

    # STL contianers
    entity.methods("getAllAnimationStates").ignore
    entity.methods("getSkeletonInstanceSharingSet").ignore
    entity.methods("getEdgeList").ignore
    entity.methods.find(:name => /Iterator$/).ignore

    # Might just need TagPoint wrapped
    entity.methods("attachObjectToBone").ignore

    # SubEntity has protected deconstructor, ignore it's use for now. We'll need to give the
    # class a special Allocation_Strategy (thought rb++ did this already, hmm, bug?)
    entity.methods("getSubEntity").ignore

    ##
    # Resource
    ##
    resource = ogre.classes("Resource")
    resource.unignore

    ##
    # SceneNode
    ##
    scene_node = ogre.classes("SceneNode")
    scene_node.unignore

    # Has out params
    scene_node.methods("_findVisibleObjects").ignore

    # STL
    scene_node.methods.find(:name => /Iterator$/).ignore

    ##
    # MovableObject
    ##
    mo = ogre.classes("MovableObject")
    mo.unignore

    # STL
    mo.methods.find(:name => /Iterator$/).ignore
    mo.methods("getEdgeList").ignore

    ##
    # FrameListener
    ##
    fl = ogre.classes("FrameListener")
    fl.unignore
    fl.director

    ##
    # FrameEvent
    ##
    ogre.structs("FrameEvent").unignore

    ##
    # LogManager
    ##
    lm = ogre.classes("LogManager")
    lm.unignore

    lm.methods("getSingleton").wrap_as("instance")
    lm.methods("getSingletonPtr").ignore
    lm.methods("stream").ignore

    ##
    # Log (to work with LogManager of course)
    ##
    log = ogre.classes("Log")
    log.unignore

    log.methods("stream").ignore

    ##
    # WindowEventUtilities
    ##
    weu = ogre.classes("WindowEventUtilities")
    weu.unignore

    weu.constants("_msListeners").ignore
    weu.constants("_msWindows").ignore

  end
end

# At completion, copy over the new noise extension
FileUtils.cp File.join(OGRE_RB_ROOT, "generated", "ogre", "ogre.so"), File.join(OGRE_RB_ROOT, "lib", "ogre")
