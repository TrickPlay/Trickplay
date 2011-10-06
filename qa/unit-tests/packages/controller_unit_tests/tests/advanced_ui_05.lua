
-- Test Set up --

-- Tests --


function test_advanced_ui_image_base_size()
	assert_equal ( img1.base_size[1], 150,  "img1.base_size[1] call not returning the correct value")
	assert_equal ( img1.base_size[2], 61,  "img1.base_size[2] call not returning the correct value")
end

function test_advanced_ui_image_tile()
	assert_true ( img1.tile[1], "img1.tile[1] call not returning the correct value")
	assert_true ( img1.tile[2], "img1.tile[2] call not returning the correct value")
end

function test_advanced_ui_image_loaded_event()
	assert_true ( img1_loaded, "img1_loaded event not called.")
end




-- Test Tear down 

