editor_use = true

local menu = {}
local menu_items
local menu_bar = Image
	{
		src = "assets/menu-bar.png",
		clip = {0,0,1920,60},
		scale = {1,1,0,0},
		name = "menu_bar",
		position = {0,0,0},
		size = {1920,60},
		reactive = true,
	}

local menuButton_file = ui_element.menuButton
	{
		ui_width = 142,
		ui_height = 61,
		skin = "editor",
		label = "File",
		focus_border_color = {27,145,27,255},
		text_color = "#cccccc",
		text_font = "FreeSans Bold 28px",
		focus_text_color = "#cccccc", 
		border_width = 1,
		border_corner_radius = 12,
		reactive = true,
		border_color = {255,255,255,255},
		fill_color = {255,255,255,0},
		items = {},
		menu_width = 250,
		horz_padding = 24,
		vert_spacing = 0,
		horz_spacing = 0,
		vert_offset = 4,
		background_color = {255,0,0,0},
		separator_thickness = 0,
		expansion_location = "below",
		focus_fill_color = {27,145,27,0},
		label_text_font ="FreeSans Bold 20px", 
    	label_text_color = "#808080",
        item_text_font = "FreeSans Bold 20px",
    	item_text_color = "#ffffff",
		ui_position = {249,28,0}, 
		button_name = "menuButton_file", 
	}


menuButton_file.insert_item(1,{type="item", string="New", bg=assets("assets/menu-item.png"), focus=assets("assets/menu-item-focus.png"), f=editor.close, parameter=true, icon=Text{text="N"}})
menuButton_file.insert_item(2,{type="item", string="Open...", bg=assets("assets/menu-item.png"), focus= assets("assets/menu-item-focus.png"), f=editor.open, icon=Text{text="O"}})
menuButton_file.insert_item(3,{type="item", string="Save", bg=assets("assets/menu-item.png"), focus= assets("assets/menu-item-focus.png"), f=editor.save, parameter=true, icon=Text{text="S"}})
menuButton_file.insert_item(4,{type="item", string="Save As...", bg=assets("assets/menu-item.png"), focus= assets("assets/menu-item-focus.png"), f=editor.save, parameter=false,  icon=Text{text="A"}})
menuButton_file.insert_item(5,{type="item", string="New Project...", bg=assets("assets/menu-item.png"), focus= assets("assets/menu-item-focus.png"), f=project_mng.new_project, icon=Text{text="F"}})
menuButton_file.insert_item(6,{type="item", string="Open Project...", bg=assets("assets/menu-item.png"), focus= assets("assets/menu-item-focus.png"), f=project_mng.open_project, parameter=false,  icon=Text{text="P"}})
menuButton_file.insert_item(7,{type="item", string="Quit", bg=assets("assets/menu-item-bottom.png"), focus= assets("assets/menu-item-bottom-focus.png"), f=function() if editor.close(nil,exit) == nil then exit() end end, icon=Text{text="Q"}})

menuButton_file.name = "menuButton_file"
menuButton_file.anchor_point = {71,30.5}
menuButton_file.extra.focus = {[65293] = "menuButton_file", [65363] = "menuButton_edit",  [65364]=menuButton_file.press_down, [65362]=menuButton_file.press_up}

menuButton_file.extra.reactive = true

function menuButton_file:on_enter()

  	if menu_bar_hover == false then return true end 

	if current_focus and current_focus ~= menuButton_file and current_focus.name ~= "menuButton_file" then 
		local temp_focus = current_focus
	   	current_focus.clear_focus(nil,true)
		if temp_focus.is_in_menu == true then 
			temp_focus.fade_in = false
		end
	end 
	
	if current_focus == nil or (current_focus and current_focus.name ~= "menuButton_file" ) then 
		menuButton_file.extra.set_focus(keys.Return)
		current_focus.name = "menuButton_file"
    end 

	return true
end 

