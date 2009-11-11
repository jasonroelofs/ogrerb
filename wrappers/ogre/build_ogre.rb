# Wrap Ogre!

require 'rubygems'
require 'rbplusplus'
require 'fileutils'
include RbPlusPlus

OGRE_RB_ROOT = File.expand_path(File.join(File.dirname(__FILE__), "..", ".."))

OGRE_DIR = File.join(OGRE_RB_ROOT, "lib", "usr")

HERE_DIR = File.join(OGRE_RB_ROOT, "wrappers", "ogre")

Extension.new "ogre" do |e|

  e.working_dir = File.join(OGRE_RB_ROOT, "generated", "ogre")

  e.sources [
      File.join(OGRE_DIR, "include", "OGRE", "Ogre.h")
    ],
    :include_paths => File.join(OGRE_RB_ROOT, "lib", "usr", "include", "OGRE"),
    :library_paths => File.join(OGRE_RB_ROOT, "lib", "usr", "lib"),
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

    ##
    # Singleton<> 
    # Ignore all of these
    ##
    singleton = ogre.classes.find(:name => /Singleton/)
    singleton.ignore

    # Processing on all Singleton classes
    #
    # TODO Obviously find(:all) isn't doing what I want. Hacking around
    # it here for now
    klass = singleton[0]
    klass.methods.find(:all, :name => "getSingleton").ignore
    klass.methods.find(:all, :name => "getSingletonPtr").wrap_as("instance")
    klass.methods.find(:all, :name => /Iterator$/).ignore
    klass.methods.find(:all, :name => "getLights").ignore

    ## Incomplete types
    ogre.structs("BillboardParticleRenderer").ignore
    ogre.classes("RenderSystemCapabilitiesSerializer").ignore
    ogre.structs("ArchiveFactory").ignore
    ogre.structs("MemoryManager").ignore
    ogre.structs("ScriptCompiler").ignore
    ogre.structs("Factory").ignore
    ogre.structs("ParticleSystemRenderer").ignore
    ogre.structs("DynLib").ignore
    ogre.structs("ConfigDialog").ignore
    ogre.structs("TagPoint").ignore
    ogre.structs("ParticleAffectorFactory").ignore
    ogre.structs("WireBoundingBox").ignore
    ogre.structs("Codec").ignore

    ##
    #  Root
    ##
    root = ogre.classes("Root")

    # Plugin architecture is for dll plugins.Ruby-written plugins will come later
    root.methods("installPlugin").ignore
    root.methods("uninstallPlugin").ignore

    ##
    # NedAlloc
    ##
    ogre.classes("NedAllocImpl").ignore
    ogre.classes("NedAllocPolicy").ignore

    ##
    # ResourceGroupManager
    ##
    rgm = ogre.classes("ResourceGroupManager")
    rgm.variables.ignore
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

    scene_manager.methods("getOption").ignore
    scene_manager.methods("setOption").ignore

    # STL Interators, as usual
    scene_manager.methods("getLightClippingPlanes").ignore

    # Returns an Enum? Need to figure out the to_ruby for that 
    scene_manager.methods("getSpecialCaseRenderQueueMode").ignore 

    # Template class
    scene_manager.methods("getLightScissorRect").ignore

    scene_manager.methods(/^_/).ignore

    ##
    # VisibleObjectsBoundsInfo
    ##
    vobi = ogre.structs("VisibleObjectsBoundsInfo")
    vobi.disable_typedef_lookup

    ##
    # Viewport
    ##
    viewport = ogre.classes("Viewport")
    viewport.methods("_getRenderQueueInvocationSequence").ignore

    ##
    # Camera
    ##
    camera = ogre.classes("Camera")
    # STL
    camera.methods("getWindowPlanes").ignore

    ##
    # PlaneBoundedVolume (Camera)
    ##
    pbv = ogre.classes("PlaneBoundedVolume")
    pbv.methods("intersects").ignore

    ##
    # Vector3
    ##
    vec3 = ogre.classes("Vector3")
    # Ignore all but the 3-argument constructor
    vec3.use_constructor vec3.constructors.find(:arguments => [nil,nil,nil])

    ##
    # Vector4
    ##
    vec4 = ogre.classes("Vector4")

    ##
    # Ray
    ##
    ray = ogre.classes("Ray")
    ray.methods("intersects").ignore

    ##
    # Radian
    ##
    radian = ogre.classes("Radian")
    radian.use_constructor radian.constructors.find(:arguments => ["Real"])

    ##
    # Degree
    ##
    degree = ogre.classes("Degree")
    degree.use_constructor degree.constructors.find(:arguments => ["Real"])

    ##
    # TextureManager
    ##
    tex_man = ogre.classes("TextureManager")

    # std::pair
    tex_man.methods("createOrRetrieve").ignore

    ##
    # SharedPtr
    ##
    shared_pointers = ogre.classes.find(:name => /SharedPtr/)
    shared_pointers.disable_typedef_lookup

    ##
    # Plane
    ##
    plane = ogre.classes("Plane")
    plane.use_constructor plane.constructors.find(:arguments => [])

    ##
    # Light
    ##
    light = ogre.classes("Light")

    # Trying to include as few classes as necessary right now
    light.methods("createAnimableValue").ignore

    # Any _ prefixed methods are privatish
    # Of course right now they return std::vector and Rice needs
    # to handle this stuff
    light.methods(/^_/).ignore

    # SharedPtr needs to be handled 
    light.methods("setCustomShadowCameraSetup").ignore
    light.methods("getCustomShadowCameraSetup").ignore

    ##
    # AxisAlignedBox
    ##
    aab = ogre.classes("AxisAlignedBox")
    aab.methods.ignore

    ##
    # Entity
    ##
    entity = ogre.classes("Entity")

    # STL contianers
    entity.methods("getAllAnimationStates").ignore
    entity.methods("getSkeletonInstanceSharingSet").ignore
    entity.methods("getEdgeList").ignore

    # Might just need TagPoint wrapped
    entity.methods("attachObjectToBone").ignore

    # SubEntity has protected deconstructor, ignore it's use for now. We'll need to give the
    # class a special Allocation_Strategy
    entity.methods("getSubEntity").ignore

    ##
    # Node
    ##
    node = ogre.classes("Node")

    ##
    # SceneNode
    ##
    scene_node = ogre.classes("SceneNode")

    # Has out params
    scene_node.methods("_findVisibleObjects").ignore

    ##
    # ManualObject
    ##
    mo = ogre.classes("ManualObject")
    mo.methods("getEdgeList").ignore

    ##
    # MovableObject
    ##
    mo = ogre.classes("MovableObject")
    mo.methods("queryLights").ignore
    mo.methods("_getLightList").ignore

    # STL
    mo.methods("getEdgeList").ignore

    ##
    # FrameListener
    ##
    fl = ogre.classes("FrameListener")
    fl.director

    ##
    # LogManager
    ##
    lm = ogre.classes("LogManager")
    lm.methods("stream").ignore

    ##
    # Log (to work with LogManager of course)
    ##
    log = ogre.classes("Log")
    log.methods("stream").ignore

    ##
    # WindowEventUtilities
    ##
    weu = ogre.classes("WindowEventUtilities")
    weu.constants("_msListeners").ignore
    weu.constants("_msWindows").ignore

    ##
    # ExceptionCodeType
    ##
    ogre.structs.find(:name => /ExceptionCodeType/).ignore

    ##
    # *Iterator
    # 
    # - MapIterator
    # - VectorIterator
    # etc
    #
    # ignore them all for now
    ##
    ogre.classes.find(:name => /Iterator/).ignore

    ##
    # AnimationStateSet
    ##
    anim_set = ogre.classes("AnimationStateSet")
    anim_set.methods("getAnimationStateIterator").ignore
    anim_set.methods("getEnabledAnimationStateIterator").ignore

    ##
    # ArchiveManager
    ##
    archive_manager = ogre.classes("ArchiveManager")
    archive_manager.methods("addArchiveFactory").ignore
    archive_manager.methods("getArchiveIterator").ignore

    ##
    # Controllers
    ##
    ogre.classes.find(:name => /ControllerValue/).ignore
    ogre.classes.find(:name => /ControllerFunction/).ignore

    ##
    # AllocPolicy classes
    ##
    ogre.classes.find(:name => /AllocPolicy/).ignore

    ##
    # AllocatedObject
    ##
    ogre.classes.find(:name => /AllocatedObject/).ignore

    ##
    # MeshManager
    ##
    mesh_man = ogre.classes("MeshManager")
    mesh_man.methods("createOrRetrieve").ignore
    
    # The following have too many parameters.
    # Need to up the limit in Rice
    mesh_man.methods("createPlane").ignore
    mesh_man.methods("createCurvedPlane").ignore
    mesh_man.methods("createCurvedIllusionPlane").ignore

    #AUTO_LEVEL?
    mesh_man.methods("createBezierPatch").ignore

    ##
    # Mesh
    ##
    mesh = ogre.classes("Mesh")
    mesh.methods("getEdgeList").ignore
    mesh.methods("hasEdgeList").ignore
    mesh.methods("getPoseList").ignore
    mesh.methods("getPoseIterator").ignore
    mesh.methods("getSubMeshNameMap").ignore
    mesh.methods("getBoneAssignments").ignore
    mesh.methods("getBoneAssignmentsIterator").ignore
    mesh.methods("getSubMeshIterator").ignore
    mesh.variables.ignore

    # Some weird const const thing going on w/ this method, ignore for now
    mesh.methods("softwareVertexBlend").ignore

    ## 
    # MeshSerializer
    #
    # - Don't wrap implementations of serializer
    ##
    ogre.classes.find(:name => /MeshSerializerImpl/).ignore

    ##
    # STLAllocator
    ##
    ogre.classes.find(:name => /STLAllocator/).ignore

    ##
    # Singleton templates
    ##
    ogre.classes.find(:name => /Singleton/).ignore

    ## 
    # ParameterList
    ##
