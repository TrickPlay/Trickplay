
-- Test Set up --

-- Tests --


function test_advanced_ui_rect_border_width ()
	assert_equal ( ui_element["border_width"], 5,  "rect.border_width not returning the correct value")
end

function test_advanced_ui_rect_border_color ()
	assert_equal ( ui_element["border_color"][1], 170,  "rect.border_color[1]_width not returning the correct value")
	assert_equal ( ui_element["border_color"][2], 0,  "rect.border_color[2]_width not returning the correct value")
	assert_equal ( ui_element["border_color"][3], 255,  "rect.border_color[3]_width not returning the correct value")

end



-- Test Tear down 