local menuButton_edit = ui_element.menuButton
	{
		ui_width = 142,
		ui_height = 61,
		skin = "editor",
		label = "Edit",
		focus_border_color = {27,145,27,255},
		text_color = "#cccccc",
		text_font = "FreeSans Bold 28px",
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
		vert_offset = 4,
		background_color = {255,0,0,0},
		separator_thickness = 0,
		expansion_location = "below",
		focus_fill_color = {27,145,27,0},
		focus_text_color = "#cccccc", --{255,255,255,255},
		label_text_font ="FreeSans Bold 20px", 
    	label_text_color = "#808080",
        item_text_font = "FreeSans Bold 20px",
    	item_text_color = "#ffffff",
		ui_position = {489,28,0}, 
		button_name = "menuButton_edit", 
	}

--menuButton_edit.insert_item(1,{type="item", string="Undo", bg=assets("assets/menu-item.png"), focus=assets("assets/menu-item-focus.png"), f=function() screen:grab_key_focus() end,  icon=Text{text="Z"}})

--menuButton_edit.insert_item(2,{type="item", string="Redo", bg=assets("assets/menu-item.png"), focus=assets("assets/menu-item-focus.png"), f=function() screen:grab_key_focus() end,  icon=Text{text="E"}})

menuButton_edit.insert_item(1,{type="item", string="Insert UI Element", bg=assets("assets/menu-item.png"), focus= assets("assets/menu-item-focus.png"), f=editor.ui_elements,  icon=Text{text="I"}})

--menuButton_edit.insert_item(4,{type="item", string="Timeline...", bg=assets("assets/menu-item.png"), focus= assets("assets/menu-item-focus.png"), f=function() screen:grab_key_focus() end,  icon=Text{text="J"}})

menuButton_edit.insert_item(2,{type="item", string="Delete", bg=assets("assets/menu-item.png"), focus= assets("assets/menu-item-focus.png"), f=editor.delete, icon=assets("assets/delete-menu-icon.png")})
menuButton_edit.insert_item(3,{type="item", string="Duplicate", bg=assets("assets/menu-item.png"), focus= assets("assets/menu-item-focus.png"), f=editor.duplicate,  icon=Text{text="D"}})

menuButton_edit.insert_item(4,{type="item", string="Clone", bg=assets("assets/menu-item.png"), focus= assets("assets/menu-item-focus.png"), f=editor.clone,   icon=Text{text="C"}})

menuButton_edit.insert_item(5,{type="item", string="Group", bg=assets("assets/menu-item.png"), focus= assets("assets/menu-item-focus.png"), f=editor.group,   icon=Text{text="G"}})

menuButton_edit.insert_item(6,{type="item", string="UnGroup", bg=assets("assets/menu-item-bottom.png"), focus= assets("assets/menu-item-bottom-focus.png"), f=editor.ugroup,  icon=Text{text="U"}})

menuButton_edit.name = "menuButton_edit"
menuButton_edit.anchor_point = {71,30.5}
menuButton_edit.extra.focus = {[65363] = "menuButton_arrange", [65293] = "menuButton_edit", [65361] = "menuButton_file", [65364]=menuButton_edit.press_down, [65362]=menuButton_edit.press_up}

menuButton_edit.extra.reactive = true

 function menuButton_edit:on_enter()
 	
  	if menu_bar_hover == false then return true end 
	if current_focus and current_focus ~= menuButton_file and current_focus.name ~= "menuButton_edit" then 
		local temp_focus = current_focus
	   	current_focus.clear_focus(nil,true)
		if temp_focus.is_in_menu == true then 
			temp_focus.fade_in = false
		end 
	end 
	
	if current_focus == nil or (current_focus and current_focus.name ~= "menuButton_edit") then 
		menuButton_edit.extra.set_focus(keys.Return)
		current_focus.name = "menuButton_edit"
    end 

	return true
 end 


local menuButton_arrange = ui_element.menuButton
	{
		ui_width = 142,
		ui_height = 61,
		skin = "editor",
		label = "Arrange",
		focus_border_color = {27,145,27,255},
		text_color = "#cccccc",
		text_font = "FreeSans Bold 28px",
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
		vert_offset = 4,
		background_color = {255,0,0,0},
		separator_thickness = 0,
		expansion_location = "below",
		focus_fill_color = {27,145,27,0},
		focus_text_color = "#cccccc", 
		label_text_font ="FreeSans Bold 20px", 
    	label_text_color = "#808080",
        item_text_font = "FreeSans Bold 20px",
    	item_text_color = "#ffffff",
		ui_position = {729,28,0}, 
		button_name = "menuButton_arrange", 
	}