#    ogre.classes("ParameterList").disable_typedef_lookup

    ##
    # ParamDictionary
    ##
    ogre.classes.find(:name => "ParamDictionary").disable_typedef_lookup

    ##
    # StringInterface
    ##
    ogre.classes("StringInterface").ignore

    ##
    # StringUtil
    ##
    ogre.classes("StringUtil").ignore

    ##
    # UTFString
    ##
    utf = ogre.classes("UTFString")
    utf.classes.ignore

    ##
    # DisplayString
    ##
    # Implement as a to_ruby<Ogre::DisplayString>, don't need to wrap
    # this class.
    ogre.classes("DisplayString").ignore

    ##
    # Radix Sort
    ##
    ogre.classes.find(:name => /RadixSort/).ignore

    ##
    # EffectType
    ##
#    ogre.classes("MaterialSerializer").classes("EffectMap").disable_typedef_lookup

    ##
    # TextureUnitState
    ##
    tus = ogre.classes("TextureUnitState")
    tus.structs("TextureEffect").disable_typedef_lookup

    ##
    # Animable
    ##
    ogre.classes("AnimableObject").ignore
    # Something finds a Union for a return type, rbgccxml doesn't support this
    # type yet so ignore for now
    ogre.classes("AnimableValue").ignore

    ## 
    # Skeleton
    ##
    skel_inst = ogre.classes("SkeletonInstance")
    skel_inst.methods.ignore

    ##
    # ShadowCaster
    ##
    shadow_caster = ogre.classes("ShadowCaster")
    shadow_caster.methods("getEdgeList").ignore
    shadow_caster.methods("hasEdgeList").ignore

    ##
    # Renderable
    ##
    renderable = ogre.classes("Renderable")
    renderable.methods("getCustomParameter").ignore
    renderable.methods("setCustomParameter").ignore
    renderable.methods("getUserAny").ignore
    renderable.methods("setUserAny").ignore

    ##
    # ShadowRenderable
    ##
    sr = ogre.classes("ShadowRenderable")

    ##
    # MaterialScriptProgramDefinition
    ##
    mspd = ogre.structs("MaterialScriptProgramDefinition")
    mspd.variables("customParameters").ignore

    ##
    # ParticleSystem
    ##
    particle_system = ogre.classes("ParticleSystem")
    # Hide all the Cmd classes inside
    particle_system.classes.ignore

    ##
    # Math
    ##
    math = ogre.classes("Math")
    math.methods("intersects").ignore
    # Function type is weird. Clamp<float>_func_type ?
    math.methods("clamp").ignore

    ##
    # Pass
    ##
    pass = ogre.classes("Pass")
    pass.methods("getDirtyHashList").ignore
    pass.methods("getPassGraveyard").ignore

    ##
    # Technique
    ##
    technique = ogre.classes("Technique")
    technique.methods("getGPUDeviceNameRuleIterator").ignore
    technique.methods.find(:name => /Iterator$/).ignore

    ##
    # ConfigFile
    ##
    # Probably going to leave this one out, reimplement
    # it in Ruby
    ogre.classes("ConfigFile").ignore

    ##
    # ConfigOption
    ##
    co = ogre.structs("ConfigOption")
    co.variables("possibleValues").ignore

    ##
    # Matrix3
    ##
    m3 = ogre.classes("Matrix3")
    m3.use_constructor m3.constructors.find(:arguments => [])

    ##
    # Matrix4
    ##
    m4 = ogre.classes("Matrix4")
    m4.use_constructor m4.constructors.find(:arguments => [])

    ##
    # VertexElement
    ##
    ve = ogre.classes("VertexElement")
    ve.methods("baseVertexPointerToElement").ignore

    # Ignore the IO Stream classes for now
    ogre.classes("FileStreamDataStream").ignore
    ogre.classes("FileHandleDataStream").ignore

    ##
    # SceneQuery
    ##
    scene_query = ogre.classes("SceneQuery").ignore
    scene_query.structs.ignore

    ##
    # RaySceneQuery
    ##
    ray_scene_query = ogre.classes("RaySceneQuery").ignore
    ray_scene_query.methods("execute").ignore
    ray_scene_query.methods("getLastResults").ignore

    ##
    # SceneQueryResult
    ##
    ogre.classes("SceneQueryResult").ignore

    ##
    # IntersectionSceneQueryResult
    ##
    ogre.structs("IntersectionSceneQueryResult").ignore

    ##
    # GpuProgramParameters
    ##
    gpu_params = ogre.classes("GpuProgramParameters")
    gpu_params.classes.ignore

    ##
    # Pose
    ##
    pose = ogre.classes("Pose")
    pose.methods("getVertexOffsets").ignore
    pose.methods("getVertexOffsetIterator").ignore

    ##
    # PatchSurface
    ##
    patch_surface = ogre.classes("PatchSurface")
    patch_surface.methods("getControlPointBuffer").ignore
    patch_surface.methods("defineSurface").ignore

    ##
    # EdgeData
    ##
    edge_data = ogre.classes("EdgeData")
    edge_data.structs.ignore

    ##
    # InstancedGeometery
    ##
    ig = ogre.classes("InstancedGeometry")
    ig.methods.find(:name => /Iterator$/).ignore
    ig.methods("getRenderOperationVector").ignore
    ig.methods("getBaseAnimationState").ignore
    ig.classes.ignore
    ig.structs.ignore

    ##
    # GpuProgramManager
    ##
    gpu_m = ogre.classes("GpuProgramManager")
    gpu_m.methods("getSupportedSyntax").ignore

    ##
    # CompositorChain
    ##
    comp_chain = ogre.classes("CompositorChain")
    comp_chain.methods("getCompsitors").ignore

    # The following are typedef-finding stl structs, disable the typedef lookup
    %w(Vector4 ParameterDef VertexElement).each do |klass|
      ogre.classes.find(:name => klass).disable_typedef_lookup
    end

  end
end

# At completion, copy over the new noise extension
FileUtils.cp File.join(OGRE_RB_ROOT, "generated", "ogre", "ogre.so"), File.join(OGRE_RB_ROOT, "lib", "ogre")
