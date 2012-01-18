
-- Test Set up --

-- Tests --


function test_advanced_ui_parent ()
	assert_equal (r1.parent.name, "G1",  "ui_element.group.parent not returning the correct value")
end


function test_advanced_ui_children () 
	assert_equal ( G2.children[1].name, "rect2",  "ui_element.group.children not returning the correct value")

end



-- Test Tear down 

