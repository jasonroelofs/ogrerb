module Ogre
	# Define a listener for certain window events, such as resizing, closing, 
	# and changes of focus
	class ApplicationWindowListener #< WindowEventListener
		def initialize(input_manager, window, keyboard, mouse, joy_stick)
			@input_manager = input_manager
			@keyboard = keyboard
			@mouse = mouse
			@window = window
			@joy_stick = joy_stick
		end

		# Adjust the mouse clipping area when the window has been resized
		def window_resized
			width, height, depth, left, top = @window.get_metrics

			mouse_state = @mouse.mouse_state
			mouse_state.width = width
			mouse_state.height = height
		end

		# Shut everything down nicely when we're done
		def window_closed
			if @input_manager
				@input_manager.destroy_mouse(@mouse) unless @mouse.nil?
				@input_manager.destroy_keyboard(@keyboard) unless @keyboard.nil?
				@input_manager.destroy_joy_stick(@joy_stick) unless @joy_stick.nil?
				OIS::InputManager.destroy_input_system(@input_manager)
				@input_manager = nil
			end
		end
	end

  # In the same way Application is the port of ExampleApplication, ApplicationFrameListener
  # is the Ruby port of ExampleFrameListener. This class gives us a very helpful starting
  # point for input management and a few Overlays for information. The default ApplicationFrameListener
  # gives the WASD movement (through OIS), as well as the well-known Ogre overlay showing triangle count, FPS, etc.
  # 
  # Usage is just as easy as can be expected:
  #
  #   require 'application'
  #   include Ogre
  #
  #   class AppListener < ApplicationFrameListener
  #
  #     def frame_started(event)
  #       return false unless super(event)
  #         
  #        ... frame event / input handling ...
  #       
  #       true
  #     end
  #   end
  #
  #   class MyApplication < Application
  #
  #     def create_scene
  #       ...
  #     end
  #
  #     def create_frame_listener
  #       frame_listener = AppListener.new(root, window, camera)
  #     end
  #   end
  #
  #   app = MyApplication.new
  #   app.go
	#
	class ApplicationFrameListener < FrameListener

		attr_accessor :keyboard, :mouse, :joy_stick, :input_manager, :camera, :window

		def initialize(render_window, camera, buffered_keys = false, 
									 buffered_mouse = false, buffered_joy = false)
			@camera = camera
			@window = render_window
			@move_speed = 100
			@rotate_speed = 36
			@move_scale = 0.0
			@rot_scale = 0.0
			@translate_vector = Vector3.new(0,0,0)
			@rot_x = Degree.new(0)
			@rot_y = Degree.new(0)
			@debug_text = ""

#			@debug_overlay = OverlayManager.instance.get_by_name("Core/DebugOverlay")	

#			LogManager.instance.log_message("*** Initializing OIS ***")
			puts "*** Initializing OIS ***"

			windowHnd = @window.get_custom_attribute_int("WINDOW")

      puts "HND is #{windowHnd.inspect}"

      # We disable grab to allow debugging, specifically when running this
      # through gdb
			@input_manager = OIS::InputManager.create_input_system_1(
        {"WINDOW" => "#{windowHnd}", "x11_mouse_grab" => "false", "x11_keyboard_grab" => "false"}
      )
			@keyboard = @input_manager.create_keyboard( buffered_keys )
			@mouse = @input_manager.create_mouse( buffered_mouse )

			# Most likely won't have a joystick here, so just throw away any exceptions
			@joy_stick = nil
#			begin
#				@joy_stick = @input_manager.create_input_object( OIS::OISJoyStick, buffered_joy) unless Platform.mac?
#			rescue
#			end

#			show_debug_overlay(true)

#			@window_event_listener = ApplicationWindowListener.new(@input_manager, @window,
#																														 @keyboard, @mouse,
#																														 @joy_stick)
    
      
#			WindowEventUtilities.add_window_event_listener(@window, @window_event_listener)
		end

		# Ruby doesn't have destructors, just manually call shutdown to clean this up
		def shutdown
