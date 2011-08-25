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
dofile( "packages/controller_unit_tests/advanced_ui_01.lua" )

dofile( "packages/controller_unit_tests/advanced_ui_02.lua" )
dofile( "packages/controller_unit_tests/advanced_ui_03.lua" )
dofile( "packages/controller_unit_tests/advanced_ui_04.lua" )

device_is_connected = false
device_app_connected = false
ui_element = {}

function controllers:on_controller_connected(controller)

 	print("CONNECTED", controller.name)

    local on_idle_creation
	function controller:on_advanced_ui_ready()
		class_table = dofile("AdvancedUIClasses.lua")
		controller.factory = loadfile("AdvancedUIAPI.lua")(controller)

        on_idle_creation()
	end

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
	device_has_images = controller.has_images
	device_has_audio_clips = controller.has_audio_clips
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
	--multiple_choice_status = controller:show_multiple_choice ( "logo", "1", "pick me", "2", "no, pick me")
	clear_ui_status = controller:clear_ui()
	reset_status = controller:reset()

	-- Using on_idle to delay calling controller.factory as it takes time to load it.
	local total = 0
    function on_idle_creation()
    	function idle.on_idle( idle , seconds )	
			total = total + seconds
	    	if total > 3 then

				-- Tests: advanced_ui_01 to advanced_ui_04 (UI_element, rectangle, container)
				local r1 = controller.factory:Rectangle {
						color = "0070E0", 
						border_width = 5,
						border_color = { 170, 0, 255 },
						x = 100, 
						y = 100,
						z = 0, 
						size = { 200 , 250 },
						name = "rect1",
						scale = { 2, 2 },
						x_rotation = 20,
						y_rotation = 30,
						z_rotation = 40,
						opacity = 200,
						clip = {0, 0, 40, 40 },
						anchor_point = {10, 10}  --  bug 1958.
				 }

				local r2 = controller.factory:Rectangle {name = "rect2"}


				ui_element["x"] = r1.position[1]
				ui_element["y"] = r1.position[2]
				ui_element["z"] = r1.position[3]
				ui_element["w"] = r1.w
				ui_element["h"] = r1.h
				ui_element["gid"] = r1.gid
				ui_element["name"] = r1.name
				ui_element["center"] = r1.center
				ui_element["anchor_point"] = r1.anchor_point	
				ui_element["scale"] = r1.scale	
				ui_element["x_rotation"] = r1.x_rotation
				ui_element["y_rotation"] = r1.y_rotation
				ui_element["z_rotation"] = r1.z_rotation
				ui_element["is_scaled"] = r1.is_scaled
				ui_element["is_rotated"] = r1.is_rotated
				ui_element["opacity"] = r1.opacity
				ui_element["clip"] = r1.clip
				ui_element["has_clip"] = r1.has_clip
				ui_element["is_visible"] = r1.is_visible
				ui_element["border_width"] = r1.border_width
				ui_element["border_color"] = r1.border_color
		
		
				local G1 = controller.factory:Group{name = "G1"}
				G1:add(r1)			
				controller.screen:add(G1)

				local G2 = controller.factory:Group{name = "G2"}
				G2:add(r2)
				ui_element["parent.name"] = r1.parent.name
				ui_element["children"] = G2.children

--[[
				r1.on_show = function ()
					print ("aasfasdfasdfa")
				end

				r1:hide()
				r1:show()

--]]

				-- tests: Advanced_UI

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




