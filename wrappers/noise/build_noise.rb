# Wrap the libnoise library into Ruby

require 'rbplusplus'
include RbPlusPlus

Extension.new "noise" do |e|
  e.working_dir = File.expand_path(File.join(File.dirname(__FILE__),
                                    "..", "..", "generated", "noise"))
  e.sources File.expand_path(File.dirname(__FILE__) + "/../../tmp/noise/include/noise.h"),
    :library_paths => File.expand_path(File.dirname(__FILE__) + "/../../tmp/noise/lib"),
    :libraries => "noise"

#  e.writer_mode :single

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