#			WindowEventUtilities::remove_window_event_listener(@window, @window_event_listener)
#			@window_event_listener.window_closed(@window)
			
			# Clean up our input objects
			@input_manager = nil
		end

		# Keyboard processing
		def process_unbuffered_key_input(event)
			# Start with basic movement, add overlay stuff later

			# Left
			if @keyboard.key_down?(OIS::KC_A)
				@translate_vector.x = -@move_scale
			end

			# Right
			if @keyboard.key_down?(OIS::KC_D)
				@translate_vector.x = @move_scale
			end

			# Forward
			if @keyboard.key_down?(OIS::KC_UP) || @keyboard.key_down?(OIS::KC_W)
				@translate_vector.z = -@move_scale
			end

			# Back
			if @keyboard.key_down?(OIS::KC_DOWN) || @keyboard.key_down?(OIS::KC_S)
				@translate_vector.z = @move_scale
			end

			# Up
			if @keyboard.key_down?(OIS::KC_PGUP)
				@translate_vector.y = @move_scale
			end

			# Down
			if @keyboard.key_down?(OIS::KC_PGDOWN)
				@translate_vector.y = -@move_scale
			end

			# Turn Right
			if @keyboard.key_down?(OIS::KC_RIGHT)
				@camera.yaw( Degree.new(-@rot_scale) )
			end

			# Turn Left
			if @keyboard.key_down?(OIS::KC_LEFT)
				@camera.yaw( Degree.new(@rot_scale) )
			end

			# Quit
			if @keyboard.key_down?(OIS::KC_ESCAPE) || @keyboard.key_down?(OIS::KC_Q)
				return false;
			end

			# Keep rendering
			true
		end

		def process_unbuffered_mouse_input(event)
			state = @mouse.mouse_state
    
			if state.button_down?(OIS::MB_Right)
				@translate_vector.x += state.X.rel * 0.13
				@translate_vector.y -= state.Y.rel * 0.13
			else
				@rot_x = Degree.new(-state.X.rel * 0.13)
				@rot_y = Degree.new(-state.Y.rel * 0.13)
			end

			true
		end

		# Process the movement we've calculated this frame
		def move_camera
			@camera.yaw(@rot_x)
			@camera.pitch(@rot_y)
			@camera.move_relative(@translate_vector)
		end

		# Toggle debug overlay if one exists
		def show_debug_overlay(show)
			if @debug_overlay
				if show
					@debug_overlay.show
				else
					@debug_overlay.hide
				end
			end
		end

		# Ogre callback, called at the beginning of every frame
		def frame_rendering_queued(event)
			return false if @window.closed?

			# Need to capture input from each device
			@keyboard.capture
			@mouse.capture
			@joy_stick.capture if @joy_stick

			buffered_joy = @joy_stick.nil? ? true : @joy_stick.buffered

			if !@mouse.buffered || !@keyboard.buffered || !buffered_joy
				# If this is the first frame, pick a speed
				if event.time_since_last_frame == 0	
					@move_scale = 1
					@rot_scale = 0.1
				else
					# ~100 units / second
					@move_scale = @move_speed * event.time_since_last_frame
					# ~10 seconds for full rotation
					@rot_scale = @rotate_speed * event.time_since_last_frame
				end

				@rot_x = Degree.new 0
				@rot_y = Degree.new 0

				@translate_vector = Vector3.new 0,0,0
			end

			if !@keyboard.buffered
				return false unless process_unbuffered_key_input(event)
			end

			if !@mouse.buffered
				return false unless process_unbuffered_mouse_input(event)
			end

			if !@mouse.buffered || !@keyboard.buffered || !buffered_joy
				move_camera
			end
			
			# Keep rendering!
			true
		end

		def frame_ended(event)
#			update_stats
			true
		end

		protected

		def update_stats
			@gui_avg ||= OverlayManager.instance.get_overlay_element("Core/AverageFps")
			@gui_curr ||= OverlayManager.instance.get_overlay_element("Core/CurrFps")
			@gui_best ||= OverlayManager.instance.get_overlay_element("Core/BestFps")
			@gui_worst ||= OverlayManager.instance.get_overlay_element("Core/WorstFps")
			@gui_tris ||= OverlayManager.instance.get_overlay_element("Core/NumTris")
			@gui_batches ||= OverlayManager.instance.get_overlay_element("Core/NumBatches")
			@gui_debug ||= OverlayManager.instance.get_overlay_element("Core/DebugText")

			stats = @window.get_statistics

			@gui_curr.set_caption("Current FPS: #{"%.3f" % stats.last_fps}")
			@gui_avg.set_caption("Average FPS: #{"%.3f" % stats.avg_fps}")
			@gui_best.set_caption("Best FPS: #{"%.3f" % stats.best_fps}")
			@gui_worst.set_caption("Worst FPS: #{"%.3f" % stats.worst_fps}")
			@gui_tris.set_caption("Triangle Count: #{stats.triangle_count}")
			@gui_batches.set_caption("Batch Count: #{stats.batch_count}")

			@gui_debug.set_caption(@debug_text)
		end
	end
end
