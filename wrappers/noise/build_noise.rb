# Wrap the libnoise library into Ruby

require 'rubygems'
require 'rbplusplus'
require 'fileutils'
include RbPlusPlus

OGRE_RB_ROOT = File.expand_path(File.join(File.dirname(__FILE__), "..", ".."))

NOISE_DIR = File.join(OGRE_RB_ROOT, "tmp", "noise")

HERE_DIR = File.join(OGRE_RB_ROOT, "wrappers", "noise")

Extension.new "noise" do |e|
  e.working_dir = File.join(OGRE_RB_ROOT, "generated", "noise")
  e.sources [
      File.join(NOISE_DIR, "include/noise.h"),
      File.join(HERE_DIR, "code", "noiseutils.h")
    ],
    :library_paths => File.join(OGRE_RB_ROOT, "lib", "noise"),
    :include_paths => File.join(OGRE_RB_ROOT, "tmp", "noise", "include"),
    :include_source_dir => File.join(HERE_DIR, "code"),
    :libraries => "noise"

  e.module "Noise" do |m|
    node = m.namespace "noise"

    m.module "Model" do |model|
      node = model.namespace "model"
    end

    m.module "Utils" do |utils|
      node = utils.namespace "utils"

      # Ignore all but the default constructors
      node.classes("NoiseMap").constructors.find(:arguments => [nil, nil]).ignore
      node.classes("NoiseMap").constructors.find(:arguments => [nil]).ignore

      node.classes("Image").use_constructor(
        node.classes("Image").constructors.find(:arguments => [])
      )

      # NoiseMap's GetConstSlapPtr is not liking the rb++ of method exposing,
      # ignore for now
      node.classes("NoiseMap").methods("GetConstSlabPtr").ignore

      # Same here
      node.classes("Image").methods("GetConstSlabPtr").ignore
    end

    m.module "Module" do |mod|
      node = mod.namespace "module"
    end
  end
end

# At completion, copy over the new noise extension
FileUtils.cp File.join(OGRE_RB_ROOT, "generated", "noise", "noise.so"), File.join(OGRE_RB_ROOT, "lib", "noise")
