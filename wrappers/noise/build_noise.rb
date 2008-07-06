# Wrap the libnoise library into Ruby

require 'rbplusplus'
require 'fileutils'
include RbPlusPlus

OGRE_RB_ROOT = File.expand_path(File.join("..", ".."))

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
    :include_source_files => [
      File.join(HERE_DIR, "code", "noiseutils.cpp"), 
      File.join(HERE_DIR, "code", "noiseutils.h"),
      File.join(HERE_DIR, "code", "custom_to_ruby.cpp"), 
      File.join(HERE_DIR, "code", "custom_to_ruby.hpp")
    ],
    :libraries => "noise"

  e.module "Noise" do |m|
    node = m.namespace "noise"

    m.module "Model" do |model|
      node = model.namespace "model"
    end

    m.module "Utils" do |utils|
      node = utils.namespace "utils"
      node.classes("NoiseMapBuilder").methods("SetCallback").ignore
#      node.classes("WriterBMP").ignore
#      node.classes("WriterTER").ignore

      # Ignore all but the default constructor
      node.classes("NoiseMap").constructors.find(:arguments => [nil, nil]).ignore
      node.classes("NoiseMap").constructors.find(:arguments => [nil]).ignore

      node.classes("Image").constructors.find(:arguments => [nil, nil]).ignore
      node.classes("Image").constructors.find(:arguments => [nil]).ignore
    end

    m.module "Module" do |mod|
      node = mod.namespace "module"

      # Ignore pure virtual
      node.classes("Module").methods("GetSourceModuleCount").ignore
      node.classes("Module").methods("GetValue").ignore
    end
  end
end

# At completion, copy over the new noise extension
FileUtils.cp File.join(OGRE_RB_ROOT, "generated", "noise", "noise.so"), File.join(OGRE_RB_ROOT, "lib", "noise")
