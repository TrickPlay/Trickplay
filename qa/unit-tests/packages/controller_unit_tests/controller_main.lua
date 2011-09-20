-- Unit Test Framework
dofile( "packages/controller_unit_tests/unit_test.lua" )

-- Unit Tests Package 

dofile( "packages/controller_unit_tests/ui_input1.lua" ) 
dofile( "packages/controller_unit_tests/set_ui_background1.lua" )
dofile( "packages/controller_unit_tests/set_ui_image1.lua" )
dofile( "packages/controller_unit_tests/supported_functionality1.lua" ) 
dofile( "packages/controller_unit_tests/accelerometer1.lua" )
dofile( "packages/controller_unit_tests/multiple_choice1.lua" )
dofile( "packages/controller_unit_tests/play_stop_sound1.lua" )
dofile( "packages/controller_unit_tests/declare_resource1.lua" )
dofile( "packages/controller_unit_tests/enter_text1.lua" )
dofile( "packages/controller_unit_tests/reset1.lua" )
dofile( "packages/controller_unit_tests/clear_ui1.lua" )
dofile( "packages/controller_unit_tests/advanced_ui_01.lua" )
dofile( "packages/controller_unit_tests/advanced_ui_02.lua" ) 
dofile( "packages/controller_unit_tests/advanced_ui_03.lua" )
dofile( "packages/controller_unit_tests/advanced_ui_04.lua" )
dofile( "packages/controller_unit_tests/advanced_ui_05.lua" )


device_is_connected = false
device_app_connected = false

