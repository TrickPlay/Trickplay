
test_description = "Find a ui element using find_child and remove it."
test_steps = "View the device"
test_verify = "Verify that the screen is blank and it says Pass below."
test_group = "acceptance"
test_area = "group"
test_api = "find_child"


function generate_test_image (controller, factory)

	controller:declare_resource("panda", "assets/medium_640x420_panda.jpg")

	local g = factory:Group{ x = 0, y = 0}

	local h = factory:Group{ x = 0, y = 0, name = "group_h"}


	local t1 = factory:Text{x = 10, y = 10, w = 310, h = 50, text = "TrickPlay", color = "FF00FF", font = "Verdana 30px", name = "Trickplay" }

	local r2 = factory:Rectangle{color = "00EB75", x = 10, y = 80, size = { 100 , 100 }, name = "green"}

	local img1 = factory:Image{x = 20, y = 20, w = 300, h = 200, src = "panda", name = "panda"}

	h:add(img1)
	g:add(t1, r2, h)
	local count = 0
	function show_name ( ui_element )
		test_verify_txt.text = test_verify_txt.text.."\n"..ui_element.name
		count = count + 1
		if count == 3 then
			test_verify_txt.text = test_verify_txt.text.."\n\nTest = Pass"
			g:remove(t1, r2, h)
		end
	end

	g:foreach_child ( show_name )
	

	return g
end


	