menuButton_arrange.insert_item(1,{type="label", string="  Align:", bg=assets("assets/menu-item-label.png")} )
menuButton_arrange.insert_item(2,{type="item", string="Left", bg=assets("assets/menu-item.png"), focus=assets("assets/menu-item-focus.png"), f=editor.left, icon=assets("assets/icon-align-left.png")} )
menuButton_arrange.insert_item(3,{type="item", string="Right", bg=assets("assets/menu-item.png"), focus=assets("assets/menu-item-focus.png"), f=editor.right, icon=assets("assets/icon-align-right.png")} )
menuButton_arrange.insert_item(4,{type="item", string="Top", bg=assets("assets/menu-item.png"), focus= assets("assets/menu-item-focus.png"), f=editor.top, icon=assets("assets/icon-align-top.png")})
menuButton_arrange.insert_item(5,{type="item", string="Bottom", bg=assets("assets/menu-item.png"), focus= assets("assets/menu-item-focus.png"), f=editor.bottom, icon=assets("assets/icon-align-bottom.png")}) 
menuButton_arrange.insert_item(6,{type="item", string="Horizontal Center", bg=assets("assets/menu-item.png"), focus= assets("assets/menu-item-focus.png"), f=editor.hcenter, icon=assets("assets/icon-align-hcenter.png")})
menuButton_arrange.insert_item(7,{type="item", string="Vertical Center", bg=assets("assets/menu-item.png"), focus= assets("assets/menu-item-focus.png"), f=editor.vcenter, icon=assets("assets/icon-align-vcenter.png")}) 
menuButton_arrange.insert_item(8,{type="label", string="  Distribute:", bg=assets("assets/menu-item-label.png")} )
menuButton_arrange.insert_item(9,{type="item", string="Horizontally", bg=assets("assets/menu-item.png"), focus= assets("assets/menu-item-focus.png"), f=editor.hspace, icon=assets("assets/icon-align-distributeh.png")}) 
menuButton_arrange.insert_item(10,{type="item", string="Vertically", bg=assets("assets/menu-item.png"), focus= assets("assets/menu-item-focus.png"), f=editor.vspace, icon=assets("assets/icon-align-distributev.png")}) menuButton_arrange.insert_item(11,{type="label", string="  Arrange:", bg=assets("assets/menu-item-label.png")} )
menuButton_arrange.insert_item(12,{type="item", string="Bring to Front", bg=assets("assets/menu-item.png"), focus= assets("assets/menu-item-focus.png"), f=editor.bring_to_front}) 
menuButton_arrange.insert_item(13,{type="item", string="Bring Forward", bg=assets("assets/menu-item.png"), focus= assets("assets/menu-item-focus.png"), f=editor.bring_forward}) 
menuButton_arrange.insert_item(14,{type="item", string="Send to Back", bg=assets("assets/menu-item.png"), focus= assets("assets/menu-item-focus.png"), f=editor.send_to_back}) 
menuButton_arrange.insert_item(15,{type="item", string="Send Backward", bg=assets("assets/menu-item-bottom.png"), focus= assets("assets/menu-item-bottom-focus.png"), f=editor.send_backward}) 

menuButton_arrange.name = "menuButton_arrange"
menuButton_arrange.anchor_point = {71,30.5}
menuButton_arrange.extra.focus = {[65363] = "menuButton_view", [65293] = "menuButton_arrange", [65361] = "menuButton_edit", [65364]=menuButton_arrange.press_down, [65362]=menuButton_arrange.press_up }

menuButton_arrange.extra.reactive = true

 function menuButton_arrange:on_enter()

  	if menu_bar_hover == false then return true end 

	if current_focus and current_focus ~= menuButton_file and current_focus.name ~= "menuButton_arrange" then 
		local temp_focus = current_focus
	   	current_focus.clear_focus(nil,true)
		if temp_focus.is_in_menu == true then 
			temp_focus.fade_in = false
		end 
	end 
	
	if current_focus == nil or (current_focus and current_focus.name ~= "menuButton_arrange") then 
		menuButton_arrange.extra.set_focus(keys.Return)
		current_focus.name = "menuButton_arrange"
    end 

	return true
 end 

