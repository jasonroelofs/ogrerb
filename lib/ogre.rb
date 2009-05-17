#!/usr/bin/env ruby

OGRE_RB_ROOT = File.expand_path(File.join("..", "..")) unless defined?(OGRE_RB_ROOT)

if ENV["LD_LIBRARY_PATH"] !~ /ogre/
  ENV["LD_LIBRARY_PATH"] = [File.join(OGRE_RB_ROOT, "lib", "ogre", "lib"),
                            ENV["LD_LIBRARY_PATH"]].join(":")
  exec("#{$0} #{ARGV.join(" ")}")
end

require File.join(OGRE_RB_ROOT, "lib", "ogre", "ogre")
