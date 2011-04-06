
local menu_bar = Image
	{
		src = "assets/menu-bar.png",
		clip = {0,0,1920,60},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "menu_bar",
		position = {0,0,0},
		size = {1920,60},
		opacity = 255,
		reactive = true,
	}

local menuButton_file = ui_element.menuButton
	{
		ui_width = 142,
		ui_height = 61,
		skin = "editor",
		label = "File",
		focus_color = {27,145,27,255},
		text_color = "#cccccc",
		text_font = "FreeSans Medium 28px",
		border_width = 1,
		border_corner_radius = 12,
		reactive = true,
		border_color = {255,255,255,255},
		fill_color = {255,255,255,0},
		items = {
		},
		menu_width = 250,
		horz_padding = 24,
		vert_spacing = 0,
		horz_spacing = 0,
		vert_offset = 0,
		background_color = {255,0,0,0},
		seperator_thickness = 0,
		expansion_location = "below",
		focus_fill_color = {27,145,27,0},
		focus_text_color = {255,255,255,255},
	}


menuButton_file.insert_item(1,{type="item", string="New\t\t\t    N", bg=assets("assets/menu-item.png"), focus=assets("assets/menu-item-focus.png"), f=editor.close} )
menuButton_file.insert_item(2,{type="item", string="Open ...\t\t    O", bg=assets("assets/menu-item.png"), focus= assets("assets/menu-item-focus.png"), f=editor.the_open})
menuButton_file.insert_item(3,{type="item", string="Save ...\t\t    S", bg=assets("assets/menu-item.png"), focus= assets("assets/menu-item-focus.png"), f=editor.save}) 
menuButton_file.insert_item(4,{type="item", string="Save As ...\t    A", bg=assets("assets/menu-item.png"), focus= assets("assets/menu-item-focus.png"), f=editor.save})
menuButton_file.insert_item(5,{type="item", string="Quit\t\t\t    Q", bg=assets("assets/menu-item.png"), focus= assets("assets/menu-item-focus.png"), f=exit}) 


menuButton_file.name = "menuButton_file"
menuButton_file.position = {249,28,0}
menuButton_file.scale = {1,1,0,0}
menuButton_file.anchor_point = {71,30.5}
menuButton_file.x_rotation = {0,0,0}
menuButton_file.y_rotation = {0,0,0}
menuButton_file.z_rotation = {0,0,0}
menuButton_file.opacity = 255
menuButton_file.extra.focus = {[65293] = "menuButton_file", [65363] = "menuButton_edit", }

function menuButton_file:on_key_down(key)
	if menuButton_file.focus[key] then
		if type(menuButton_file.focus[key]) == "function" then
			menuButton_file.focus[key]()
		elseif screen:find_child(menuButton_file.focus[key]) then
			if menuButton_file.on_focus_out then
				menuButton_file.on_focus_out()
			end
			screen:find_child(menuButton_file.focus[key]):grab_key_focus()
			if screen:find_child(menuButton_file.focus[key]).on_focus_in then
				screen:find_child(menuButton_file.focus[key]).on_focus_in()
			end
			end
	end
	return true
end

menuButton_file.extra.reactive = true


local menuButton_edit = ui_element.menuButton
	{
		ui_width = 142,
		ui_height = 61,
		skin = "editor",
		label = "Edit",
		focus_color = {27,145,27,255},
		--text_color = {255,255,255,255},
		--text_font = "DejaVu Sans 30px",
		text_color = "#cccccc",
		text_font = "FreeSans Medium 28px",
		border_width = 1,
		border_corner_radius = 12,
		reactive = true,
		border_color = {255,255,255,255},
		fill_color = {255,255,255,0},
		items = {
		},
		menu_width = 250,
		horz_padding = 24,
		vert_spacing = 0,
		horz_spacing = 0,
		vert_offset = 0,
		background_color = {255,0,0,0},
		seperator_thickness = 0,
		expansion_location = "below",
		focus_fill_color = {27,145,27,0},
		focus_text_color = {255,255,255,255},
	}

