# Wrap the libnoise library into Ruby

require 'rbplusplus'
include RbPlusPlus

OGRE_RB_ROOT = File.expand_path(File.join("..", ".."))

NOISE_DIR = File.join(OGRE_RB_ROOT, "tmp", "noise")

Extension.new "noise" do |e|
  e.working_dir = File.join(OGRE_RB_ROOT, "generated", "noise")
  e.sources File.join(NOISE_DIR, "include/noise.h"),
    :library_paths => File.join(OGRE_RB_ROOT, "lib", "noise"),
    :libraries => "noise"

  e.module "Noise" do |m|
    m.namespace "noise"

    m.module "Model" do |model|
      node = model.namespace "model"
    end

    m.module "Module" do |mod|
      node = mod.namespace "module"

      # Ignore pure virtual
      node.classes("Module").methods("GetSourceModuleCount").ignore
      node.classes("Module").methods("GetValue").ignore
    end
  end
end

