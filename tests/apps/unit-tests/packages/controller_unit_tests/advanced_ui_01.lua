
-- Test Set up --

-- Tests --
function test_advanced_ui_position ()
	--dumptable (ui_size)
	assert_equal ( ui_element["x"], 100,  "ui_element[x] not returning the correct value")
	assert_equal ( ui_element["y"], 100, "ui_element[y] not returning the correct value")
	assert_equal ( ui_element["z"], 0, "ui_element[z] not returning the correct value")
end

function test_advanced_ui_size ()
	--dumptable (ui_size)
	assert_equal ( ui_element["w"], 200,  "ui_element[w] not returning the correct value")
	assert_equal ( ui_element["h"], 250, "ui_element[h] not returning the correct value")
end

function test_advanced_ui_gid ()
	is_string ( ui_element["gid"], "ui_element[gid] not returning the correct value")
end

function test_advanced_ui_name ()
	assert_equal ( ui_element["name"], "rect1", "ui_element[name] not returning the correct value")
end

function test_advanced_ui_center ()
	--dumptable (ui_element["center"])
	assert_equal ( ui_element["center"][1], 100,  "ui_element.center[1] not returning the correct value")
	assert_equal ( ui_element["center"][2], 125, "ui_element.center[2] not returning the correct value")
end

function test_advanced_ui_anchor_point ()
	assert_equal ( ui_element["anchor_point"][1], 10,  "ui_element.anchor_point[1] not returning the correct value")
	assert_equal ( ui_element["anchor_point"][2], 10, "ui_element.anchor_point[2] not returning the correct value")
end

function test_advanced_ui_opacity ()
	assert_equal ( ui_element["opacity"], 200,  "ui_element.opacity not returning the correct value")
end


function test_advanced_ui_is_visible ()
	assert_true ( ui_element["is_visible"], "ui_element.is_true not returning the true")
end


-- Test Tear down 

