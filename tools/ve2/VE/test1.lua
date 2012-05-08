local g = ... 


local rectangle0 = Rectangle
	{
		color = {255,255,255,255},
		border_color = {255,255,255,255},
		border_width = 0,
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "rectangle0",
		position = {160,216,0},
		size = {186,212},
		opacity = 255,
		reactive = true,
	}

rectangle0.extra.focus = {}

function rectangle0:on_key_down(key)
	if rectangle0.focus[key] then
		if type(rectangle0.focus[key]) == "function" then
			rectangle0.focus[key]()
		elseif screen:find_child(rectangle0.focus[key]) then
			if rectangle0.clear_focus then
				rectangle0.clear_focus(key)
			end
			screen:find_child(rectangle0.focus[key]):grab_key_focus()
			if screen:find_child(rectangle0.focus[key]).set_focus then
				screen:find_child(rectangle0.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

rectangle0.extra.reactive = true


local clone1 = Clone
	{
		scale = {1,1,0,0},
		source = rectangle0,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone1",
		position = {390,216,0},
		size = {186,212},
		opacity = 255,
		reactive = true,
	}

clone1.extra.focus = {}

function clone1:on_key_down(key)
	if clone1.focus[key] then
		if type(clone1.focus[key]) == "function" then
			clone1.focus[key]()
		elseif screen:find_child(clone1.focus[key]) then
			if clone1.clear_focus then
				clone1.clear_focus(key)
			end
			screen:find_child(clone1.focus[key]):grab_key_focus()
			if screen:find_child(clone1.focus[key]).set_focus then
				screen:find_child(clone1.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

clone1.extra.reactive = true


local image2 = Image
	{
		src = "/assets/images/img_big_01.png",
		clip = {0,0,450,978},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image2",
		position = {590,208,0},
		size = {450,978},
		opacity = 255,
		reactive = true,
	}

image2.extra.focus = {}

function image2:on_key_down(key)
	if image2.focus[key] then
		if type(image2.focus[key]) == "function" then
			image2.focus[key]()
		elseif screen:find_child(image2.focus[key]) then
			if image2.clear_focus then
				image2.clear_focus(key)
			end
			screen:find_child(image2.focus[key]):grab_key_focus()
			if screen:find_child(image2.focus[key]).set_focus then
				screen:find_child(image2.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

image2.extra.reactive = true


local text3 = Text
	{
		color = {255,255,255,255},
		font = "FreeSans Medium 30px",
		text = "TEXT",
		editable = false,
		wants_enter = true,
		wrap = true,
		wrap_mode = "CHAR",
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "text3",
		position = {1046,224,0},
		size = {75,39},
		opacity = 255,
		reactive = true,
		cursor_visible = false,
	}

text3.extra.focus = {}

function text3:on_key_down(key)
	if text3.focus[key] then
		if type(text3.focus[key]) == "function" then
			text3.focus[key]()
		elseif screen:find_child(text3.focus[key]) then
			if text3.clear_focus then
				text3.clear_focus(key)
			end
			screen:find_child(text3.focus[key]):grab_key_focus()
			if screen:find_child(text3.focus[key]).set_focus then
				screen:find_child(text3.focus[key]).set_focus(key)
			end
		end
	end
	return true
end

text3.extra.reactive = true


g:add(rectangle0,clone1,image2,text3)