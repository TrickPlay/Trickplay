local g = ... 

local scrollPane12


local fail_results_txt = Text
	{
		color = {255,61,61,255},
		font = "DejaVu Sans 30px",
		text = "",
		editable = false,
		wants_enter = true,
		wrap = true,
		wrap_mode = "CHAR",
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "fail_results_txt",
		position = {890,10,0},
		size = {870,500},
		opacity = 255,
		reactive = true,
		cursor_visible = false,
	}

fail_results_txt.extra.focus = {}

function fail_results_txt:on_key_down(key)
	if fail_results_txt.focus[key] then
		if type(fail_results_txt.focus[key]) == "function" then
			fail_results_txt.focus[key]()
		elseif screen:find_child(fail_results_txt.focus[key]) then
			if fail_results_txt.on_focus_out then
				fail_results_txt.on_focus_out(key)
			end
			screen:find_child(fail_results_txt.focus[key]):grab_key_focus()
			if screen:find_child(fail_results_txt.focus[key]).on_focus_in then
				screen:find_child(fail_results_txt.focus[key]).on_focus_in(key)
				scrollPane12.seek_to_middle(screen:find_child(fail_results_txt.focus[key]).x, screen:find_child(fail_results_txt.focus[key]).y)
			end
		end
	end
	return true
end

fail_results_txt.extra.reactive = true


local pass_results_txt = Text
	{
		color = {102,204,0,255},
		font = "DejaVu Sans 30px",
		text = "",
		editable = false,
		wants_enter = true,
		wrap = true,
		wrap_mode = "CHAR",
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "pass_results_txt",
		position = {8,10,0},
		size = {870,500},
		opacity = 255,
		reactive = true,
		cursor_visible = false,
	}

pass_results_txt.extra.focus = {[keys.Up] = "button0", }

function pass_results_txt:on_key_down(key)
	if pass_results_txt.focus[key] then
		if type(pass_results_txt.focus[key]) == "function" then
			pass_results_txt.focus[key]()
		elseif screen:find_child(pass_results_txt.focus[key]) then
			if pass_results_txt.on_focus_out then
				pass_results_txt.on_focus_out(key)
			end
			screen:find_child(pass_results_txt.focus[key]):grab_key_focus()
			if screen:find_child(pass_results_txt.focus[key]).on_focus_in then
				screen:find_child(pass_results_txt.focus[key]).on_focus_in(key)
				scrollPane12.seek_to_middle(screen:find_child(pass_results_txt.focus[key]).x, screen:find_child(pass_results_txt.focus[key]).y)
			end
		end
	end
	return true
end

pass_results_txt.extra.reactive = true


local rectangle28 = Rectangle
	{
		color = {0,0,0,255},
		border_color = {255,255,255,0},
		border_width = 2,
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "rectangle28",
		position = {2,6,0},
		size = {1800,650},
		opacity = 255,
		reactive = true,
	}

rectangle28.extra.focus = {}

function rectangle28:on_key_down(key)
	if rectangle28.focus[key] then
		if type(rectangle28.focus[key]) == "function" then
			rectangle28.focus[key]()
		elseif screen:find_child(rectangle28.focus[key]) then
			if rectangle28.on_focus_out then
				rectangle28.on_focus_out(key)
			end
			screen:find_child(rectangle28.focus[key]):grab_key_focus()
			if screen:find_child(rectangle28.focus[key]).on_focus_in then
				screen:find_child(rectangle28.focus[key]).on_focus_in(key)
				scrollPane12.seek_to_middle(screen:find_child(rectangle28.focus[key]).x, screen:find_child(rectangle28.focus[key]).y)
			end
		end
	end
	return true
end

rectangle28.extra.reactive = true


scrollPane12 = ui_element.scrollPane
	{
		skin = "Custom",
		reactive = true,
		visible_w = 1800,
		visible_h = 600,
		virtual_w = 1800,
		virtual_h = 1000,
		bar_color_inner = {180,180,180,255},
		bar_color_outer = {30,30,30,255},
		bar_focus_color_inner = {180,255,180,255},
		bar_focus_color_outer = {30,30,30,255},
		empty_color_inner = {120,120,120,255},
		empty_color_outer = {255,255,255,255},
		frame_thickness = 2,
		frame_color = {60,60,60,255},
		bar_thickness = 15,
		bar_offset = 5,
		vert_bar_visible = true,
		horz_bar_visible = true,
		box_color = {160,160,160,0},
		box_focus_color = {160,255,160,0},
		box_width = 0,
		content= Group { children = {rectangle28,pass_results_txt,fail_results_txt,} },
		arrows_visible = false,
		arrow_color = {255,255,255,255},
	}

