
-- Test Set up --

-- Tests --

function test_advanced_ui_scale ()
	assert_equal ( math.ceil(ui_element["scale"][1]), 2,  "ui_element.scale[1] not returning the correct value")
	assert_equal ( math.ceil(ui_element["scale"][2]), 2, "ui_element.scale[2] not returning the correct value")
end

function test_advanced_ui_rotation ()
	assert_equal ( ui_element["x_rotation"], 20,  "ui_element.x_rotation not returning the correct value")
	assert_equal ( ui_element["y_rotation"], 30,  "ui_element.y_rotation not returning the correct value")
	assert_equal ( ui_element["z_rotation"], 40,  "ui_element.z_rotation not returning the correct value")
	
end

function test_advanced_ui_is_scaled ()
	assert_true (ui_element["is_scaled"],  "ui_element.is_scaled not returning true")
end

function test_advanced_ui_is_rotated ()
	assert_true (ui_element["is_rotated"],  "ui_element.is_rotated not returning true")
end

function test_advanced_ui_clip ()
	assert_equal ( ui_element["clip"][1], 0,  "ui_element.clip[1] not returning the correct value")
	assert_equal ( ui_element["clip"][2], 0,  "ui_element.clip[2] not returning the correct value")
	assert_equal ( ui_element["clip"][3], 40,  "ui_element.clip[3] not returning the correct value")
	assert_equal ( ui_element["clip"][4], 40,  "ui_element.clip[4] not returning the correct value")
end

function test_advanced_ui_has_clip ()
	assert_true (ui_element["has_clip"],  "ui_element.has_clip not returning true")
end

-- Test Tear down 