menuButton_edit.insert_item(1,{type="item", string="Undo\t\t    Z", bg=assets("assets/menu-item.png"), focus=assets("assets/menu-item-focus.png"), f=editor.undo} )
menuButton_edit.insert_item(2,{type="item", string="Redo\t\t    E", bg=assets("assets/menu-item.png"), focus=assets("assets/menu-item-focus.png"), f=editor.redo} )
menuButton_edit.insert_item(3,{type="item", string="Insert UI Element  I", bg=assets("assets/menu-item.png"), focus= assets("assets/menu-item-focus.png"), f=editor.ui_elements})
menuButton_edit.insert_item(4,{type="item", string="Timeline...\t     J", bg=assets("assets/menu-item.png"), focus= assets("assets/menu-item-focus.png"), f=editor.timeline}) 
menuButton_edit.insert_item(5,{type="item", string="Delete", bg=assets("assets/menu-item.png"), focus= assets("assets/menu-item-focus.png"), f=editor.delete})
menuButton_edit.insert_item(6,{type="item", string="Duplicate\t    D", bg=assets("assets/menu-item.png"), focus= assets("assets/menu-item-focus.png"), f=editor.duplicate}) 
menuButton_edit.insert_item(7,{type="item", string="Clone\t\t    C", bg=assets("assets/menu-item.png"), focus= assets("assets/menu-item-focus.png"), f=editor.clone}) 
menuButton_edit.insert_item(8,{type="item", string="Group\t\t    G", bg=assets("assets/menu-item.png"), focus= assets("assets/menu-item-focus.png"), f=editor.group}) 
menuButton_edit.insert_item(9,{type="item", string="UnGroup\t\t    U", bg=assets("assets/menu-item.png"), focus= assets("assets/menu-item-focus.png"), f=editor.ugroup}) 

menuButton_edit.name = "menuButton_edit"
menuButton_edit.position = {489,28,0}
menuButton_edit.scale = {1,1,0,0}
menuButton_edit.anchor_point = {71,30.5}
menuButton_edit.x_rotation = {0,0,0}
menuButton_edit.y_rotation = {0,0,0}
menuButton_edit.z_rotation = {0,0,0}
menuButton_edit.opacity = 255
menuButton_edit.extra.focus = {[65363] = "menuButton_arrange", [65293] = "menuButton_edit", [65361] = "menuButton_file", }

function menuButton_edit:on_key_down(key)
	if menuButton_edit.focus[key] then
		if type(menuButton_edit.focus[key]) == "function" then
			menuButton_edit.focus[key]()
		elseif screen:find_child(menuButton_edit.focus[key]) then
			if menuButton_edit.on_focus_out then
				menuButton_edit.on_focus_out()
			end
			screen:find_child(menuButton_edit.focus[key]):grab_key_focus()
			if screen:find_child(menuButton_edit.focus[key]).on_focus_in then
				screen:find_child(menuButton_edit.focus[key]).on_focus_in()
			end
			end
	end
	return true
end

menuButton_edit.extra.reactive = true


local menuButton_arrange = ui_element.menuButton
	{
		ui_width = 142,
		ui_height = 61,
		skin = "editor",
		label = "Arrange",
		focus_color = {27,145,27,255},
		--text_color = {255,255,255,255},
		--text_font = "DejaVu Sans 30px",
		text_color = "#cccccc",
		text_font = "FreeSans Medium 28px",
		border_width = 1,
		border_corner_radius = 12,
		reactive = true,
		border_color = {255,255,255,255},
		fill_color = {255,255,255,0},
		items = {
		},
		menu_width = 250,
		horz_padding = 24,
		vert_spacing = 0,
		horz_spacing = 0,
		vert_offset = 0,
		background_color = {255,0,0,0},
		seperator_thickness = 0,
		expansion_location = "below",
		focus_fill_color = {27,145,27,0},
		focus_text_color = {255,255,255,255},
	}