local menuButton_view = ui_element.menuButton
	{
		ui_width = 142,
		ui_height = 61,
		skin = "editor",
		label = "View",
		focus_border_color = {27,145,27,255},
		text_color = "#cccccc",
		text_font = "FreeSans Bold 28px",
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
		vert_offset = 4,
		background_color = {255,0,0,0},
		separator_thickness = 0,
		expansion_location = "below",
		focus_fill_color = {27,145,27,0},
		focus_text_color = "#cccccc", --{255,255,255,255},
		label_text_font ="FreeSans Bold 20px", 
    	label_text_color = "#808080",
        item_text_font = "FreeSans Bold 20px",
    	item_text_color = "#ffffff",
		ui_position = {971,28,0}, 
		button_name = "menuButton_view", 
	}

menuButton_view.insert_item(1,{type="label", string="  Background:", bg=assets("assets/menu-item-label.png")} )
menuButton_view.insert_item(2,{type="item", string="Image...", bg=assets("assets/menu-item.png"), focus=assets("assets/menu-item-focus.png"), f=editor.image, parameter=true, icon=assets("assets/menu-checkmark.png")})
menuButton_view.items[2]["icon"].opacity = 0
menuButton_view.insert_item(3,{type="item", string="Small Grid", bg=assets("assets/menu-item.png"), focus=assets("assets/menu-item-focus.png"), f=editor.small_grid, icon=assets("assets/menu-checkmark.png")} )
menuButton_view.items[3]["icon"].opacity = 0
menuButton_view.insert_item(4,{type="item", string="Medium Grid", bg=assets("assets/menu-item.png"), focus= assets("assets/menu-item-focus.png"), f=editor.medium_grid, icon=assets("assets/menu-checkmark.png")})
menuButton_view.insert_item(5,{type="item", string="Large Grid", bg=assets("assets/menu-item.png"), focus= assets("assets/menu-item-focus.png"), f=editor.large_grid, icon=assets("assets/menu-checkmark.png")}) 
menuButton_view.items[5]["icon"].opacity = 0
menuButton_view.insert_item(6,{type="item", string="White", bg=assets("assets/menu-item.png"), focus= assets("assets/menu-item-focus.png"), f=editor.white_bg, icon=assets("assets/menu-checkmark.png")})
menuButton_view.items[6]["icon"].opacity = 0
menuButton_view.insert_item(7,{type="item", string="Black", bg=assets("assets/menu-item.png"), focus= assets("assets/menu-item-focus.png"), f=editor.black_bg, icon=assets("assets/menu-checkmark.png")}) 
menuButton_view.items[7]["icon"].opacity = 0

function menu.clearMenuButtonView_BGIcons() 
	menuButton_view.items[2]["icon"].opacity = 0
	menuButton_view.items[3]["icon"].opacity = 0
	menuButton_view.items[4]["icon"].opacity = 0
	menuButton_view.items[5]["icon"].opacity = 0
	menuButton_view.items[6]["icon"].opacity = 0
	menuButton_view.items[7]["icon"].opacity = 0
end 

menuButton_view.insert_item(8,{type="label", string="  Guides:", bg=assets("assets/menu-item-label.png")} )
menuButton_view.insert_item(9,{type="item", string="Add Horizontal Guide", bg=assets("assets/menu-item.png"), focus= assets("assets/menu-item-focus.png"), f=editor.h_guideline})
--menuButton_view.insert_item(9,{type="item", string="Add Horizontal Guide", bg=assets("assets/menu-item.png"), focus= assets("assets/menu-item-focus.png"), f=editor.h_guideline, icon=Text{text="H"}})
menuButton_view.insert_item(10,{type="item", string="Add Vertical Guide", bg=assets("assets/menu-item.png"), focus= assets("assets/menu-item-focus.png"), f=editor.v_guideline})
--menuButton_view.insert_item(10,{type="item", string="Add Vertical Guide", bg=assets("assets/menu-item.png"), focus= assets("assets/menu-item-focus.png"), f=editor.v_guideline, icon=Text{text="V"}})
menuButton_view.insert_item(11,{type="item", string="Show Guides", bg=assets("assets/menu-item.png"), focus= assets("assets/menu-item-focus.png"), f=editor.show_guides, icon=assets("assets/menu-checkmark.png")}) 
menuButton_view.insert_item(12,{type="item", string="Snap to Guides", bg=assets("assets/menu-item-bottom.png"), focus= assets("assets/menu-item-bottom-focus.png"), f=editor.snap_guides, icon=assets("assets/menu-checkmark.png")}) 

