
-- Test Set up --

-- Tests --


function test_advanced_ui_parent ()
	assert_equal ( ui_element["parent.name"], "G1",  "ui_element.group.parent not returning the correct value")
end
--[[
function test_advanced_ui_children () --bug ui_element.children is returning an empty table.
	assert_equal ( ui_element["children"][2].name, "G1",  "ui_element.group.children not returning the correct value")
end
--]]
function test_advanced_ui_has_clip ()
	assert_true (ui_element["has_clip"],  "ui_element.has_clip not returning true")
end

-- Test Tear down 

