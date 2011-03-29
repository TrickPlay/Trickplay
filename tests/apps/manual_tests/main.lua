--[[
Filename: main.lua
Author: Peter von dem Hagen
Date: February 2, 2011
Description: This file is the driver for the manual UI tests. It requires:
			1) A file called manual_tests that contains a table with subtables:
				a) name - The name of the test file to be loaded.
				b) active - Boolean on whether to run this test or not.
			2) Files for each test.
				a) Render code: Should be named number_API_description.lua
				b) png of code: Contains a screenshot of the code in 'a'.

--]]
--External file that contains list of tests
test_folder = "smoke_tests_ubuntu"
test_file = "smoke_tests_ubuntu.txt" 

-- start test ordinal number
local start_no = 1 

-- Global variables
local test_list
local current_test = start_no
local focus_items = { Pass = 1, Fail = 2, Prev = 3, Next = 4 }
local current_focus
local end_of_tests
local test_results = {}
local test_completed_focus_items = { Yes = 1, No = 2 }
local current_focus_view = "action_keys"
local results = Group ()
local code_image = Group ()

----
---- Create Initial UI 
----
function load_initial_ui ()

	local c = Canvas (screen.w, screen.h)
	c.name = "canvas"

  -- Draw the panels
    c:move_to (0, screen.h - 110 )
    c:line_to (screen.w, screen.h - 110)
    c:move_to (screen.w/2, 100 )
    c:line_to (screen.w/2, screen.h - 110)
    c:move_to (0, 100 )
    c:line_to (screen.w, 103)
    c:move_to (0, 100 )
    c:line_to (screen.w, 103)
    c:set_line_width (3)
    c:set_source_color( "88FFFF" )
    c:stroke (true)
    c:fill (true)


  -- Draw a separator line
  	c:move_to (screen.w/2, 200)
  	c:line_to (screen.w/2, screen.h)
  	c:set_line_width (2)
    c:set_source_color( "000000" )
    c:stroke (true)
	screen:add (c:Image())

	-- add Framework Title
	local title_txt = Text (
			{
				font="san 50px",
				color = "FFFFFF", 
				position = {20,30},
				text = "Manual Testing Suite"
			}
	)
	screen:add (title_txt)
	
	local code_txt = Text (
			{
				font="san 30px",
				color = "FFFFFF", 
				position = {350,140},
				text = "Code Generated"
			}
	)
	screen:add (code_txt)
	
	local baseline_txt = Text (
			{
				font="san 30px",
				color = "FFFFFF", 
				position = {screen.w/2 + 350,140},
				text = "Baseline Image"
			}
	)
	screen:add (baseline_txt)
	
	next_txt = Text (
		{
			font="san 30px",
			color = "FFFFFF", 
			position = {screen.w - 150, screen.h - 75},
			text = "NEXT"
		}
	)
	screen:add (next_txt)
	
	prev_txt = Text (
		{
			font="san 30px",
			color = "FFFFFF", 
			position = {screen.w - 360, screen.h - 75},
			text = "PREVIOUS"
		}
	)
	screen:add (prev_txt)
	
	pass_txt = Text (
		{
			font="san 30px",
			color = "FFFFFF", 
			position = {screen.w - 600, screen.h - 75},
			text = "PASS"
		}
	)
	screen:add (pass_txt)
	
	fail_txt = Text (
		{
			font="san 30px",
			color = "FFFFFF", 
			position = {screen.w - 470, screen.h - 75},
			text = "FAIL"
		}
	)
	screen:add (fail_txt)

	-- set default focus to Next
	current_focus = focus_items["Pass"]
	pass_txt.color = "00FF33" 
end	

---
--- Draw a separator line between the images of the two tests
---
function draw_separator_line ()
	local sep_line = Canvas (screen.w, screen.h)
	sep_line.name = "sep_line"
	
  -- Draw a separator line
  	sep_line:move_to (screen.w/2, 200)
  	sep_line:line_to (screen.w/2, screen.h)
  	sep_line:set_line_width (2)
    sep_line:set_source_color( "000000" )
    sep_line:stroke (true)
	screen:add (sep_line:Image())
