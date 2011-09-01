skin_list = { 
	["default"] = {
		["button"] = "lib/assets/smallbutton.png", 
		["button_focus"] = "lib/assets/button1-focus.png", 
		--["button_focus"] = "assets/smallbuttonfocus.png", 
		["buttonpicker"] = "lib/assets/smallbutton.png",
    	["buttonpicker_focus"] = "lib/assets/button1-focus.png",
		["buttonpicker_left_un"] = "lib/assets/left.png",
		["buttonpciker_left_sel"] = "lib/assets/leftfocus.png",
		["buttonpicker_right_un"] = "lib/assets/right.png",
    	["buttonpicker_right_sel"] = "lib/assets/rightfocus.png",
		["checkbox_sel"] = "lib/assets/checkmark.png", 
		["loading_dot"]  = nil,
    	["scroll_arrow"] = nil,
    	["drop_down_color"]={0,0,0},
	},

	["Custom"] = {},
	["CarbonCandy"] = { 
		["button"] = "lib/assets/button1-blank.png",
		["button_focus"] = "lib/assets/button1-focus.png", 
		["toast"] = "lib/assets/toast.png", 
		["textinput"] = "lib/assets/button3-blank.png", 
		["textinput_focus"] = "lib/assets/button3-blank.png", 
		["dialogbox"] = "", 
		["dialogbox_x"] ="", 
		["buttonpicker"] = "lib/assets/button1-blank.png",
     	["buttonpicker_focus"] =  "lib/assets/button1-focus.png",
		["buttonpicker_left_un"] = "lib/assets/left.png",
		["buttonpciker_left_sel"] = "lib/assets/leftfocus.png",
		["buttonpicker_right_un"] = "lib/assets/right.png",
        ["buttonpicker_right_sel"] = "lib/assets/rightfocus.png",
		["radiobutton"] = "lib/assets/radiobutton-off.png", 
		["radiobutton_focus"] = "lib/assets/radiobutton-off-focus.png", 
		["radiobutton_sel"] = "lib/assets/radiobutton-button.png", 
		["checkbox"] = "lib/assets/checkbox-off.png",
		["checkbox_focus"] = "lib/assets/checkbox-off-focus.png", 
		["checkbox_sel"] = "lib/assets/checkbox-check.png", 
		["loadingdot"] = "lib/assets/spinner.png",
        ["drop_down_color"]={255,0,0},
        ["scroll_arrow"] = nil,
	},
	["OOBE"] =  { 
		["button"] = "lib/assets/button-oobe.png",
		["button_focus"] = "lib/assets/buttonfocus-oobe.png", 
	},
	["tabs"] = {
		["button_focus"] = "lib/assets/tab-active.png", 
		["button"] = "lib/assets/tab-dim.png", 
	}, 
	["inspector"] = {
		["checkbox"] = "lib/assets/btn-check-off.png",
		["checkbox_sel"] = "lib/assets/btn-check-on.png", 
	}
}
	
	-- used for timeline 
attr_map = {
	["Rectangle"] = function() return {"x", "y", "z", "w","h","opacity","color","border_color", "border_width", "x_rotation", "y_rotation", "z_rotation", "anchor_point"} end,
   	["Image"] = function() return {"x", "y", "z", "w","h","opacity","x_rotation", "y_rotation", "z_rotation", "anchor_point"} end,
   	["Text"] = function() return {"x", "y", "z", "w","h","opacity","color","x_rotation", "y_rotation", "z_rotation", "anchor_point"} end,
   	["Group"] = function() return {"x", "y", "z", "w","h","opacity","x_rotation", "y_rotation", "z_rotation", "anchor_point", "scale"} end,
   	["Clone"] = function() return {"x", "y", "z", "w","h","opacity","x_rotation", "y_rotation", "z_rotation", "anchor_point", "scale"} end,
}

current_focus = nil  --- for user code main 

if g == nil then 
	g= Group()
end 

--for i, j in pairs(skin_list) do
	--table.insert(skins, i) 
--end 

--- Cursor Images
--user_mouse_pointer = Image{name = "user_mouse_pointer", src = "/lib/assets/pointer.png", opacity = 255, scale = { screen.width/screen.display_size[1], screen.height/screen.display_size[2]}}

--[[
function screen:on_motion(x,y)
	user_mouse_pointer.position = {x - 10 ,y - 10 ,0}
	if(screen:find_child("user_mouse_pointer") == nil) then 
		screen:add(user_mouse_pointer)
		user_mouse_pointer:raise_to_top()
	end			
end 
]]


