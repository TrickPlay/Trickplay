
-- Test Set up --

-- Tests --
function test_controller_connected ()
	assert_true ( device_app_connected, "controller not connected")
end

function test_controller_is_connected ()
	assert_true ( device_is_connected, "is_controller ~= trued")
end

function test_controller_name ()
	is_string (device_controller_name, "controller.name is not a string")
end

function test_controller_has_keys ()
	assert_true ( device_has_keys, "has_keys = false")
end

function test_controller_has_accelerometer ()
	assert_true ( device_has_accelerometer, "has_accelerometer ~= true")
end

function test_controller_has_touches ()
	assert_true ( device_has_touches, "has_touches ~= true")
end

function test_controller_has_multiple_choice ()
	assert_true ( device_has_multiple_choice, "has_multiple_choice ~= true")
end

function test_controller_has_sound ()
	assert_true ( device_has_sound, "has_sound ~= true")
end

function test_controller_has_ui ()
	assert_true ( device_has_ui, "has_ui ~= true")
end

function test_controller_has_text_entry ()
	assert_true ( device_has_text_entry, "has_text_entry ~= true")
end

function test_controller_has_images ()
	assert_true ( device_has_images, "has_images ~= true")
end


function test_controller_has_audio_clips ()
	assert_true ( device_has_audio_clips, "has_audio_clips ~= true\n ** Ignore. Not currently implemented. **\n")
end


function test_controller_has_advanced_ui ()
	assert_true ( device_has_advanced_ui, "has_advanced_ui ~= true")
end
-- Test Tear down --









