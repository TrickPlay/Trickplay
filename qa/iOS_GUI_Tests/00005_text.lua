
test_description = "Display 2 lines of text with modified colors and fonts"
test_steps = "View the device"
test_verify = " Verify 2 lines of text display. Top one is pink and bottom is aqua."
test_group = "smoke"
test_area = "rectangle"
test_api = "basic"


function generate_device_image (controller, factory)

	local g = factory:Group{ x = 0, y = 0}
	
	local t1 = factory:Text{x = 10, y = 10, w = 310, h = 50, text = "TrickPlay", color = "FF00FF", font = "Verdana 30px" }

	local t2 = factory:Text{x = 10, y = 100, w = 310, h = 200, text = "That Sam-I-Am\nThat Sam-I-Am\nI do not like that Sam-I-Am", color = "00FFFF", font = "DeJa Vu 20px"}

	local t3 = factory:Text{x = 10, y = 200, w = 510, h = 200, text = "<span foreground=\"blue\" size=\"x-large\">This text</span> should display several tags and <i>have no italicizations.</i>!", font = "DeJa Vu 20px"}

	g:add(t1, t2, t3)

	return g
end

function generate_match_image (resize_ratio_w, resize_ratio_h)

	local g = Group{ x = 0, y = 0}
	
	local t1 = Text{x = 10 * resize_ratio_w, y = 10 * resize_ratio_h, w = 310 * resize_ratio_w, h = 50 * resize_ratio_h, markup = "TrickPlay", color = "FF00FF", font = "Verdana 30px", use_markup = true}

	local t2 = Text{x = 10 * resize_ratio_w, y = 100 * resize_ratio_h, w = 310 * resize_ratio_w, h = 200 * resize_ratio_h, markup = "That Sam-I-Am\nThat Sam-I-Am\nI do not like that Sam-I-Am", color = "00FFFF", font = "DeJa Vu 20px", use_markup = true}

	local t3 = Text{x = 10 * resize_ratio_w, y = 200 * resize_ratio_h, w = 510 * resize_ratio_w, h = 200 * resize_ratio_h, markup = "<span foreground=\"blue\" size=\"x-large\">This text</span> should display several tags and <i>have no italicizations.</i>!", font = "DeJa Vu 20px", use_markup = false}

	g:add(t1, t2, t3)


	return g
end
