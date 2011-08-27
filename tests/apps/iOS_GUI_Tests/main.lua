--- Variables ---

local current_focus = 1
local test_list = Group ()
local all_tests = {}
local test_img
local screenshot_name
local screenshot = Image()
local screen_w = screen.width
local screen_h = screen.height



function create_UI() 

	no_screenshot_found_msg_txt = Text
			{
			text = "No screenshot found\n for this test",
			position = {  685, 490 },
			font = "DejaVu 35px",
			color = "FFFFFF"
			}
	
	-- UI: App Title
	local app_title_txt = Text
		{
			text = "Manual Controller Test Suite",
			position = { screen.w/2 - 300, 20 },
			font = "DejaVu Bold 45px",
			color = "FFFFFF"
		}
	test_list:add (app_title_txt)


	-- UI: Box containing Test Description
	local test_desc_box = Rectangle
		{
			size = { 600, 225},
			position = { 525, 120 },
			color = "000000",
			border_color = "FFFFFF",
			border_width = 5
		}
	test_list:add (test_desc_box)

	-- UI: Title for box containing desc
	local test_desc_title_txt = Text
		{
			text = "Test Description",
			position = {  525, 70 },
			font = "DejaVu 40px",
			color = "FFFFFF"
		}
	test_list:add (test_desc_title_txt)


	-- UI: Box containing Test Steps
	local test_steps_box = Rectangle
		{
			size = { 600, 425},
			position = { screen_w - 650, 120 },
			color = "000000",
			border_color = "FFFFFF",
			border_width = 5
		}
	test_list:add (test_steps_box)

	-- UI: Title for box containing steps
	local test_steps_title_txt = Text
		{
			text = "Steps",
			position = {  screen_w - 650, 70 },
			font = "DejaVu 40px",
			color = "FFFFFF"
		}
	test_list:add (test_steps_title_txt)

	-- UI: Box containing Test verify
	local test_verify_box = Rectangle
		{
			size = { 600, 425},
			position = {  screen_w - 650, 620 },
			color = "000000",
			border_color = "FFFFFF",
			border_width = 5
		}
	test_list:add (test_verify_box)


	-- UI: Title for box containing steps
	local test_verify_title_txt = Text
		{
			text = "Verify",
			position = {  screen_w - 650, 570 },
			font = "DejaVu 40px",
			color = "FFFFFF"
		}
	test_list:add (test_verify_title_txt)


	-- UI: Box containing tests
	local test_list_box = Rectangle
		{
			size = { 400, screen.h - 150},
			position = { 70, 120 },
			color = "000000",
			border_color = "FFFFFF",
			border_width = 5
		}
	test_list:add (test_list_box)


	-- UI: Title for box containing tests
	local test_list_box_title_txt = Text
		{
			text = "Tests",
			position = { 70, 70 },
			font = "DejaVu 40px",
			color = "FFFFFF"
		}
	test_list:add (test_list_box_title_txt)

-- UI: Box containing screenshot
	local test_screenshot_box = Rectangle
		{
			size = { 330, 490},
			position = { 670, 465 },
			color = "000000",
			border_color = "FFFFFF",
			border_width = 5
		}
	test_list:add (test_screenshot_box)


	-- UI: Title for box containing screenshot
	local test_screenshot_title_txt = Text
		{
			text = "Screenshot",
			position = { 675, 425 },
			font = "DejaVu 40px",
			color = "FFFFFF"
		}
	test_list:add (test_screenshot_title_txt)

-- UI: text for box containing steps
	test_steps_txt = Text
		{
			text = "To start testing, open Trickplay on an iOS device and connect to for A_Test_TV.",
			position = { screen_w - 620, 130 },
			size = { 500, 420 },
			font = "DejaVu 35px",
			wrap = true, 
			color = "FFFFFF"
		}
	test_list:add (test_steps_txt)

-- UI: text for box containing desc
	test_desc_txt = Text
		{
			text = "",
			position = { 545, 130 },
			size = {500, 425 },
			font = "DejaVu 35px",
			wrap = true, 
			color = "FFFFFF"
		}
	test_list:add (test_desc_txt)


