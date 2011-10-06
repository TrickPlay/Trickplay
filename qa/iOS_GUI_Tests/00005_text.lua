
test_description = "Display 2 lines of text with modified colors and fonts"
test_steps = "View the device"
test_verify = " Verify 2 lines of text display. Top one is pink and bottom is aqua."
test_group = "smoke"
test_area = "rectangle"
test_api = "basic"


function generate_test_image (controller, factory)

	local g = factory:Group{ x = 0, y = 0}
	
	local t1 = factory:Text{x = 10, y = 10, w = 310, h = 50, text = "TrickPlay", color = "FF00FF", font = "Verdana 30px" }

	local t2 = factory:Text{x = 10, y = 100, w = 310, h = 200, text = "That Sam-I-Am\nThat Sam-I-Am\nI do not like that Sam-I-Am", color = "00FFFF", font = "DeJa Vu 20px"}

	g:add(t1, t2)

	return g
end

	
