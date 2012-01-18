-- Load the UI Element library
ui_element = dofile("/lib/ui_element.lua")

-- Create a ButtonPicker, defining its scrollable list and other settings
local bpNumbers = ui_element.buttonPicker{
		items = { "un", "deux", "trois", "quatre", "cinq", "six", "sept", "huit", "neuf", "dix" }
		}
bpNumbers.position = { 300, 350, 0 }

-- Create a Button, when pressed, it will jump to the 5th item in the list ("cinq")
local bJumpToCinq = ui_element.button{ ui_width = 300,
                                       label = "Jump to Cinq",
                                     }
bJumpToCinq.position = { 240, 550, 0 }

-- Add the ButtonPicker and Button to the screen and display them
screen:add( bpNumbers, bJumpToCinq )
screen:show()

-- bJumpToCinq button-pressed event handler
bJumpToCinq.pressed = function()
	-- Jump to "cinq", the 5th item in the list
	-- Note: At this point, the current selected_item may be anywhere in the list.
	
	-- Find the shortest scrolling path (backward or forward) to the 5th item
	local curr = bpNumbers.selected_item
	local num_items = #bpNumbers.items
	local desired = 5
	local num_scrolls_back, num_scrolls_forward
	
	-- Validate value of desired and verify we're not already at the desired item
	if desired < 1 or desired > num_items or desired == curr then return end
	
	-- Is current item past the desired item?
	if curr > desired then
		-- Yes, determine the number of scrolls in each direction to get to desired item
		num_scrolls_back = curr - desired
		num_scrolls_forward = num_items - curr + desired
	else
		-- No, current item is before desired, determine number of scrolls needed
		num_scrolls_back = curr + num_items - desired
		num_scrolls_forward = desired - curr
	end
	
	-- Which direction is shorter?
	if num_scrolls_back < num_scrolls_forward then
		-- Scroll back
		for i = 1, num_scrolls_back, 1 do
			-- Note: These scroll operations occur asynchronously with immediate
			-- termination of any existing unfinished operation. Because of this,
			-- all the scrolling ops, except the last one, may be aborted and not
			-- be viewable onscreen.
			layout["numbers"].bpNumbers:press_left()
		end
	else
		-- Scroll forward
		for i = 1, num_scrolls_forward, 1 do
			layout["numbers"].bpNumbers:press_right()
		end
	end
end