-- UI: text for box containing verify
	test_verify_txt = Text
		{
			text = "",
			position = { screen_w - 620, 630 },
			size = { 560, 420 },
			font = "DejaVu 35px",
			wrap = true,
			color = "FFFFFF"
		}
	test_list:add (test_verify_txt)


end



function focus_manager (line)

	print (screen:find_child("rect"..line))
	local rect1 = screen:find_child("rect"..line)
	rect1.color = { 52, 102, 255, 100 }
	screen:add(rect1)

	if line < #all_tests  then
		local rect2 = screen:find_child("rect"..line + 1)
		rect2.color = { 52, 102, 255, 0 }
	end

	if line > 1 then
		local rect3 = screen:find_child("rect"..line - 1)
		rect3.color = { 52, 102, 255, 0 }
	end
end


function move_focus (direction, current_line)
	if direction == "down" and current_line < #all_tests then
		focus_manager (current_line + 1)
		current_focus = current_focus + 1
	elseif direction == "up" and current_line > 1 then
		focus_manager (current_line - 1)
		current_focus = current_focus -1
	end
end



function load_test_list ()
	local loaded_test_list = {}
	
	local tests_file_string = readfile ("smoke_tests_generic.txt")
	
	return json:parse(tests_file_string)
	
end



function populate_test_fields ()	

	function on_loadedHandler (loadedImage, failed)

		if failed then
			screen:remove(screenshot)
			screen:add (no_screenshot_found_msg_txt)
		else      
			screenshot.position = { 675, 470 }
			screenshot.size = { 320, 480 }
			screen:remove (no_screenshot_found_msg_txt)
			screen:add(screenshot)
		end
	end


	screenshot_name = string.gsub(all_tests[current_focus]["name"], "lua", "PNG")

	screenshot.async = true        
	screenshot.src = "baseline_pics/"..screenshot_name
	screenshot.on_loaded = on_loadedHandler

	if test_steps ~= nil then test_steps_txt.text = test_steps end
	if test_verify ~= nil then test_verify_txt.text = test_verify end
	if test_description ~= nil then test_desc_txt.text = test_description end
end


function populate_test_list ()
	-- UI: Populate box with list of tests.
	for i = 1, #all_tests do
		local rect = Rectangle
		    {
			color = {255, 255, 255, 0},
			position = {70, 40 * i + 90,0},
			size = {380,40},
			name = "rect"..i
		    }
		local text = Text
		    {
			color = {255, 255, 255, 200},
			position = {100, 40 * i + 95, 0},
			size = {400,50},
			text = all_tests[i]["name"],
			font = "DejaVu 35px",
			name = "text"..i
		    }
		test_list:add (rect, text)
	end
end



function controllers:on_controller_connected(controller)
    print("CONNECTED", controller.name)
	test_steps_txt.text = "Connected...\nSelect a test in the Tests Section and hit enter."

    -- Set up disconnection routine
    function controller:on_disconnected()
        print("DISCONNECTED", controller.name)
    end

	function controller:on_advanced_ui_ready()
		class_table = dofile("AdvancedUIClasses.lua")
		controller.factory = loadfile("AdvancedUIAPI.lua")(controller)
	end


	function screen.on_key_down( screen , key )
			print (all_tests[current_focus]["name"])

			if key == keys.Return then
					controller.screen:remove(test_img)
					dofile (all_tests[current_focus]["name"])
					test_img = generate_test_image(controller,controller.factory)
					controller.screen:add(test_img)
			elseif key == keys.Up then
				move_focus ("up", current_focus)
			elseif key == keys.Down then
				move_focus ("down", current_focus)
			end
			populate_test_fields ()
	end


	ctrl = controller

end

-- Run on connected for all controllers already connected
for k,controller in pairs(controllers.connected) do
    if controller.name ~= "Keyboard" then
        controllers:on_controller_connected(controller)
    end
end


--main --
create_UI() 
all_tests = load_test_list()
dumptable (all_tests)
screen:add(test_list)
populate_test_list()
populate_test_fields ()	
focus_manager(current_focus)
print ("current_focus = ", current_focus)
--dofile (all_tests[current_focus]["name"])
screen:show()

