#!/usr/bin/env ruby

# See http://libnoise.sourceforge.net/tutorials/tutorial3.html

require 'noise'

my_module = Noise::Module::Perlin.new

# Our actual height map
height_map = Noise::Utils::NoiseMap.new

# Plane on which we pull noise from
map_builder = Noise::Utils::NoiseMapBuilderPlane.new

map_builder.set_source_module(my_module)
map_builder.set_dest_noise_map(height_map)
map_builder.set_dest_size(256, 256)

# Section of the plane from which we pull our noise
map_builder.set_bounds(2.0, 6.0, 1.0, 5.0)

map_builder.build

# Output the noise into a BMP file
renderer = Noise::Utils::RendererImage.new
image = Noise::Utils::Image.new

renderer.set_source_noise_map(height_map)
renderer.set_dest_image(image)
renderer.render

writer = Noise::Utils::WriterBMP.new
writer.set_source_image(image)
writer.set_dest_filename("sample2_bw.bmp")
writer.write_dest_file

# Add color to the height map
renderer.clear_gradient
renderer.add_gradient_point(-1.0000, Noise::Utils::Color.new(  0,   0, 128, 255)); # deeps
renderer.add_gradient_point(-0.2500, Noise::Utils::Color.new(  0,   0, 255, 255)); # shallow
renderer.add_gradient_point( 0.0000, Noise::Utils::Color.new(  0, 128, 255, 255)); # shore
renderer.add_gradient_point( 0.0625, Noise::Utils::Color.new(240, 240,  64, 255)); # sand
renderer.add_gradient_point( 0.1250, Noise::Utils::Color.new( 32, 160,   0, 255)); # grass
renderer.add_gradient_point( 0.3750, Noise::Utils::Color.new(224, 224,   0, 255)); # dirt
renderer.add_gradient_point( 0.7500, Noise::Utils::Color.new(128, 128, 128, 255)); # rock
renderer.add_gradient_point( 1.0000, Noise::Utils::Color.new(255, 255, 255, 255)); # snow
renderer.render

writer.set_dest_filename("sample2_color.bmp")
writer.write_dest_file

# Add artificial light
renderer.enable_light(true)
renderer.render

writer.set_dest_filename("sample2_color_light.bmp")
writer.write_dest_file

# Up the contrast to make the details stick out more
renderer.set_light_contrast(3.0)
renderer.render

writer.set_dest_filename("sample2_color_light_contrast.bmp")
writer.write_dest_file

# Now make the image a little brighter
renderer.set_light_brightness(2.0)
renderer.render

writer.set_dest_filename("sample2_color_light_bright.bmp")
writer.write_dest_file

# You can tile your height maps too!
map_builder.set_bounds(6.0, 10.0, 1.0, 5.0)
map_builder.build

renderer.render

writer.set_dest_filename("sample2_to_the_right.bmp")
writer.write_dest_file
