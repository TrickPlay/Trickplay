
test_description = "Display a variety of Pango text options"
test_steps = "View the device"
test_verify = " Compare the device to the screenshot."
test_group = "acceptance"
test_area = "Text"
test_api = "Pango"


function generate_test_image (controller, factory)

	local g = factory:Group{ x = 0, y = 0}
	
	local t1 = factory:Text{x = 10, y = 10, w = 500, h = 200, markup = "<span font=\"Verdana 30px\" foreground=\"blue\" size=\"x-large\">Blue text is <i>italicized</i>!"}

	local t2 = factory:Text{x = 10, y = 50, w = 500, h = 200, markup = "<span font_desc=\"Verdana 20px\" foreground=\"red\">Red text is <b>bold</b>!"}

	local t3 = factory:Text{x = 10, y = 90, w = 500, h = 200, markup = "<span font_desc=\"Verdana 20px\" foreground=\"#FFFFFF\" font_style=\"oblique\">White text is oblique!"}

	local t4 = factory:Text{x = 10, y = 130, w = 500, h = 200, markup = "<span font=\"Verdana 30px\" foreground=\"green\" font_weight=\"heavy\">Green text is heavy!"}

	local t5 = factory:Text{x = 10, y = 170, w = 500, h = 200, markup = "<span font=\"Courier 30px\" foreground=\"pink\" font_weight=\"100\">Pink text is 100 weight!"}

	local t6 = factory:Text{x = 10, y = 210, w = 500, h = 200, markup = "<span  font=\"Courier 20px\" foreground=\"yellow\" stretch=\"expanded\">Yellow text is expanded!"}

	local t7 = factory:Text{x = 10, y = 250, w = 500, h = 200, markup = "<span font=\"Courier 20px\" foreground=\"yellow\" font_stretch=\"condensed\">Yellow text is condensed!"}

	local t8 = factory:Text{x = 10, y = 290, w = 500, h = 200, markup = "<span font=\"Courier 20px\" background=\"white\" font_stretch=\"condensed\">white background is condensed!"}

	local t9 = factory:Text{x = 10, y = 330, w = 500, h = 200, markup = "<span font=\"Courier 20px\" foreground=\"red\" underline=\"single\" underline_color=\"red\">red text is underlined!"}


	g:add(t1, t2, t3, t4, t5, t6, t7, t8, t9)

	return g
end

	
