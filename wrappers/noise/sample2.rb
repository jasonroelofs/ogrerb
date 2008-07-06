#!/usr/bin/env ruby

require 'noise'

my_module = Noise::Module::Perlin.new
height_map = Noise::Utils::NoiseMap.new
map_builder = Noise::Utils::NoiseMapBuilderPlane.new

map_builder.set_source_module(my_module)
map_builder.set_dest_noise_map(height_map)

map_builder.set_dest_size(256, 256)

map_builder.set_bounds(2.0, 6.0, 1.0, 5.0)

map_builder.build

renderer = Noise::Utils::RendererImage.new
image = Noise::Utils::Image.new

renderer.set_source_noise_map(height_map)
renderer.set_dest_image(image)
renderer.render

writer = Noise::Utils::WriterBMP.new
writer.set_source_image(image)
writer.set_dest_filename("tutorial.bmp")
writer.write_dest_file
