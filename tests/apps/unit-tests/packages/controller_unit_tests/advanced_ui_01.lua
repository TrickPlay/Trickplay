
-- Test Set up --

-- Tests --
function test_advanced_ui_position ()
	assert_equal ( r1.x, 100,  "r1[x] not returning the correct value")
	assert_equal ( r1.y, 100, "r1[y] not returning the correct value")
	assert_equal ( r1.z, 0, "r1[z] not returning the correct value")
end

function test_advanced_ui_size ()
	assert_equal (r1.w, 200,  "r1[w] not returning the correct value")
	assert_equal ( r1.h, 250, "r1[h] not returning the correct value")
end

function test_advanced_ui_gid ()
	is_string ( r1.gid, "r1[gid] not returning the correct value")
end

function test_advanced_ui_name ()
	assert_equal ( r1.name, "rect1", "r1[name] not returning the correct value")
end

function test_advanced_ui_center ()
	--dumptable (r1["center"])
	assert_equal ( r1.center[1], 100,  "r1.center[1] not returning the correct value.\n ** Bug 1957 **\n")
	assert_equal ( r1.center[2], 125, "r1.center[2] not returning the correct value")
end

function test_advanced_ui_anchor_point ()	
	assert_equal ( r1.anchor_point[1], 10,  "r1.anchor_point[1] not returning the correct value")
	assert_equal ( r1.anchor_point[2], 10, "r1.anchor_point[2] not returning the correct value")
end

function test_advanced_ui_opacity ()
	assert_equal ( r1.opacity, 200,  "r1.opacity not returning the correct value")
end


function test_advanced_ui_is_visible ()
	assert_true ( r1.is_visible, "r1.is_true not returning the true")
end


-- Test Tear down 