menuButton_arrange.insert_item(1,{type="label", string="  Align:", bg=assets("assets/menu-item-label.png")} )
menuButton_arrange.insert_item(2,{type="item", string="Left", bg=assets("assets/menu-item.png"), focus=assets("assets/menu-item-focus.png"), f=editor.left} )
menuButton_arrange.insert_item(3,{type="item", string="Right", bg=assets("assets/menu-item.png"), focus=assets("assets/menu-item-focus.png"), f=editor.right} )
menuButton_arrange.insert_item(4,{type="item", string="Top", bg=assets("assets/menu-item.png"), focus= assets("assets/menu-item-focus.png"), f=editor.top})
menuButton_arrange.insert_item(5,{type="item", string="Bottom", bg=assets("assets/menu-item.png"), focus= assets("assets/menu-item-focus.png"), f=editor.bottom}) 
menuButton_arrange.insert_item(6,{type="item", string="Horizontal Center", bg=assets("assets/menu-item.png"), focus= assets("assets/menu-item-focus.png"), f=editor.hcenter})
menuButton_arrange.insert_item(7,{type="item", string="Vertical Center", bg=assets("assets/menu-item.png"), focus= assets("assets/menu-item-focus.png"), f=editor.vcenter}) 
menuButton_arrange.insert_item(8,{type="label", string="  Distribute:", bg=assets("assets/menu-item-label.png")} )
menuButton_arrange.insert_item(9,{type="item", string="Horizontally", bg=assets("assets/menu-item.png"), focus= assets("assets/menu-item-focus.png"), f=hspace}) 
menuButton_arrange.insert_item(10,{type="item", string="Vertically", bg=assets("assets/menu-item.png"), focus= assets("assets/menu-item-focus.png"), f=vspace}) 
menuButton_arrange.insert_item(11,{type="label", string="  Arrange:", bg=assets("assets/menu-item-label.png")} )
menuButton_arrange.insert_item(12,{type="item", string="Bring to Front", bg=assets("assets/menu-item.png"), focus= assets("assets/menu-item-focus.png"), f=editor.bring_to_front}) 
menuButton_arrange.insert_item(13,{type="item", string="Bring Forward", bg=assets("assets/menu-item.png"), focus= assets("assets/menu-item-focus.png"), f=editor.bring_forward}) 
menuButton_arrange.insert_item(14,{type="item", string="Send Backward", bg=assets("assets/menu-item.png"), focus= assets("assets/menu-item-focus.png"), f=editor.send_to_back}) 
menuButton_arrange.insert_item(15,{type="item", string="Send to Back", bg=assets("assets/menu-item.png"), focus= assets("assets/menu-item-focus.png"), f=editor.send_backward}) 

menuButton_arrange.name = "menuButton_arrange"
menuButton_arrange.position = {729,28,0}
menuButton_arrange.scale = {1,1,0,0}
menuButton_arrange.anchor_point = {71,30.5}
menuButton_arrange.x_rotation = {0,0,0}
menuButton_arrange.y_rotation = {0,0,0}
menuButton_arrange.z_rotation = {0,0,0}
menuButton_arrange.opacity = 255
menuButton_arrange.extra.focus = {[65363] = "menuButton_view", [65293] = "menuButton_arrange", [65361] = "menuButton_edit", }

function menuButton_arrange:on_key_down(key)
	if menuButton_arrange.focus[key] then
		if type(menuButton_arrange.focus[key]) == "function" then
			menuButton_arrange.focus[key]()
		elseif screen:find_child(menuButton_arrange.focus[key]) then
			if menuButton_arrange.on_focus_out then
				menuButton_arrange.on_focus_out()
			end
			screen:find_child(menuButton_arrange.focus[key]):grab_key_focus()
			if screen:find_child(menuButton_arrange.focus[key]).on_focus_in then
				screen:find_child(menuButton_arrange.focus[key]).on_focus_in()
			end
			end
	end
	return true
end

menuButton_arrange.extra.reactive = true


local menuButton_view = ui_element.menuButton
	{
		ui_width = 142,
		ui_height = 61,
		skin = "editor",
		label = "View",
		focus_color = {27,145,27,255},
		--text_color = {255,255,255,255},
		--text_font = "DejaVu Sans 30px",
		text_color = "#cccccc",
		text_font = "FreeSans Medium 28px",
		border_width = 1,
		border_corner_radius = 12,
		reactive = true,
		border_color = {255,255,255,255},
		fill_color = {255,255,255,0},
		items = {
		},
		menu_width = 250,
		horz_padding = 24,
		vert_spacing = 0,
		horz_spacing = 0,
		vert_offset = 0,
		background_color = {255,0,0,0},
		seperator_thickness = 0,
		expansion_location = "below",
		focus_fill_color = {27,145,27,0},
		focus_text_color = {255,255,255,255},
	}


