# Wrap Ogre!

require 'rubygems'
require 'rbplusplus'
require 'fileutils'
include RbPlusPlus

#puts "Yeah, xml parsing is still REALLY slow with datasets as large as with Ogre"
#puts "I highly recommend NOT running this yet"
#exit(0)

OGRE_RB_ROOT = File.expand_path(File.join(File.dirname(__FILE__), "..", ".."))

OGRE_DIR = File.join(OGRE_RB_ROOT, "lib", "ogre")

HERE_DIR = File.join(OGRE_RB_ROOT, "wrappers", "ogre")

Extension.new "ogre" do |e|

  e.working_dir = File.join(OGRE_RB_ROOT, "generated", "ogre")

  e.sources File.join(OGRE_DIR, "include", "OGRE", "Ogre.h"),
    :include_paths => File.join(OGRE_RB_ROOT, "lib", "ogre", "include", "OGRE"),
    :library_paths => File.join(OGRE_RB_ROOT, "lib", "ogre", "lib"),
    :include_source_dir => File.join(OGRE_DIR, "code"),
    :libraries => "Ogre"

  e.module "Ogre" do |ogre|
    node = ogre.namespace "Ogre"

    # To start, just ignore those classes with multiple inheritance
    # multi-inheritance classes not included in Ogre.h
    #
    #  Font
    #  FontManager
    #
    %w(
      BillboardChain
      CompositorManager
      Entity
      Frustum
      GpuProgramManager
      MaterialManager
      MeshManager
      MovableObject
      MovablePlane
      OverlayElement
      OverlayManager
      ParticleEmitter
      ParticleSystem
      ParticleSystemManager
      FrameTimeControllerValue
      RibbonTrail
      SimpleRenderable
      SkeletonManager
      TextureManager
      RegionSceneQuery
    ).each do |klass|
#      puts "Ignoring #{klass}"
      node.classes(klass).ignore
    end

    # And ignore classes that are causing odd code generation issues
    %w(
      ControllerManager
    ).each do |klass|
      node.classes(klass).ignore
    end

    # Abstract classes that are abstract via inheritance
    node.classes("SphereSceneQuery").ignore

    # Ignore class definitions created by effectively protected variables
    %w(
      RadixSort
    ).each do |klass|
      node.classes.find(:name => /^#{klass}/).ignore
    end

    # Some inner classes are marked as _OgrePrivate, but are actually C++ public
    # to work around VS compiler bugs (I think). Ignore these.
    %w(
      MeshSerializerImpl
      MeshSerializerImpl_v1_1
      MeshSerializerImpl_v1_2
      MeshSerializerImpl_v1_3
    ).each do |klass|
      node.classes(klass).ignore
    end

    # Not sure why I can't easy-find nested classes. rbpp bug?
    node.classes("ProgressiveMesh").classes("PMFaceVertex").ignore
    node.classes("InstancedGeometry").classes("OptimisedSubMeshGeometry").ignore


    # Something is picking up pure STL containers in Ogre, ignore them until
    # We figure out what's up (causing file creation to crash ... hard)
    %w(
      vector
      pair
      map
      iterator
      list
    ).each do |klass|
      if found = node.structs.find(:all, :name => /^#{klass}/)
        if found.is_a?(Array) && found.empty?
          # nop
        else
          found.ignore
        end
      end

      if found = node.classes.find(:all, :name => /^#{klass}/)
        if found.is_a?(Array) && found.empty?
          # nop
        else
          found.ignore
        end
      end
    end
    

    # TODO Hand build wrappers for the _Iterator classes, we can't auto-gen
    # the wrapping for this stuff and it only blows up
    node.classes.find(:name => /Iterator/).ignore
  end
end
