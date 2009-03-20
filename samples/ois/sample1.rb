#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../../lib/ois'

puts "OIS! #{OIS}"

puts "WOOT! #{OIS.constants.sort.inspect}"

puts "InputManager version: #{OIS::InputManager.get_version_number}"

manager = OIS::InputManager.create_input_system_1({"WINDOW" => "value"})

puts manager.inspect

puts "Our manager's version name is #{manager.get_version_name.inspect}"

puts "We're using input system #{manager.input_system_name.inspect}"
