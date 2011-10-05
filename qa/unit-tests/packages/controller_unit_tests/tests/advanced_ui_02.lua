
-- Test Set up --

-- Tests --

function test_advanced_ui_scale ()
	assert_equal ( math.ceil(r1.scale[1]), 2,  "r1.scale[1] not returning the correct value")
	assert_equal ( math.ceil(r1.scale[2]), 2, "r1.scale[2] not returning the correct value")
end

function test_advanced_ui_rotation ()
	assert_equal ( r1.x_rotation, 20,  "r1.x_rotation not returning the correct value")
	assert_equal ( r1.y_rotation, 30,  "r1.y_rotation not returning the correct value")
	assert_equal ( r1.z_rotation, 40,  "r1.z_rotation not returning the correct value")
	
end

function test_advanced_ui_is_scaled ()
	assert_true (r1.is_scaled,  "r1.is_scaled not returning true")
end

function test_advanced_ui_is_rotated ()
	assert_true (r1.is_rotated,  "r1.is_rotated not returning true")
end

function test_advanced_ui_clip ()
	assert_equal ( r1.clip[1], 0,  "r1.clip[1] not returning the correct value")
	assert_equal ( r1.clip[2], 0,  "r1.clip[2] not returning the correct value")
	assert_equal ( r1.clip[3], 40,  "r1.clip[3] not returning the correct value")
	assert_equal ( r1.clip[4], 40,  "r1.clip[4] not returning the correct value")
end

function test_advanced_ui_has_clip ()
	assert_true (r1.has_clip,  "r1.has_clip not returning true")
end

-- Test Tear down 

