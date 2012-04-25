
test_description = "Clear UI clears all UI items on the screen."
test_steps = "Touch the 'Press this' button"
test_verify = "Verify that only the Tickplay logo pic is removed."
test_group = "acceptance"
test_area = "clear_ui"
test_api = "clear_ui"


function generate_device_image (controller, factory)

	local g = factory:Group{ x = 0, y = 0}

	local r1 = factory:Rectangle{color = "FF00FFFF", x = 0, y = 170, size = { 100 , 50 },border_color = "00FF00", border_width = 10}

	local t1 = factory:Text{x = 10, y = 110, w = 200, h = 20, text = "TrickPlay", color = "FF00FF", font = "Verdana 15px" }


	controller:declare_resource("panda", "assets/medium_640x420_panda.jpg")
	controller:declare_resource("logo", "assets/logo.png")
	controller:declare_resource("background", "assets/bkgd-blank.jpg")


	local img1 = factory:Image{x = 0, y = 0, w = 150, h = 100, src = "panda"}
	controller:set_ui_image ("logo", 110, 170, 40, 40 )
	controller:set_ui_background ("background", "CENTER")
	
	g:add(t1, r1, img1)


	function controller.on_ui_event (controller, text)
		controller:clear_ui()
	end 	  

	controller:show_multiple_choice( "Clear UI Test","1","Press this")


	return g
end

function generate_match_image (resize_ratio_w, resize_ratio_h)

	local t1 = Text{x = 10 * resize_ratio_w, y = 10 * resize_ratio_h, w = 310 * resize_ratio_w, h = 50 * resize_ratio_h, markup = "Device screen should be clear.", color = "FFFFFF", font = "Verdana 30px", use_markup = true}

	return t1
end