scrollPane12.name = "scrollPane12"
scrollPane12.position = {76,456,0}
scrollPane12.scale = {1,1,0,0}
scrollPane12.anchor_point = {0,0}
scrollPane12.x_rotation = {0,0,0}
scrollPane12.y_rotation = {0,0,0}
scrollPane12.z_rotation = {0,0,0}
scrollPane12.opacity = 255
scrollPane12.extra.reactive = true


local rect5 = Rectangle
	{
		color = {255,230,204,255},
		border_color = {215,177,255,255},
		border_width = 0,
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "rect5",
		position = {188,70,0},
		size = {1500,110},
		opacity = 255,
		reactive = true,
	}

rect5.extra.focus = {}

function rect5:on_key_down(key)
	if rect5.focus[key] then
		if type(rect5.focus[key]) == "function" then
			rect5.focus[key]()
		elseif screen:find_child(rect5.focus[key]) then
			if rect5.on_focus_out then
				rect5.on_focus_out(key)
			end
			screen:find_child(rect5.focus[key]):grab_key_focus()
			if screen:find_child(rect5.focus[key]).on_focus_in then
				screen:find_child(rect5.focus[key]).on_focus_in(key)
			end
		end
	end
	return true
end

rect5.extra.reactive = true


local button0 = ui_element.button
	{
		ui_width = 400,
		ui_height = 60,
		skin = "default",
		label = "Run Controller Tests",
		focus_color = {27,145,27,255},
		text_color = {255,255,255,255},
		text_font = "DejaVu Sans 30px",
		border_width = 1,
		border_corner_radius = 12,
		reactive = true,
		border_color = {255,255,255,255},
		fill_color = {255,255,255,0},
		focus_fill_color = {27,145,27,0},
		focus_text_color = {255,255,255,255},
	}

button0.name = "button0"
button0.position = {230,96,0}
button0.scale = {1,1,0,0}
button0.anchor_point = {0,0}
button0.x_rotation = {0,0,0}
button0.y_rotation = {0,0,0}
button0.z_rotation = {0,0,0}
button0.opacity = 255
button0.extra.focus = {[keys.Right] = "button11", [keys.Return] = "button0", [keys.Down] = "pass_results_txt", }

function button0:on_key_down(key)
	if button0.focus[key] then
		if type(button0.focus[key]) == "function" then
			button0.focus[key]()
		elseif screen:find_child(button0.focus[key]) then
			if button0.on_focus_out then
				button0.on_focus_out(key)
			end
			screen:find_child(button0.focus[key]):grab_key_focus()
			if screen:find_child(button0.focus[key]).on_focus_in then
				screen:find_child(button0.focus[key]).on_focus_in(key)
			end
		end
	end
	return true
end

button0.extra.reactive = true


local button1 = ui_element.button
	{
		ui_width = 400,
		ui_height = 60,
		skin = "default",
		label = "Return to Main Menu",
		focus_color = {27,145,27,255},
		text_color = {255,255,255,255},
		text_font = "DejaVu Sans 30px",
		border_width = 1,
		border_corner_radius = 12,
		reactive = true,
		border_color = {255,255,255,255},
		fill_color = {255,255,255,0},
		focus_fill_color = {27,145,27,0},
		focus_text_color = {255,255,255,255},
	}

button1.name = "button1"
button1.position = {1246,96,0}
button1.scale = {1,1,0,0}
button1.anchor_point = {0,0}
button1.x_rotation = {0,0,0}
button1.y_rotation = {0,0,0}
button1.z_rotation = {0,0,0}
button1.opacity = 255
button1.extra.focus = {[keys.Return] = "button1", [keys.Left] = "button11", }

function button1:on_key_down(key)
	if button1.focus[key] then
		if type(button1.focus[key]) == "function" then
			button1.focus[key]()
		elseif screen:find_child(button1.focus[key]) then
			if button1.on_focus_out then
				button1.on_focus_out(key)
			end
			screen:find_child(button1.focus[key]):grab_key_focus()
			if screen:find_child(button1.focus[key]).on_focus_in then
				screen:find_child(button1.focus[key]).on_focus_in(key)
			end
		end
	end
	return true
