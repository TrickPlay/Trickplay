local g = ... 


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
		position = {188,74,0},
		size = {1500,152},
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
				rect5.on_focus_out()
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
button0.position = {230,112,0}
button0.scale = {1,1,0,0}
button0.anchor_point = {0,0}
button0.x_rotation = {0,0,0}
button0.y_rotation = {0,0,0}
button0.z_rotation = {0,0,0}
button0.opacity = 255
button0.extra.focus = {[65293] = "button0", [65363] = "button11", }

function button0:on_key_down(key)
	if button0.focus[key] then
		if type(button0.focus[key]) == "function" then
			button0.focus[key]()
		elseif screen:find_child(button0.focus[key]) then
			if button0.on_focus_out then
				button0.on_focus_out()
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
button1.position = {1246,112,0}
button1.scale = {1,1,0,0}
button1.anchor_point = {0,0}
button1.x_rotation = {0,0,0}
button1.y_rotation = {0,0,0}
button1.z_rotation = {0,0,0}
button1.opacity = 255
button1.extra.focus = {[65293] = "button1", [65361] = "button11", }

function button1:on_key_down(key)
	if button1.focus[key] then
		if type(button1.focus[key]) == "function" then
			button1.focus[key]()
		elseif screen:find_child(button1.focus[key]) then
			if button1.on_focus_out then
				button1.on_focus_out()
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
		editable = false,
		wants_enter = true,
		wrap = true,
		wrap_mode = "CHAR",
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "text2",
		position = {74,230,0},
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
				text2.on_focus_out()
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
		position = {76,296,0},
		size = {1800,200},
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
				rect16.on_focus_out()
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


local rectangle28 = Rectangle
	{
		color = {0,0,0,255},
		border_color = {255,255,255,255},
		border_width = 2,
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "rectangle28",
		position = {78,560,0},
		size = {1800,500},
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
				rectangle28.on_focus_out()
			end
			screen:find_child(rectangle28.focus[key]):grab_key_focus()
			if screen:find_child(rectangle28.focus[key]).on_focus_in then
				screen:find_child(rectangle28.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

rectangle28.extra.reactive = true


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
		position = {74,496,0},
		size = {200,50},
		opacity = 255,
		reactive = true,
		cursor_visible = false,
	}

text30.extra.reactive = true


steps_txt = Text
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
		position = {92,318,0},
		size = {1760,160},
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
				steps_txt.on_focus_out()
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


col3_results_txt = Text
	{
		color = {255,255,255,255},
		font = "DejaVu Sans 25px",
		text = "",
		editable = true,
		wants_enter = true,
		wrap = false,
		wrap_mode = "CHAR",
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "col3_results_txt",
		position = {1284,574,0},
		size = {580,460},
		opacity = 255,
		reactive = true,
		cursor_visible = false,
	}

col3_results_txt.extra.focus = {}

function col3_results_txt:on_key_down(key)
	if col3_results_txt.focus[key] then
		if type(col3_results_txt.focus[key]) == "function" then
			col3_results_txt.focus[key]()
		elseif screen:find_child(col3_results_txt.focus[key]) then
			if col3_results_txt.on_focus_out then
				col3_results_txt.on_focus_out()
			end
			screen:find_child(col3_results_txt.focus[key]):grab_key_focus()
			if screen:find_child(col3_results_txt.focus[key]).on_focus_in then
				screen:find_child(col3_results_txt.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

col3_results_txt.extra.reactive = true


col2_results_txt = Text
	{
		color = {255,255,255,255},
		font = "DejaVu Sans 25px",
		text = "",
		editable = true,
		wants_enter = true,
		wrap = false,
		wrap_mode = "CHAR",
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "col2_results_txt",
		position = {684,572,0},
		size = {580,460},
		opacity = 255,
		reactive = true,
		cursor_visible = false,
	}

col2_results_txt.extra.focus = {}

function col2_results_txt:on_key_down(key)
	if col2_results_txt.focus[key] then
		if type(col2_results_txt.focus[key]) == "function" then
			col2_results_txt.focus[key]()
		elseif screen:find_child(col2_results_txt.focus[key]) then
			if col2_results_txt.on_focus_out then
				col2_results_txt.on_focus_out()
			end
			screen:find_child(col2_results_txt.focus[key]):grab_key_focus()
			if screen:find_child(col2_results_txt.focus[key]).on_focus_in then
				screen:find_child(col2_results_txt.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

col2_results_txt.extra.reactive = true


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
button11.position = {734,112,0}
button11.scale = {1,1,0,0}
button11.anchor_point = {0,0}
button11.x_rotation = {0,0,0}
button11.y_rotation = {0,0,0}
button11.z_rotation = {0,0,0}
button11.opacity = 255
button11.extra.focus = {[65363] = "button1", [65293] = "button11", [65361] = "button0", }

function button11:on_key_down(key)
	if button11.focus[key] then
		if type(button11.focus[key]) == "function" then
			button11.focus[key]()
		elseif screen:find_child(button11.focus[key]) then
			if button11.on_focus_out then
				button11.on_focus_out()
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


col1_results_txt = Text
	{
		color = {255,255,255,255},
		font = "DejaVu Sans 25px",
		text = "",
		editable = true,
		wants_enter = true,
		wrap = false,
		wrap_mode = "CHAR",
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "col1_results_txt",
		position = {98,572,0},
		size = {580,460},
		opacity = 255,
		reactive = true,
		cursor_visible = false,
	}

col1_results_txt.extra.focus = {}

function col1_results_txt:on_key_down(key)
	if col1_results_txt.focus[key] then
		if type(col1_results_txt.focus[key]) == "function" then
			col1_results_txt.focus[key]()
		elseif screen:find_child(col1_results_txt.focus[key]) then
			if col1_results_txt.on_focus_out then
				col1_results_txt.on_focus_out()
			end
			screen:find_child(col1_results_txt.focus[key]):grab_key_focus()
			if screen:find_child(col1_results_txt.focus[key]).on_focus_in then
				screen:find_child(col1_results_txt.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

col1_results_txt.extra.reactive = true


g:add(rect5,button0,button1,text2,rect16,rectangle28,text30,steps_txt,col3_results_txt,col2_results_txt,button11,col1_results_txt)
