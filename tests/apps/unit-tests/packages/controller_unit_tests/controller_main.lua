-- Unit Test Framework
dofile( "packages/controller_unit_tests/unit_test.lua" )

-- Unit Tests


dofile( "packages/controller_unit_tests/ui_input1.lua" ) 
dofile( "packages/controller_unit_tests/set_ui_background1.lua" )
dofile( "packages/controller_unit_tests/supported_functionality1.lua" ) 
dofile( "packages/controller_unit_tests/accelerometer1.lua" )
dofile( "packages/controller_unit_tests/multiple_choice1.lua" )
dofile( "packages/controller_unit_tests/play_stop_sound1.lua" )
dofile( "packages/controller_unit_tests/declare_resource1.lua" )
dofile( "packages/controller_unit_tests/enter_text1.lua" )
dofile( "packages/controller_unit_tests/reset1.lua" )
dofile( "packages/controller_unit_tests/clear_ui1.lua" )

device_is_connected = false
device_app_connected = false


function controllers:on_controller_connected(controller)

	declare_resource_status = controller:declare_resource("logo", "packages/controller_unit_tests/assets/logo.png")
	controller:declare_resource("jack", "packages/assets/controller_unit_tests/jack.jpg")
	controller:declare_resource("glee", "packages/assets/controller_unit_tests/glee-1.mp4")

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
	device_has_pictures = controller.has_pictures
--	device_has_audio_clips = controller.has_audio_clips
	device_has_advanced_ui = controller.has_advanced_ui
	ui_size = controller.ui_size
	input_size = controller.input_size
	start_accelerometer_status = controller:start_accelerometer ("L", 1)
	stop_accelerometer_status = controller:stop_accelerometer ("L", 1)
	set_ui_image_status = controller:set_ui_image("jack", 0, 0, 50, 50)	
	play_sound_status = controller:play_sound ("glee", 1)
	stop_sound_status = controller:stop_sound ("glee")
	set_ui_background_status = controller:set_ui_background("logo", "STRETCH")	
	enter_text_status = controller:enter_text ("label", "text")
	multiple_choice_status = controller:show_multiple_choice ( "logo", "1", "pick me", "2", "no, pick me")
	clear_ui_status = controller:clear_ui()
	reset_status = controller:reset()
end

steps_txt.text = "1. Connect to a Device with Trickplay installed.\n2. Select the QA_Test_TV server.\n3.Verify that all tests pass."

screen:show()

function idle.on_idle( idle , seconds )
	
      if device_is_connected == true then
        local results = unit_test()  
        idle.on_idle = nil
      end
end