end

button1.extra.reactive = true


local text2 = Text
	{
		color = {255,255,255,255},
		font = "DejaVu Sans 40px",
		text = "Steps:",
		editable = true,
		wants_enter = true,
		wrap = true,
		wrap_mode = "CHAR",
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "text2",
		position = {74,185,0},
		size = {200,50},
		opacity = 255,
		reactive = true,
		cursor_visible = false,
	}

text2.extra.focus = {}

function text2:on_key_down(key)
	if text2.focus[key] then
		if type(text2.focus[key]) == "function" then
			text2.focus[key]()
		elseif screen:find_child(text2.focus[key]) then
			if text2.on_focus_out then
				text2.on_focus_out(key)
			end
			screen:find_child(text2.focus[key]):grab_key_focus()
			if screen:find_child(text2.focus[key]).on_focus_in then
				screen:find_child(text2.focus[key]).on_focus_in(key)
			end
		end
	end
	return true
end

text2.extra.reactive = true


local rect16 = Rectangle
	{
		color = {0,0,0,255},
		border_color = {255,255,255,255},
		border_width = 2,
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "rect16",
		position = {76,236,0},
		size = {1800,160},
		opacity = 255,
		reactive = true,
	}

rect16.extra.focus = {}

function rect16:on_key_down(key)
	if rect16.focus[key] then
		if type(rect16.focus[key]) == "function" then
			rect16.focus[key]()
		elseif screen:find_child(rect16.focus[key]) then
			if rect16.on_focus_out then
				rect16.on_focus_out(key)
			end
			screen:find_child(rect16.focus[key]):grab_key_focus()
			if screen:find_child(rect16.focus[key]).on_focus_in then
				screen:find_child(rect16.focus[key]).on_focus_in(key)
			end
		end
	end
	return true
end

rect16.extra.reactive = true


local text30 = Text
	{
		color = {255,255,255,255},
		font = "DejaVu Sans 40px",
		text = "Results:",
		editable = true,
		wants_enter = true,
		wrap = false,
		wrap_mode = "CHAR",
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "text30",
		position = {74,405,0},
		size = {200,50},
		opacity = 255,
		reactive = true,
		cursor_visible = false,
	}

text30.extra.focus = {}

function text30:on_key_down(key)
	if text30.focus[key] then
		if type(text30.focus[key]) == "function" then
			text30.focus[key]()
		elseif screen:find_child(text30.focus[key]) then
			if text30.on_focus_out then
				text30.on_focus_out(key)
			end
			screen:find_child(text30.focus[key]):grab_key_focus()
			if screen:find_child(text30.focus[key]).on_focus_in then
				screen:find_child(text30.focus[key]).on_focus_in(key)
			end
		end
	end
	return true
end

text30.extra.reactive = true


local steps_txt = Text
	{
		color = {255,255,255,255},
		font = "DejaVu Sans 30px",
		text = "",
		editable = true,
		wants_enter = true,
		wrap = true,
		wrap_mode = "CHAR",
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "steps_txt",
		position = {92,246,0},
		size = {1760,140},
		opacity = 255,
		reactive = true,
		cursor_visible = false,
	}

steps_txt.extra.focus = {}

function steps_txt:on_key_down(key)
	if steps_txt.focus[key] then
		if type(steps_txt.focus[key]) == "function" then
			steps_txt.focus[key]()
		elseif screen:find_child(steps_txt.focus[key]) then
			if steps_txt.on_focus_out then
				steps_txt.on_focus_out(key)
			end
			screen:find_child(steps_txt.focus[key]):grab_key_focus()
			if screen:find_child(steps_txt.focus[key]).on_focus_in then
				screen:find_child(steps_txt.focus[key]).on_focus_in(key)
			end
		end
	end
	return true
end

steps_txt.extra.reactive = true


local button11 = ui_element.button
	{
		ui_width = 400,
		ui_height = 60,
		skin = "default",
		label = "Clear results",
		focus_color = {27,145,27,255},
		text_color = {255,255,255,255},
		text_font = "DejaVu Sans 30px",
		border_width = 1,
		border_corner_radius = 12,
		reactive = true,
		border_color = {255,255,255,255},
		fill_color = {255,255,255,0},
		focus_fill_color = {27,145,27,0},
		focus_text_color = {255,255,255,255},
	}

