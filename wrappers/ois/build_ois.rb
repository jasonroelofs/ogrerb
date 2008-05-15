require 'rbplusplus'
include RbPlusPlus

Extension.new "ois" do |e|
  e.working_dir = File.expand_path(File.join(File.dirname(__FILE__),
                                    "..", "..", "generated", "ois"))
  e.sources `pkg-config --cflags-only-I OIS`.gsub("-I", "").chomp.strip

  e.module "OIS" do |m|
    m.namespace "OIS"
  end
end
