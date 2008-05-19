# Wrap the libnoise library into Ruby

require 'rbplusplus'
include RbPlusPlus

Extension.new "noise" do |e|
  e.working_dir = File.expand_path(File.join(File.dirname(__FILE__),
                                    "..", "..", "generated", "noise"))
  e.sources File.expand_path(File.dirname(__FILE__) + "/../../tmp/noise/include/noise.h")

  e.module "Noise" do |m|
    m.namespace "noise"

    m.module "Model" do |model|
      model.namespace "noise::model"
    end

    m.module "Module" do |mod|
      mod.namespace "noise::module"
    end
  end
end