function controllers:on_controller_connected(controller)

 	print("CONNECTED", controller.name)

    local on_idle_creation
	function controller:on_advanced_ui_ready()
		class_table = dofile("AdvancedUIClasses.lua")
		controller.factory = loadfile("AdvancedUIAPI.lua")(controller)

        on_idle_creation()
	end

	-- Load some testing assets
	controller:declare_resource("jack", "packages/controller_unit_tests/assets/jack.jpg")
	controller:declare_resource("glee", "packages/controller_unit_tests/assets/glee-1.mp4")

	-- support_functionality1.lua	[start]
	device_app_connected = true
	device_is_connected = controller.is_connected
	device_controller_name = controller.name
	device_has_keys = controller.has_keys
	device_has_accelerometer = controller.has_accelerometer
	device_has_touches = controller.has_touches
	device_has_multiple_choice = controller.has_multiple_choice
	device_has_sound = controller.has_sound
	device_has_ui = controller.has_ui
	device_has_text_entry = controller.has_text_entry
	device_has_images = controller.has_images
	device_has_audio_clips = controller.has_audio_clips
	device_has_advanced_ui = controller.has_advanced_ui

	-- support_functionality1.lua	[end]


	-- ui_input1.lua				test_controllers_ui_size
	ui_size = controller.ui_size

	-- ui_input1.lua				test_controllers_id
	ui_id = controller.id

	-- ui_input1.lua				test_controllers_input_size
	input_size = controller.input_size

	-- accelerometer1.lua			test_controllers_start_accelerometer
	start_accelerometer_status = controller:start_accelerometer ("L", 1)

	-- accelerometer1.lua			test_controllers_stop_accelerometer
	stop_accelerometer_status = controller:stop_accelerometer ("L", 1)

	-- set_ui_image1.lua			test_controllers_set_ui_image
	set_ui_image_status = controller:set_ui_image("jack", 0, 0, 50, 50)	

	-- play_stop_sound1.lua				test_controllers_play_sound
	play_sound_status = controller:play_sound ("glee", 1)

	-- play_stop_sound1.lua				test_controllers_stop_sound
	stop_sound_status = controller:stop_sound ("glee")

	-- set_ui_background1.lua				test_controllers_set_ui_background
	set_ui_background_status = controller:set_ui_background("logo", "STRETCH")	

	-- enter_text1.lua				test_controllers_enter_text
	enter_text_status = controller:enter_text ("label", "text")

	-- multiple_choice1.lua				test_controllers_show_multiple_choice
	--multiple_choice_status = controller:show_multiple_choice ( "logo", "1", "pick me", "2", "no, pick me")

	-- clear_ui1.lua				test_controllers_clear_ui 
	clear_ui_status = controller:clear_ui()

	-- reset1.lua				test_controllers_reset
	reset_status = controller:reset()

	-- declare_resource1.lua 		test_controllers_declare_resource_status
	declare_resource_status = controller:declare_resource("logo", "packages/controller_unit_tests/assets/logo.png")

	-- Using on_idle to delay calling controller.factory as it takes time to load it.
	local total = 0
	local test_setup_complete = false
	on_text_changed_called = false
	img1_loaded = false
	local counter = 0
    function on_idle_creation()
    	function idle.on_idle( idle , seconds )	
			
			total = total + seconds

	    	if total > 1 and test_setup_complete == false then


				
				r1 = controller.factory:Rectangle {
						color = "0070E0", 
						border_width = 5,
						border_color = { 170, 0, 255 },
						-- advanced_ui_01.lua		test_advanced_ui_position
						x = 100, 
						y = 100,
						z = 0, 
						
						-- advanced_ui_01.lua		test_advanced_ui_size
						size = { 200 , 250 },

						-- advanced_ui_01.lua		test_advanced_ui_name
						name = "rect1",

						-- advanced_ui_02.lua		test_advanced_ui_scale
						scale = { 2, 2 },

						-- advanced_ui_02.lua		test_advanced_ui_rotation
						x_rotation = 20,
						y_rotation = 30,
						z_rotation = 40,
						
						-- advanced_ui_01.lua		test_advanced_ui_opacity
						opacity = 200,

						-- advanced_ui_02.lua		test_advanced_ui_clip
						clip = {0, 0, 40, 40 },

						-- advanced_ui_01.lua		test_advanced_ui_anchor_point (bug 1958)
						anchor_point = {10, 10}  
				 }



				r2 = controller.factory:Rectangle {name = "rect2"}
		
				-- advanced_ui_03.lua		test_advanced_ui_parent  (r1.parent.name returns G1)
				G1 = controller.factory:Group{name = "G1"}
				G1:add(r1)			
				controller.screen:add(G1)

				-- advanced_ui_03.lua		test_advanced_ui_children  (rG2.children[2].name returns rect1)
				G2 = controller.factory:Group{name = "G2"}
				G2:add(r2)



				text1 = controller.factory:Text {
					x = 10,
					y = 200,
					w = 250,
					h = 80,
					text = "That Sam-I-Am. That Sam-I-Am. I do not like that Sam-I-Am. Do you like green eggs and ham?",
					
					-- advanced_ui_04.lua		test_advanced_ui_text_color
					color = "00FFFF",

					-- advanced_ui_04.lua		test_advanced_ui_text_font
					font = "TrebuchetMS 20px",

					-- advanced_ui_04.lua		test_advanced_ui_text_wrap
					wrap = true,

					-- advanced_ui_04.lua		test_advanced_ui_text_wrap_mode
					wrap_mode = "CHAR",

					-- advanced_ui_04.lua		test_advanced_ui_text_max_length
					max_length = 30,
					-- advanced_ui_04.lua		test_advanced_ui_text_alignment
					alignment = "RIGHT",
					-- advanced_ui_04.lua		test_advanced_ui_text_line_spacing
					line_spacing = 10
				 }
				controller.screen:add(text1)

				text2 = controller.factory:Text {
					x = 10,
					y = 300,
					w = 100,
					h = 80,
					text = "The sun did not shine. It was too wet to play. So we sat in the house all the cold, cold wet day. I sat there with Sally. We sat there we two. I sat there with Sally and said what shall we do.",
					color = "00FFFF",
					font = "TrebuchetMS 20px",
					ellipsize = "END",
					-- advanced_ui_04.lua		test_advanced_ui_text_password_char
					password_char = true
				 }

				controller.screen:add(text2)

				text3 = controller.factory:Text {
					x = 10,
					y = 10,
					w = 200,
					h = 200,
					text = "The sun did not shine. It was too wet to play. So we sat in the house all the cold, cold wet day. I sat there with Sally. We sat there we two. I sat there with Sally and said what shall we do.",
					color = "00FFFF",
					font = "TrebuchetMS 12px",

					-- advanced_ui_04.lua		test_advanced_ui_text_justify
					justify = true,
					wrap = true
				 }

				controller.screen:add(text3)

				text2.on_text_changed = function ()
					counter = counter + 1
					on_text_changed_called = true
				end

				-- advanced_ui_05.lua		test_advanced_ui_image_base_size
				img1 = controller.factory:Image{
							x = 100,
							y = 100,
							src = "logo",
				-- advanced_ui_05.lua		test_advanced_ui_image_tile
							tile = {true, true }
					}

				-- advanced_ui_05.lua		test_advanced_ui_image_loaded_event
				img1.on_loaded = function ()
					img1_loaded = true
				end

				controller.screen:add(img1)
				


				test_setup_complete = true
			elseif total > 3 and test_setup_complete == true and img1_loaded == true then

				-- advanced_ui_04.lua		test_advanced_ui_event_on_text_changed
				text2.text = "test"

	      		local controller_results = controller_unit_test()  
				idle.on_idle = nil
             end
        end
    end
	

    function controller:on_disconnected()
        print("DISCONNECTED", controller.name)
    end


end


-- Run on connected for all controllers already connected
for k,controller in pairs(controllers.connected) do
    if controller.name ~= "Keyboard" then
        controllers:on_controller_connected(controller)
        controller:on_advanced_ui_ready()
    end
end


layout["ui3"].steps_txt.text = "1. Connect to a Device with Trickplay installed.\n2. Select the QA_Test_TV server.\n3.Verify that all tests pass."

screen:show()




