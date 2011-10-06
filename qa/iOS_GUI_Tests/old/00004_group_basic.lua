test_description = "Populate the screen with groups of objects"
test_steps = "View the device"
test_verify = " Verify that "
test_group = "smoke"
test_area = "group"
test_api = "basic"


function generate_test_image ()

	local r = factory:Rectangle{color = "FF00FFFF", x = 100, y = 100, size = { 40 , 80 }}

	return r
end

