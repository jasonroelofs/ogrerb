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
      node.classes.find(:all, :name => /^#{klass}/).ignore
    end

    # TODO Hand build wrappers for the _Iterator classes, we can't auto-gen
    # the wrapping for this stuff and it only blows up
    node.classes.find(:all, :name => /Iterator/).ignore
  end
end
