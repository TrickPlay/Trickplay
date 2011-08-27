
-- Test Set up --

-- Tests --


function test_advanced_ui_event_on_text_changed ()
	assert_true ( on_text_changed_called,  "on_text_changed_call not returning the true")
end

function test_advanced_ui_text_color ()
	assert_equal ( text1.color[1], 0,  "text1.color[1] not returning the correct value")
	assert_equal ( text1.color[2], 255,  "text1.color[2] not returning the correct value")
	assert_equal ( text1.color[3], 255,  "text1.color[3] not returning the correct value")
end

function test_advanced_ui_text_font ()
	--print ("text1.font = ", text1.font)
	assert_equal ( text1.font, " TrebuchetMS 20.000000px",  "text1.font not returning the correct value")
end

function test_advanced_ui_text_justify ()
	assert_true ( text3.justify,  "text3.justify call not returning the true")
end

function test_advanced_ui_text_wrap ()
	assert_true ( text3.wrap,  "text3.wrap call not returning the true")
end

function test_advanced_ui_text_wrap_mode ()
	assert_equal( text1.wrap_mode, "CHAR", "text1.wrap_mode call not returning CHAR")
end

function test_advanced_ui_text_ellipsize ()
	--print ( "text2.ellipsize = ",  text2.ellipsize)
	assert_equal( text2.ellipsize, "END", "text1.ellipsize call not returning END.\n** Bug 1968 ** \n")
end

function test_advanced_ui_text_password_char()
	assert_true ( text2.password_char,  "text2.password_char call not returning the true")
end

function test_advanced_ui_text_max_length ()
	assert_equal( text1.max_length, 30, "text1.max_length call not returning correct value.")
end

function test_advanced_ui_text_line_spacing ()
	assert_equal( text1.line_spacing, 10, "text1.line_spacing call not returning correct value.")
end

function test_advanced_ui_text_alignment ()
	assert_equal( text1.alignment, "RIGHT", "text1.alignment call not returning correct value.")
end



-- Test Tear down 