menuButton_view.insert_item(1,{type="label", string="  Background:", bg=assets("assets/menu-item-label.png")} )
menuButton_view.insert_item(2,{type="item", string="Image...", bg=assets("assets/menu-item.png"), focus=assets("assets/menu-item-focus.png"), f=editor.the_image} )
menuButton_view.insert_item(3,{type="item", string="Small Grid", bg=assets("assets/menu-item.png"), focus=assets("assets/menu-item-focus.png"), f=editor.close} )
menuButton_view.insert_item(4,{type="item", string="Medium Grid", bg=assets("assets/menu-item.png"), focus= assets("assets/menu-item-focus.png"), f=editor.the_open})
menuButton_view.insert_item(5,{type="item", string="Large Grid", bg=assets("assets/menu-item.png"), focus= assets("assets/menu-item-focus.png"), f=editor.save}) 
menuButton_view.insert_item(6,{type="item", string="White", bg=assets("assets/menu-item.png"), focus= assets("assets/menu-item-focus.png"), f=editor.save})
menuButton_view.insert_item(7,{type="item", string="Black", bg=assets("assets/menu-item.png"), focus= assets("assets/menu-item-focus.png"), f=exit}) 
menuButton_view.insert_item(8,{type="label", string="  Guides:", bg=assets("assets/menu-item-label.png")} )
menuButton_view.insert_item(9,{type="item", string="Add Horizontal Guide", bg=assets("assets/menu-item.png"), focus= assets("assets/menu-item-focus.png"), f=exit}) 
menuButton_view.insert_item(10,{type="item", string="Add Vertical Guide", bg=assets("assets/menu-item.png"), focus= assets("assets/menu-item-focus.png"), f=exit}) 
menuButton_view.insert_item(11,{type="item", string="Show Guides", bg=assets("assets/menu-item.png"), focus= assets("assets/menu-item-focus.png"), f=exit}) 
menuButton_view.insert_item(12,{type="item", string="Snap to Guides", bg=assets("assets/menu-item.png"), focus= assets("assets/menu-item-focus.png"), f=exit}) 

menuButton_view.name = "menuButton_view"
menuButton_view.position = {971,28,0}
menuButton_view.scale = {1,1,0,0}
menuButton_view.anchor_point = {71,30.5}
menuButton_view.x_rotation = {0,0,0}
menuButton_view.y_rotation = {0,0,0}
menuButton_view.z_rotation = {0,0,0}
menuButton_view.opacity = 255
menuButton_view.extra.focus = {[65293] = "menuButton_view", [65361] = "menuButton_arrange", }

function menuButton_view:on_key_down(key)
	if menuButton_view.focus[key] then
		if type(menuButton_view.focus[key]) == "function" then
			menuButton_view.focus[key]()
		elseif screen:find_child(menuButton_view.focus[key]) then
			if menuButton_view.on_focus_out then
				menuButton_view.on_focus_out()
			end
			screen:find_child(menuButton_view.focus[key]):grab_key_focus()
			if screen:find_child(menuButton_view.focus[key]).on_focus_in then
				screen:find_child(menuButton_view.focus[key]).on_focus_in()
			end
			end
	end
	return true
end

menuButton_view.extra.reactive = true


local menu_text = Text
	{
		color = "#cccccc",
		font = "FreeSans Medium 20px",
		text = "TestProject::File1.lua::Object1",
		editable = true,
		wants_enter = false,
		wrap = false,
		wrap_mode = "CHAR",
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {350,30.5},
		name = "menu_text",
		position = {1500,47,0},
		size = {700,20},
		opacity = 255,
		reactive = false,
		cursor_visible =false,
		alignment ="RIGHT",
	}

screen:add(menu_bar,menuButton_file,menuButton_edit,menuButton_arrange,menuButton_view,menu_text)
