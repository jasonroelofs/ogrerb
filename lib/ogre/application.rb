$:.unshift File.expand_path(File.join(File.dirname(__FILE__), ".."))

require 'ogre'
require 'ois'

require 'application_frame_listener'

module Ogre

  # Application is a Ruby port of ExampleApplication. It is written so that there's nothing new
	# to learn here, but you do have to watch out for Ruby version of names 
	# (createScene vs create_scene).
  #
  # All you need to do is define your own createScene. An example Application subclass (sky_plane.rb):
  #
  #   require 'ogre'
  #   include Ogre
  #
  #   class SkyPlaneApplication < Application
  #
  #     def create_scene
  #       scene_manager.set_ambient_light(ColourValue.new(0.5, 0.5, 0.5))
  #      
  #       plane = Plane.new
  #       plane.d = 5000
  #       plane.normal = -Vector3.UNIT_Y
  #       scene_manager.set_sky_plane(true, plane, "SpaceSkyPlane", 10000, 3)
  #
  #       light = scene_manager.create_light("MainLight")
  #       light.set_position(20, 80, 50)
  #
  #       dragon = scene_manager.create_entity("dragon", "dragon.mesh")
  #       scene_manager.root_scene_node.attach_object(dragon)
  #     end
  #   end
  #
  #   app = SkyPlaneApplication.new
  #   app.go
	#
	# Any of the protected methods in this class are free for overriding.
	class Application

		attr_accessor :root, :frame_listener, :window, :scene_manager, :camera

		def initialize
			@frame_listener = nil
			@root = nil
		end

		# This starts off everything.
		def go
			return unless setup

			@root.start_rendering

			destroy_scene

		ensure
			@frame_listener.shutdown if @frame_listener
		end

		protected

		def setup
			@root = Root.new("plugins.cfg", "ogre.cfg", "Ogre.log")

			setup_resources

			return unless configure

			choose_scene_manager
			create_camera
			create_viewports

			TextureManager.instance.set_default_num_mipmaps 5

			create_resource_listener
			load_resources
			create_scene
			create_frame_listener
			true
		end

		# Shows the configuration dialog and initializes our
		# render window
		def configure
			return false unless @root.show_config_dialog
			@window = @root.initialise(true, "Ogre.rb Render Window", "")
			true
		end

		def choose_scene_manager
			@scene_manager = @root.create_scene_manager_0("DefaultSceneManager", "ExampleSMInstance")
		end

		def create_camera
			@camera = @scene_manager.create_camera("PlayerCam")

			@camera.set_position_0(0, 0, 500)
			# Look along the -Z axis
			@camera.look_at_1(0, 0, -300)
			@camera.set_near_clip_distance 5
		end

		def create_frame_listener
			@frame_listener = ApplicationFrameListener.new(@window, @camera)
#			@frame_listener.show_debug_overlay(true)
      @root.add_frame_listener(@frame_listener)
		end

		def create_scene
			raise "Please redefine #create_scene in your application"
		end

		def destroy_scene
		end

		def create_viewports
			vp = @window.add_viewport(@camera, 0, 0.0, 0.0, 1.0, 1.0)
			vp.set_background_colour ColourValue.new(0,0,0,0)

			@camera.set_aspect_ratio( (vp.get_actual_width * 1.0) / (vp.get_actual_height * 1.0) )
		end

		def setup_resources
			section = "General"
			File.open("resources.cfg", "r") do |config_file|
				config_file.each do |line|
					line.chomp!
					next if line =~ /^#/ || line.empty?
					if line =~ /^\[(.+?)\]/
						section = $1
						next
					end

					key, value = line.split("=")
					ResourceGroupManager.instance.add_resource_location(value, key, section, false)
				end
			end
		end

		def create_resource_listener
		end

		def load_resources
			ResourceGroupManager.instance.initialise_all_resource_groups
		end

	end
end
