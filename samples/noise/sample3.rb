#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/../../lib/noise'
include Noise

# See http://libnoise.sourceforge.net/tutorials/tutorial5.html

# Basic height-map setup 
height_map = Utils::NoiseMap.new
height_map_builder = Utils::NoiseMapBuilderPlane.new

# the Mountain module
mountain_terrain = Noise::Module::RidgedMulti.new

# Flat terrain module
base_flat_terrain = Noise::Module::Billow.new
base_flat_terrain.set_frequency(2.0)

# Lower the flat terrain to make it actually "flat"
flat_terrain = Noise::Module::ScaleBias.new
flat_terrain.set_source_module(0, base_flat_terrain)
flat_terrain.set_scale(0.125)
flat_terrain.set_bias(-0.75)

# Now specify what module goes where in the final view
terrain_type = Noise::Module::Perlin.new
terrain_type.set_frequency(0.5)
terrain_type.set_persistence(0.25)

# Now the Selector module to pick and put together the complete terrain
final_terrain = Noise::Module::Select.new
final_terrain.set_source_module(0, flat_terrain)
final_terrain.set_source_module(1, mountain_terrain)
final_terrain.set_control_module(terrain_type)
final_terrain.set_bounds(0.0, 1000.0)
final_terrain.set_edge_falloff(0.125)

# To view the individual steps, uncomment the appropriate line
#height_map_builder.set_source_module(base_flat_terrain)
#height_map_builder.set_source_module(flat_terrain)
#height_map_builder.set_source_module(mountain_terrain)
height_map_builder.set_source_module(final_terrain)

height_map_builder.set_dest_noise_map(height_map)
height_map_builder.set_dest_size(256, 256)
height_map_builder.set_bounds(6.0, 10.0, 1.0, 5.0)
height_map_builder.build

renderer = Utils::RendererImage.new
image = Utils::Image.new

# Rendering options and coloring gradiants
renderer.set_source_noise_map(height_map)
renderer.set_dest_image(image)
renderer.clear_gradient
renderer.add_gradient_point(-1.0000, Noise::Utils::Color.new( 32, 160,   0, 255)) # grass
renderer.add_gradient_point(-0.2500, Noise::Utils::Color.new(244, 244,   0, 255)) # dirt
renderer.add_gradient_point( 0.2500, Noise::Utils::Color.new(128, 128, 128, 255)) # rock
renderer.add_gradient_point( 1.0000, Noise::Utils::Color.new(255, 255, 255, 255)) # snow
renderer.enable_light(true)
renderer.set_light_contrast(3.0)
renderer.set_light_brightness(2.0)
renderer.render

writer = Utils::WriterBMP.new
writer.set_source_image(image)
writer.set_dest_filename("sample3.bmp")
writer.write_dest_file
