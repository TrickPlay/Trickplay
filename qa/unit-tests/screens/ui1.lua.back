local g = ... 


local rect2 = Rectangle
	{
		color = {204,204,153,255},
		border_color = {255,255,255,255},
		border_width = 0,
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "rect2",
		position = {606,152,0},
		size = {600,300},
		opacity = 255,
		reactive = true,
	}

rect2.extra.focus = {}

function rect2:on_key_down(key)
	if rect2.focus[key] then
		if type(rect2.focus[key]) == "function" then
			rect2.focus[key]()
		elseif screen:find_child(rect2.focus[key]) then
			if rect2.on_focus_out then
				rect2.on_focus_out()
			end
			screen:find_child(rect2.focus[key]):grab_key_focus()
			if screen:find_child(rect2.focus[key]).on_focus_in then
				screen:find_child(rect2.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

rect2.extra.reactive = true


local button0 = ui_element.button
	{
		ui_width = 400,
		ui_height = 60,
		skin = "default",
		label = "Acceptance Tests",
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
button0.position = {710,234,0}
button0.scale = {1,1,0,0}
button0.anchor_point = {0,0}
button0.x_rotation = {0,0,0}
button0.y_rotation = {0,0,0}
button0.z_rotation = {0,0,0}
button0.opacity = 255
button0.extra.focus = {[65364] = "button1", [65293] = "button0", }

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
		label = "iPhone Controller Tests",
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
button1.position = {712,322,0}
button1.scale = {1,1,0,0}
button1.anchor_point = {0,0}
button1.x_rotation = {0,0,0}
button1.y_rotation = {0,0,0}
button1.z_rotation = {0,0,0}
button1.opacity = 255
button1.extra.focus = {[65362] = "button0", [65293] = "button1", }

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


local rect3 = Rectangle
	{
		color = {0,0,0,255},
		border_color = {255,255,255,255},
		border_width = 2,
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "rect3",
		position = {78,492,0},
		size = {1760,480},
		opacity = 255,
		reactive = true,
	}

rect3.extra.focus = {}

function rect3:on_key_down(key)
	if rect3.focus[key] then
		if type(rect3.focus[key]) == "function" then
			rect3.focus[key]()
		elseif screen:find_child(rect3.focus[key]) then
			if rect3.on_focus_out then
				rect3.on_focus_out()
			end
			screen:find_child(rect3.focus[key]):grab_key_focus()
			if screen:find_child(rect3.focus[key]).on_focus_in then
				screen:find_child(rect3.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

rect3.extra.reactive = true


local text4 = Text
	{
		color = {0,0,0,255},
		font = "DejaVu Sans Bold 40px",
		text = "Test Options",
		editable = true,
		wants_enter = true,
		wrap = true,
		wrap_mode = "CHAR",
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "text4",
		position = {764,156,0},
		size = {300,100},
		opacity = 255,
		reactive = true,
		cursor_visible = false,
	}

text4.extra.focus = {}

function text4:on_key_down(key)
	if text4.focus[key] then
		if type(text4.focus[key]) == "function" then
			text4.focus[key]()
		elseif screen:find_child(text4.focus[key]) then
			if text4.on_focus_out then
				text4.on_focus_out()
			end
			screen:find_child(text4.focus[key]):grab_key_focus()
			if screen:find_child(text4.focus[key]).on_focus_in then
				screen:find_child(text4.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

text4.extra.reactive = true


local text11 = Text
	{
		color = {255,255,255,255},
		font = "DejaVu Sans 30px",
		text = "Acceptance Tests - Comprehensive set of API tests that verify that strings, tables or boolean values are returned. \n\niPhone Controller Tests - Similar to the Acceptance Unit tests except this set of tests only hits the controller APIs. You need to have an iPhone or similar suppported Trickplay device to run these tests.",
		editable = true,
		wants_enter = true,
		wrap = true,
		wrap_mode = "CHAR",
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "text11",
		position = {96,512,0},
		size = {1720,440},
		opacity = 255,
		reactive = true,
		cursor_visible = false,
	}

text11.extra.focus = {}

function text11:on_key_down(key)
	if text11.focus[key] then
		if type(text11.focus[key]) == "function" then
			text11.focus[key]()
		elseif screen:find_child(text11.focus[key]) then
			if text11.on_focus_out then
				text11.on_focus_out()
			end
			screen:find_child(text11.focus[key]):grab_key_focus()
			if screen:find_child(text11.focus[key]).on_focus_in then
				screen:find_child(text11.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

text11.extra.reactive = true


local text19 = Text
	{
		color = {255,255,255,255},
		font = "DejaVu Sans 35px",
		text = "Test Suite Description",
		editable = false,
		wants_enter = true,
		wrap = true,
		wrap_mode = "CHAR",
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "text19",
		position = {86,440,0},
		size = {400,100},
		opacity = 255,
		reactive = true,
		cursor_visible = false,
	}

text19.extra.focus = {}

function text19:on_key_down(key)
	if text19.focus[key] then
		if type(text19.focus[key]) == "function" then
			text19.focus[key]()
		elseif screen:find_child(text19.focus[key]) then
			if text19.on_focus_out then
				text19.on_focus_out()
			end
			screen:find_child(text19.focus[key]):grab_key_focus()
			if screen:find_child(text19.focus[key]).on_focus_in then
				screen:find_child(text19.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

text19.extra.reactive = true


local text7 = Text
	{
		color = {255,255,255,255},
		font = "DejaVu Sans Bold 45px",
		text = "Trickplay Engine Unit Tests",
		editable = false,
		wants_enter = true,
		wrap = true,
		wrap_mode = "CHAR",
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "text7",
		position = {586,74,0},
		size = {1000,100},
		opacity = 255,
		reactive = true,
		cursor_visible = false,
	}

text7.extra.focus = {}

function text7:on_key_down(key)
	if text7.focus[key] then
		if type(text7.focus[key]) == "function" then
			text7.focus[key]()
		elseif screen:find_child(text7.focus[key]) then
			if text7.on_focus_out then
				text7.on_focus_out()
			end
			screen:find_child(text7.focus[key]):grab_key_focus()
			if screen:find_child(text7.focus[key]).on_focus_in then
				screen:find_child(text7.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

text7.extra.reactive = true


g:add(rect2,button0,button1,rect3,text4,text11,text19,text7)
