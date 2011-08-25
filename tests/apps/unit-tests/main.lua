-- GLOBAL SECTION
ui_element = dofile("/lib/ui_element.lua") --Load widget helper library
layout = {} --Table containing all the UIElements that make up each screen
groups = {} --Table of groups of the UIElements of each screen, each of which can then be ui_element.screen_add()ed
-- END GLOBAL SECTION

--  UI3 SECTION
groups["ui3"] = Group() -- Create a Group for this screen
layout["ui3"] = {}
loadfile("/screens/ui3.lua")(groups["ui3"]) -- Load all the elements for this screen
ui_element.populate_to(groups["ui3"],layout["ui3"]) -- Populate the elements into the Group

-- UI3.BUTTON0 SECTION
layout["ui3"].button0.pressed = function() -- Handler for button0.pressed in this screen
	dofile("packages/controller_unit_tests/controller_main.lua")
end
layout["ui3"].button0.released = function() -- Handler for button0.released in this screen
end
-- END UI3.BUTTON0 SECTION

-- UI3.BUTTON1 SECTION
layout["ui3"].button1.pressed = function() -- Handler for button1.pressed in this screen
	ui_element.transit_to(groups["ui3"], groups["ui1"])
	layout["ui1"].button0.on_focus_in()
end
layout["ui3"].button1.released = function() -- Handler for button1.released in this screen
end
-- END UI3.BUTTON1 SECTION

-- UI3.BUTTON11 SECTION
layout["ui3"].button11.pressed = function() -- Handler for button11.pressed in this screen
	layout["ui3"].steps_txt.text = ""
	layout["ui3"].pass_results_txt.text = ""
	layout["ui3"].fail_results_txt.text = ""


end
layout["ui3"].button11.released = function() -- Handler for button11.released in this screen
end
-- END UI3.BUTTON11 SECTION

-- END UI3 SECTION

--  UI2 SECTION
groups["ui2"] = Group() -- Create a Group for this screen
layout["ui2"] = {}
loadfile("/screens/ui2.lua")(groups["ui2"]) -- Load all the elements for this screen
ui_element.populate_to(groups["ui2"],layout["ui2"]) -- Populate the elements into the Group

-- UI2.BUTTON0 SECTION

layout["ui2"].button0.pressed = function() -- Handler for button0.pressed in this screen
	dofile("packages/acceptance_unit_tests/acceptance_main.lua")
end
layout["ui2"].button0.released = function() -- Handler for button0.released in this screen
end
-- END UI2.BUTTON0 SECTION

-- UI2.BUTTON1 SECTION

layout["ui2"].button1.pressed = function() -- Handler for button1.pressed in this screen
	ui_element.transit_to(groups["ui2"], groups["ui1"])
	layout["ui1"].button0.on_focus_in()
end
layout["ui2"].button1.released = function() -- Handler for button1.released in this screen
end
-- END UI2.BUTTON1 SECTION

-- UI2.BUTTON11 SECTION
layout["ui2"].button11.pressed = function() -- Handler for button11.pressed in this screen
	steps_txt.text = ""
	results_txt.text = ""
end
layout["ui2"].button11.released = function() -- Handler for button11.released in this screen
end
-- END UI2.BUTTON11 SECTION

-- END UI2 SECTION

--  UI1 SECTION
groups["ui1"] = Group() -- Create a Group for this screen
layout["ui1"] = {}
loadfile("/screens/ui1.lua")(groups["ui1"]) -- Load all the elements for this screen
ui_element.populate_to(groups["ui1"],layout["ui1"]) -- Populate the elements into the Group

-- UI1.BUTTON0 SECTION

layout["ui1"].button0.pressed = function() -- Handler for button0.pressed in this screen
	ui_element.transit_to(groups["ui1"], groups["ui2"])
	layout["ui2"].button0.on_focus_in()
end
layout["ui1"].button0.released = function() -- Handler for button0.released in this screen
end
-- END UI1.BUTTON0 SECTION

-- UI1.BUTTON1 SECTION

layout["ui1"].button1.pressed = function() -- Handler for button1.pressed in this screen
	ui_element.transit_to(groups["ui1"], groups["ui3"])
	layout["ui3"].button0.on_focus_in()
	layout["ui3"].steps_txt.text = "Press Run Controller Tests button before connecting to device."
end
layout["ui1"].button1.released = function() -- Handler for button1.released in this screen
end
-- END UI1.BUTTON1 SECTION

-- END UI1 SECTION

-- GLOBAL SECTION FOOTER 
screen:grab_key_focus()
screen:show()
screen.reactive = true

ui_element.screen_add(groups["ui1"])
layout["ui1"].button0.on_focus_in()

-- SCREEN ON_KEY_DOWN SECTION
function screen:on_key_down(key)
	screen:find_child("button0"):on_key_down(key)
end
-- END SCREEN ON_KEY_DOWN SECTION

-- SCREEN ON_MONTION SECTION
function screen:on_motion(x,y)
	if dragging then
		local actor = unpack(dragging)
		if (actor.name == "grip") then
			local actor,s_on_motion = unpack(dragging)
			s_on_motion(x, y)
			return true
		end
		return true
	end
end
-- END SCREEN ON_MONTION SECTION

-- SCREEN ON_BUTTON_UP SECTION
function screen:on_button_up()
	if dragging then
		dragging = nil
	end
end
-- END SCREEN ON_BUTTON_UP SECTION

-- END GLOBAL SECTION FOOTER 
