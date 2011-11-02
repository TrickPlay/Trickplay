
-- Test Set up --

-- Tests --

function test_advanced_ui_scale ()
	assert_equal ( math.ceil(r1.scale[1]), 2,  "r1.scale[1] not returning the correct value")
	assert_equal ( math.ceil(r1.scale[2]), 2, "r1.scale[2] not returning the correct value")
end

function test_advanced_ui_rotation ()
	-- As iOs controller often returns float values, using float compare code
    	local relative_error_x = math.abs((r1.x_rotation - 20) / math.max(r1.x_rotation, 20))
 	local relative_error_y = math.abs((r1.y_rotation - 30) / math.max(r1.y_rotation, 30))
  	local relative_error_z = math.abs((r1.z_rotation - 40) / math.max(r1.z_rotation, 40))
    	local epsilon = 0.000001
    	assert_less_than( relative_error_x, epsilon, "r1.x_rotation failed")
    	assert_less_than( relative_error_y, epsilon, "r1.y_rotation failed")
    	assert_less_than( relative_error_z, epsilon, "r1.z_rotation failed")
	
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

