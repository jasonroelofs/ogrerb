#!/usr/bin/env ruby

require 'noise'

my_module = Noise::Module::Perlin.new
puts "Random coherent value: #{my_module.get_value(1.25, 0.75, 0.5)}"

puts "Slightly different value: #{my_module.get_value(1.2501, 0.7501, 0.5001)}"

puts "Much bigger difference: #{my_module.get_value(14.50, 20.25, 75.75)}"
