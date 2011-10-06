
test_description = "Populate the screen with text of various size, color and position"
test_steps = "View the device. This test takes a while to load."
test_verify = "Verify a matrix of text is displayed with font sizes and colors changing from top to bottom."
test_group = "smoke"
test_area = "text"
test_api = "basic"


function generate_test_image (controller)

	local g = controller:Group{ x = 0, y = 0}
	
	local t1 = controller:Text{x = 100, y = 100, w = 1000, h = 50, text = "TrickPlay", color = "FF00FF", font = "Verdana 40px" }

	local t2 = controller:Text{x = 100, y = 300, w = 1000, h = 250, text = "That Sam-I-Am\nThat Sam-I-Am\nI do not like that Sam-I-Am", color = "00FFFF", font = "DeJa Vu 40px"}
	g:add(t1, t2)

	return g
end

