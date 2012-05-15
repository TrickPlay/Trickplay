
test_description = "Display a variety of Pango text options"
test_steps = "View the device"
test_verify = " Compare the device to the screenshot."
test_group = "acceptance"
test_area = "Text"
test_api = "Pango"


function generate_device_image (controller, factory)

	local g = factory:Group{ x = 0, y = 0}
	
	local t1 = factory:Text{x = 10, y = 10, w = 500, h = 200, markup = "<span font=\"Verdana 30px\" foreground=\"blue\" size=\"x-large\">Blue text is <i>italicized</i>!</span>"}

	local t2 = factory:Text{x = 10, y = 50, w = 500, h = 200, markup = "<span font_desc=\"Verdana 20px\" foreground=\"red\">Red text is <b>bold</b>!</span>"}

	local t3 = factory:Text{x = 10, y = 90, w = 500, h = 200, markup = "<span font_desc=\"Verdana 20px\" foreground=\"#FFFFFF\" font_style=\"oblique\">White text is oblique!</span>"}

	local t4 = factory:Text{x = 10, y = 130, w = 500, h = 200, markup = "<span font=\"Verdana 30px\" foreground=\"green\" font_weight=\"heavy\">Green text is heavy!</span>"}

	local t5 = factory:Text{x = 10, y = 170, w = 500, h = 200, markup = "<span font=\"Courier 30px\" foreground=\"pink\" font_weight=\"100\">Pink text is 100 weight!</span>"}

	local t6 = factory:Text{x = 10, y = 210, w = 500, h = 200, markup = "<span  font=\"Courier 20px\" foreground=\"yellow\" stretch=\"expanded\">Yellow text is expanded!</span>"}

	local t7 = factory:Text{x = 10, y = 250, w = 500, h = 200, markup = "<span font=\"Courier 20px\" foreground=\"yellow\" font_stretch=\"condensed\">Yellow text is condensed!</span>"}

	local t8 = factory:Text{x = 10, y = 290, w = 500, h = 200, markup = "<span font=\"Courier 20px\" background=\"white\" font_stretch=\"condensed\">white background is condensed!</span>"}

	local t9 = factory:Text{x = 10, y = 330, w = 500, h = 200, markup = "<span font=\"Courier 20px\" foreground=\"red\" underline=\"single\" underline_color=\"red\">red text is underlined!</span>"}


	g:add(t1, t2, t3, t4, t5, t6, t7, t8, t9)

	return g
end

function generate_match_image (resize_ratio_w, resize_ratio_h)

	local g = Group{ x = 0, y = 0}

	local t1 = Text{x = 10 * resize_ratio_w, y = 10 * resize_ratio_h, w = 500 * resize_ratio_w, h = 200 * resize_ratio_h, markup = "<span font=\"Verdana 30px\" foreground=\"blue\" size=\"x-large\">Blue text is <i>italicized</i>!</span>", use_markup = true, color = "00FFFF", font = "DeJa Vu 20px"}

	local t2 = Text{x = 10 * resize_ratio_w, y = 50 * resize_ratio_h, w = 500 * resize_ratio_w, h = 200 * resize_ratio_h, markup = '<span font_desc=\"Verdana 20px\" foreground=\"red\">Red text is <b>bold</b>!</span>', use_markup = true}

	local t3 = Text{x = 10 * resize_ratio_w, y = 90 * resize_ratio_h, w = 500 * resize_ratio_w, h = 200 * resize_ratio_h, markup = "<span font_desc=\"Verdana 20px\" foreground=\"#FFFFFF\" font_style=\"oblique\">White text is oblique!</span>", use_markup = true}

	local t4 = Text{x = 10 * resize_ratio_w, y = 130 * resize_ratio_h, w = 500 * resize_ratio_w, h = 200 * resize_ratio_h, markup = "<span font=\"Verdana 30px\" foreground=\"green\" font_weight=\"heavy\">Green text is heavy!</span>", use_markup = true}

	local t5 = Text{x = 10 * resize_ratio_w, y = 170 * resize_ratio_h, w = 500 * resize_ratio_w, h = 200 * resize_ratio_h, markup = "<span font=\"Courier 30px\" foreground=\"pink\" font_weight=\"100\">Pink text is 100 weight!</span>", use_markup = true}

	local t6 = Text{x = 10 * resize_ratio_w, y = 210 * resize_ratio_h, w = 500 * resize_ratio_w, h = 200 * resize_ratio_h, markup = "<span  font=\"Courier 20px\" foreground=\"yellow\" stretch=\"expanded\">Yellow text is expanded!</span>", use_markup = true}

	local t7 = Text{x = 10 * resize_ratio_w, y = 250 * resize_ratio_h, w = 500 * resize_ratio_w, h = 200 * resize_ratio_h, markup = "<span font=\"Courier 20px\" foreground=\"yellow\" font_stretch=\"condensed\">Yellow text is condensed!</span>", use_markup = true}

	local t8 = Text{x = 10 * resize_ratio_w, y = 290 * resize_ratio_h, w = 500 * resize_ratio_w, h = 200 * resize_ratio_h, markup = "<span font=\"Courier 20px\" background=\"white\" font_stretch=\"condensed\">white background is condensed!</span>", use_markup = true}

	local t9 = Text{x = 10 * resize_ratio_w, y = 330 * resize_ratio_h, w = 500 * resize_ratio_w, h = 200 * resize_ratio_h, markup = "<span font=\"Courier 20px\" foreground=\"red\" underline=\"single\" underline_color=\"red\">red text is underlined!</span>", use_markup = true}

	g:add(t1, t2, t3, t4, t5, t6, t7, t8, t9)

	return g
end


	
