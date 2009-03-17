#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../../lib/ois'

puts "OIS! #{OIS}"

puts "WOOT! #{OIS.constants.inspect}"

puts "InputManager version: #{OIS::InputManager.get_version_number}"