button11.name = "button11"
button11.position = {734,96,0}
button11.scale = {1,1,0,0}
button11.anchor_point = {0,0}
button11.x_rotation = {0,0,0}
button11.y_rotation = {0,0,0}
button11.z_rotation = {0,0,0}
button11.opacity = 255
button11.extra.focus = {[keys.Right] = "button1", [keys.Return] = "button11", [keys.Left] = "button0", }

function button11:on_key_down(key)
	if button11.focus[key] then
		if type(button11.focus[key]) == "function" then
			button11.focus[key]()
		elseif screen:find_child(button11.focus[key]) then
			if button11.on_focus_out then
				button11.on_focus_out(key)
			end
			screen:find_child(button11.focus[key]):grab_key_focus()
			if screen:find_child(button11.focus[key]).on_focus_in then
				screen:find_child(button11.focus[key]).on_focus_in(key)
			end
		end
	end
	return true
end

button11.extra.reactive = true


local pass_summary_txt = Text
	{
		color = {102,204,0,255},
		font = "FreeSans Medium 35px",
		text = "",
		editable = true,
		wants_enter = true,
		wrap = true,
		wrap_mode = "CHAR",
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "pass_summary_txt",
		position = {282,411,0},
		size = {300,37},
		opacity = 255,
		reactive = true,
		cursor_visible = false,
	}

pass_summary_txt.extra.focus = {}

function pass_summary_txt:on_key_down(key)
	if pass_summary_txt.focus[key] then
		if type(pass_summary_txt.focus[key]) == "function" then
			pass_summary_txt.focus[key]()
		elseif screen:find_child(pass_summary_txt.focus[key]) then
			if pass_summary_txt.on_focus_out then
				pass_summary_txt.on_focus_out(key)
			end
			screen:find_child(pass_summary_txt.focus[key]):grab_key_focus()
			if screen:find_child(pass_summary_txt.focus[key]).on_focus_in then
				screen:find_child(pass_summary_txt.focus[key]).on_focus_in(key)
			end
		end
	end
	return true
end

pass_summary_txt.extra.reactive = true


local fail_summary_txt = Text
	{
		color = {255,61,61,255},
		font = "FreeSans Medium 35px",
		text = "",
		editable = true,
		wants_enter = true,
		wrap = true,
		wrap_mode = "CHAR",
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "fail_summary_txt",
		position = {606,411,0},
		size = {300,36},
		opacity = 255,
		reactive = true,
		cursor_visible = false,
	}

fail_summary_txt.extra.focus = {}

function fail_summary_txt:on_key_down(key)
	if fail_summary_txt.focus[key] then
		if type(fail_summary_txt.focus[key]) == "function" then
			fail_summary_txt.focus[key]()
		elseif screen:find_child(fail_summary_txt.focus[key]) then
			if fail_summary_txt.on_focus_out then
				fail_summary_txt.on_focus_out(key)
			end
			screen:find_child(fail_summary_txt.focus[key]):grab_key_focus()
			if screen:find_child(fail_summary_txt.focus[key]).on_focus_in then
				screen:find_child(fail_summary_txt.focus[key]).on_focus_in(key)
			end
		end
	end
	return true
end

fail_summary_txt.extra.reactive = true


local total_tests_txt = Text
	{
		color = {255,255,100,255},
		font = "FreeSans Medium 35px",
		text = "",
		editable = true,
		wants_enter = true,
		wrap = true,
		wrap_mode = "CHAR",
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "total_tests_txt",
		position = {930,411,0},
		size = {300,36},
		opacity = 255,
		reactive = true,
		cursor_visible = false,
	}

total_tests_txt.extra.focus = {}

function total_tests_txt:on_key_down(key)
	if total_tests_txt.focus[key] then
		if type(total_tests_txt.focus[key]) == "function" then
			total_tests_txt.focus[key]()
		elseif screen:find_child(total_tests_txt.focus[key]) then
			if total_tests_txt.on_focus_out then
				total_tests_txt.on_focus_out(key)
			end
			screen:find_child(total_tests_txt.focus[key]):grab_key_focus()
			if screen:find_child(total_tests_txt.focus[key]).on_focus_in then
				screen:find_child(total_tests_txt.focus[key]).on_focus_in(key)
			end
		end
	end
	return true
end

total_tests_txt.extra.reactive = true


g:add(scrollPane12,rect5,button0,button1,text2,rect16,text30,steps_txt,button11,pass_summary_txt,fail_summary_txt,total_tests_txt)