end

---
--- Initialize the test_results table so that each items is "Not Tested"
---
function create_test_results_table ()
 	for i=1, #test_list do
 		test_results[i] = "Not Tested"
 	end
end

---
---  Display a view that prompts to see the test results
---
function tests_completed_view ()

	current_focus_view = "test_completed_prompt"
	
	test_completed_txt =Text 
			{      
				font = "sans 30px",
				text = " Test pass complete. Show results?",
				color = "EB7500",
				position = {screen.w - 800, screen.h - 150},
				size = { 600, 150 }
			}
	screen:add(test_completed_txt)
			
	yes_txt = Text 
			{      
				font = "sans 30px",
				text = " Yes",
				color = "00FF33",
				position = {screen.w - 200, screen.h - 150},
				size = { 100, 100 }
			}
	screen:add(yes_txt)
			
	no_txt = Text 
			{      
				font = "sans 30px",
				text = " No",
				color = "FFFFFF",
				position = {screen.w - 100, screen.h - 150},
				size = { 100, 100 }
			}
	screen:add(no_txt)
	
	current_focus = test_completed_focus_items["Yes"]
end

---
--- Create a view that shows a dialog box with test results and also dumps results onto console.
---
function test_results_view ()

	results = Group
	{
		name = "results",
		children =
		{
			Rectangle
			{
				size = { 1800, 900 },
				position = { 100, 100 },
				color = "B0B0B0",
				opacity = 240
			},
			Text
			{
				text = "Test Results",
				font = "sans 50px",
				color = "000000",
				position = { 800, 100},
				opacity = 240
			},
			Text
			{
				text = "Press Enter to clear this window...",
				font = "sans 25px",
				color = "00991F",
				position = { 1450, 950},
				opacity = 240
			}
		}
	}
	screen:add (results)


	local H = 44
	local top = 140
	local left = 140
	local pass_count = 0
	local fail_count = 0
	local test_result_count = 0
	local not_tested_count = 0
	local print_formatted_results = ""
	
	for i,v in ipairs (test_results) do
		if v == "Pass" then 
			pass_count = pass_count + 1
		elseif v == "Fail" then 
			fail_count = fail_count + 1
		elseif v == "Not Tested" then 
			not_tested_count = not_tested_count + 1
		end
			
		local test_name = string.gsub(test_list[i], ".lua", "")
		print_formatted_results = print_formatted_results.."\n"..test_name..": "..v
		local text1 = Text
        {
            font =  "sans "..tostring( H - 20 ).."px",
            color = "000000",
            text = test_name..": "..v,
            x = left,
            y = top
        }
        
        results:add(text1)
        
       -- screen:add( text1 )
		
		top = top + H
        if top + H > 500 then
            top = 140
            left = left + 400
        end
	end


	
	print( "" )
        print( string.format( "PASSED       %4d (%d%%)" , pass_count , ( pass_count / #test_list ) * 100 ) )
        print( string.format( "FAILED       %4d (%d%%)" , fail_count , ( fail_count / #test_list ) * 100 ) )
        print( string.format( "NOT TESTED   %4d (%d%%)" , not_tested_count , ( not_tested_count / #test_list ) * 100 ) )
        print( string.format( "TOTAL    	   %4d" , #test_list ) )
        print( "" )
        print ("\nList of Tests with Results\n"..print_formatted_results)
end

---
--- Load a list of tests from the file and return a table
---
function load_test_list ()
	local loaded_test_list = {}
	
	local tests_file_string = readfile ("packages/"..test_folder.."/"..test_file)
	
	local all_tests = json:parse(tests_file_string)
	
	for i,v in ipairs(all_tests) do
		table.insert( loaded_test_list , all_tests[i]["name"] )
	end
	return loaded_test_list
end

---
--- Function that accepts the test_list and the current test number. It then populates
--- the screen based on the test number.
---
function load_test ( test_list, test_no )

	local filename, count = string.gsub(test_list[test_no], "lua", "png")
	local test_name = string.gsub(test_list[test_no], ".lua", "")

	-- load the code from the current test file
	dofile("packages/"..test_folder.."/"..test_list[test_no])
	
	-- check if the test has been created and clear for next test info.
	local old_test_ui = screen:find_child("test_ui")
	if old_test_ui ~= nil then old_test_ui:unparent() end
	
	local old_code_image = screen:find_child("code_image")
	if old_code_image ~= nil then old_code_image:unparent() end

	local generated_image = generate_test_image()
	
	-- display the code_image
	code_image = Group 
		{      
		name = "code_image",
    		size = { screen.w , screen.h },
    		position = { 0 , 200 },
   		scale = { 0.5, 0.5 },
    		children = 
    		{
         		Rectangle 
         		{
        			color = "FFFFFF",
        			size = { 1920, 1080 },
        			position = { 0, 0 }
        		},
        		generated_image  --function in the external file that contains the test code to be rendered.
        	}
    	}
    screen:add(code_image)	
    
	
	-- load the baseline png as well as other dynamic data (test name, test number, etc)
	test_ui = Group
	{	
		name = "test_ui",
		children = 
		{
			Image
			{
				name = "base_image",
				src = "packages/"..test_folder.."/".."test_pngs/"..filename,
				position = { screen.w/2, 200 }
			},
        		Text {
					font="san 30px",
					color = "F5B800", 
					position = {screen.w - 175, 50},
					text = current_test
			},
			Text {
					font="san 30px",
					color = "FFFFFF", 
					position = {screen.w - 150, 50},
					text = " of "
			},
			Text {
					font="san 30px",
					color = "F5B800", 
					position = {screen.w - 70, 50},
					text = #test_list
			},
			Text {
					font="san 30px",
					color = "F5B800", 
					position = {10,screen.h - 80},
					text = test_question
			},
			Text {
					font="san 30px",
					color = "F5B800", 
					position = {screen.w/2 - 175, 40},
					text = test_name
			},
			Text {
					font="san 30px",
					color = "FFFFFF", 
					position = {10, screen.h - 150},
					text = "Test Status: "
			},
			Text {
					font="san 30px",
					color = "FFFFFF", 
					position = {200, screen.h - 150},
					text = test_results[test_no]
			}
		}
	}
	
	screen:add (test_ui)
	
	draw_separator_line ()	
end

---
---  Function that accepts a test result and stores it in a table. 
---  If it's the last item in the list then call only_prev_enabled()
---
function add_to_test_results (result)
	if test_results[current_test] ~= nil then
   			table.remove (test_results, current_test)
   		end
    	table.insert (test_results, current_test, result)
    	if current_test < #test_list then
    		current_test = current_test + 1
    		load_test (test_list, current_test)
    	else
    		only_prev_enabled()
    	end
end

---
---	Disable all action keys except Previous.
---
function only_prev_enabled ()
	current_focus =  focus_items["Prev"]
    next_txt.color = "707070"
    prev_txt.color = "00FF33"
    pass_txt.color = "707070"
    fail_txt.color = "707070"
    end_of_tests = true
    tests_completed_view()  -- prompt if the user wants to see the test results
end

---
---	Animates the code_image over the baseline image for easy comparison.
---
function overlap_images()
	code_image:raise_to_top()
	code_image:animate{ duration = 1000, position = { screen.w/2, 200} , opacity = 60}
end

---
--- Moves code_image back to original location
---
function move_code_image_back()
	code_image:animate{ duration = 1000, position = { 0, 200} , opacity = 255}
end

---
--- Focus Manager
---
function screen.on_key_down( screen , key )
	if current_focus_view == "test_results" then  -- Set focus to test_results
		if key == keys.Return then
	        current_focus_view = "action_keys"
	        screen:remove (results)
	    end
	    											-- end focus test_results
	elseif current_focus_view == "test_completed_prompt" then -- Set focus to test completed prompt
		if key == keys.Right and current_focus == test_completed_focus_items["Yes"]  then
	        current_focus =  test_completed_focus_items["No"]
	        no_txt.color = "00FF33"
	        yes_txt.color = "FFFFFF"
	    elseif key == keys.Left and current_focus == test_completed_focus_items["No"] then
	        current_focus = test_completed_focus_items["Yes"]
	        yes_txt.color = "00FF33"
	        no_txt.color = "FFFFFF"
	    elseif key == keys.Return then
	        if current_focus == test_completed_focus_items["Yes"] then
	        	current_focus_view = "test_results"
	        	test_results_view ()
	      	else
	      		current_focus_view = "action_keys"
	      	end
     	    screen:remove (no_txt)
      		screen:remove (yes_txt)
      		screen:remove (test_completed_txt)
      		current_focus = focus_items["Prev"]
	     end	
	     													-- End focus test completed Prompt
	elseif current_focus_view == "action_keys" then  -- set focus to action keys
		if key == keys.Left and current_focus == focus_items["Next"]  then
	        current_focus =  focus_items["Prev"]
	        prev_txt.color = "00FF33"
	        next_txt.color = "FFFFFF"
	    elseif key == keys.Left and current_focus == focus_items["Prev"] and not end_of_tests then
	        current_focus = focus_items["Fail"]
	        fail_txt.color = "00FF33"
	        prev_txt.color = "FFFFFF"
	        pass_txt.color = "FFFFFF"
	        next_txt.color = "FFFFFF"
	    elseif key == keys.Left and current_focus == focus_items["Fail"] then
	        current_focus = focus_items["Pass"]
	        pass_txt.color = "00FF33"
	        fail_txt.color = "FFFFFF"
	    elseif key == keys.Right and current_focus == focus_items["Pass"] then
	        current_focus = focus_items["Fail"]
	        fail_txt.color = "00FF33"
	        pass_txt.color = "FFFFFF"
	    elseif key == keys.Right and current_focus == focus_items["Fail"] then
	        current_focus = focus_items["Prev"]
	        prev_txt.color = "00FF33"
	        fail_txt.color = "FFFFFF"
	    elseif key == keys.Right and current_focus == focus_items["Prev"] and not end_of_tests then
	        current_focus = focus_items["Next"]
	        next_txt.color = "00FF33"
	        prev_txt.color = "FFFFFF"
	        pass_txt.color = "FFFFFF"
	        fail_txt.color = "FFFFFF"
	    elseif key == keys.Up then
	    	overlap_images()
	   	elseif key == keys.Down then
			move_code_image_back()
		elseif key == keys.GREEN then
			add_to_test_results ("Pass")
		elseif key == keys.RED then
			add_to_test_results ("Fail")
	    elseif key == keys.Return then	
	        if current_focus == focus_items["Prev"] and current_test >= 2 then
	        	current_test = current_test - 1
	        	load_test (test_list, current_test)
	        	next_txt.color = "FFFFFF"
	        	pass_txt.color = "FFFFFF"
	        	fail_txt.color = "FFFFFF"
	        	end_of_tests = false
	        elseif current_focus == focus_items["Prev"] and current_test < 2 then
	        	load_test (test_list, current_test)
	        	current_test = current_test - 1
	        	current_focus = focus_items["Next"]
	        	next_txt.color = "00FF33"
	        	prev_txt.color = "707070"
	        	pass_txt.color = "FFFFFF"
	        	fail_txt.color = "FFFFFF"
	        elseif current_focus == focus_items["Next"] and current_test < #test_list then
	        	current_test = current_test + 1
	        	load_test (test_list, current_test)
	        	next_txt.color = "00FF33"
	        	prev_txt.color = "FFFFFF"
	        	pass_txt.color = "FFFFFF"
	        	fail_txt.color = "FFFFFF"
	        	if current_test == #test_list then
	        		only_prev_enabled()
	        	end
	       	elseif current_focus == focus_items["Pass"] and current_test <= #test_list then
	       		add_to_test_results ("Pass")
	       	elseif current_focus == focus_items["Fail"] and current_test <= #test_list then
	        	add_to_test_results ("Fail")
	        end
	    end  
	    										-- End focus action keys
	end
end
   
---
--- main 
---

test_list = load_test_list ()
load_initial_ui()
create_test_results_table ()
load_test (test_list, current_test) 
screen:show()


