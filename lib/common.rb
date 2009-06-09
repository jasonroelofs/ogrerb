# This file is a collection of helper methods and classes used throughout
# the Ogre.rb library.

require 'dl'

# GC does bad things right now, always keep it disabled until we figure
# out proper memory management
GC.disable

module Kernel

  # Loading up multiple Rice libraries that use inheritence currently doesn't
  # work using Ruby's base #require because of some hard coded settings in Ruby.
  # Use this method to load libraries manually in a way that makes sure they
  # all talk together.
  def ogrerb_lib(lib_name)
    name = lib_name.to_s
    lib_so = DL.dlopen(
      File.expand_path(
        File.join(File.dirname(__FILE__), name, "#{name}.so")), DL::RTLD_NOW)
    lib_so["Init_#{name}", 'I'].call
  end

end
