#!/usr/bin/ruby -w

$:.unshift File.expand_path(File.join(File.dirname(__FILE__),'..','..','lib','ogre'))
require 'application'

include Ogre

class SkyPlaneApplication < Application
  def create_scene
    scene_manager.set_ambient_light ColourValue.new(0.5, 0.5, 0.5)
  
    plane = Plane.new
    plane.d = 5000
    plane.normal = -Vector3.UNIT_Y
    scene_manager.set_sky_plane(true, plane, "SpaceSkyPlane", 10000, 3)

    light = scene_manager.create_light("MainLight")
    light.set_position(20, 80, 50)

    dragon = scene_manager.create_entity("dragon", "dragon.mesh")
    scene_manager.root_scene_node.attach_object(dragon)
  end
end

app = SkyPlaneApplication.new
app.go