menuButton_view.name = "menuButton_view"
menuButton_view.anchor_point = {71,30.5}
menuButton_view.extra.focus = {[65293] = "menuButton_view", [65361] = "menuButton_arrange", [65364]=menuButton_view.press_down, [65362]=menuButton_view.press_up }

menuButton_view.extra.reactive = true

 function menuButton_view:on_enter()
  	
	if menu_bar_hover == false then return true end 
	
	if current_focus and current_focus ~= menuButton_file and current_focus.name ~= "menuButton_view" then 
		local temp_focus = current_focus
	   	current_focus.clear_focus(nil,true)
		if temp_focus.is_in_menu == true then 
			temp_focus.fade_in = false
		end 
	end 
	
	if current_focus == nil or (current_focus and current_focus.name ~= "menuButton_view") then 
		menuButton_view.extra.set_focus(keys.Return)
		current_focus.name = "menuButton_view"
    end 

	return true
 end 

local menu_text = Text
	{
		color = "#cccccc",
		font = "FreeSans Bold 20px",
		text = "",
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
	

local menu_text_shadow = Text
	{
		color = "000000",
		font = "FreeSans Bold 20px",
		text = "",
		editable = true,
		wants_enter = false,
		wrap = false,
		wrap_mode = "CHAR",
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {350,30.5},
		name = "menu_text_shadow",
		position = {1501,48,0},
		size = {700,20},
		opacity = 255/2,
		reactive = false,
		cursor_visible =false,
		alignment ="RIGHT",
	}

screen:add(menu_bar,menuButton_file,menuButton_edit,menuButton_arrange,menuButton_view,menu_text,menu_text_shadow)
menu_items = {["menu_item"]=menu_item, 
			  ["menu_bar"]=menu_bar, 
			  ["menuButton_file"]=menuButton_file,
			  ["menuButton_edit"]= menuButton_edit, 
			  ["menuButton_arrange"]=menuButton_arrange, 
			  ["menuButton_view"] = menuButton_view,
			  ["menu_text"]=menu_text,
			  ["menu_text_shadow"]=menu_text_shadow 
			  } 

----------------------------------------------------------------------------
-- Hides Menu 
----------------------------------------------------------------------------
    menu.menuHide = function()

		for i,j in pairs (menu_items) do 
			j:hide()
		end 

		screen:grab_key_focus()
		menu_hide  = true 

    end 

----------------------------------------------------------------------------
-- Show Menu
----------------------------------------------------------------------------
    
    menu.menuShow = function()

		for i,j in pairs (menu_items) do 
			j:show()
			j:raise_to_top()
		end 

		screen:grab_key_focus()
		menu_hide  = false

    end 
----------------------------------------------------------------------------
-- Deactivate Menu 
----------------------------------------------------------------------------
function menu.deactivate_menu()
	local menu_hide = Rectangle{name = "menu_hide_rect", color = {0,0,0,0}, position = {0,0,0}, size = {menu_bar.w, menu_bar.h}, reactive = true} 

	function menu_hide.on_button_down()
		return true
	end 

	screen:add(menu_hide)

end 

----------------------------------------------------------------------------
-- Reactivate Menu 
----------------------------------------------------------------------------

function menu.reactivate_menu()
	screen:remove(screen:find_child("menu_hide_rect"))
end 

----------------------------------------------------------------------------
-- Menu Raise To Top
----------------------------------------------------------------------------
function menu.menu_raise_to_top() 
	menu.menuShow()
end 

screen:add(g)
menu.menu_raise_to_top()
editor_use = false

return menu, menu_items
