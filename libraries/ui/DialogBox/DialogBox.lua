--[[
Function: dialogBox

Creates a Dialog box ui element

Arguments:
	Table of Dialog box properties

	skin - Modify the skin used for the dialog box by changing this value
    bwidth  - Width of the dialog box 
    bheight - Height of the dialog box
    label - Title in the dialog box
    fill_color - Background color of the dialog box
    border_color - Border color of the dialog box
    title_color - Color of the dialog box text 
    title_font - Font of the text in the dialog box
    border_width - Border width of the dialog box  
    border_corner_radius - The radius of the border of the dialog box
	title_separator_thickness - Thickness of the title separator 
	title_separator_color - Color of the title separator 
    padding_x - Padding of the dialog box on the X axis
    padding_y - Padding of the dialog box on the Y axis

Return:
 	db_group - group containing the dialog box
]]

--[[

-- Dialog Box with josh's canvas image 

function ui_element.dialogBox(t) 
 
--default parameters
   local p = {
	skin = "Custom", 
	ui_width = 500 ,
	ui_height = 400 ,
	label = "Dialog Box Title" ,
	border_color  = {255,255,255,255}, --"FFFFFFC0" , 
	fill_color  = {25,25,25,100},
	title_color = {255,255,255,255} , --"FFFFFF" , 
	border_width  = 12 ,
	padding_x = 0 ,
	padding_y = 0 ,
	border_corner_radius = 22 ,
	title_font = "FreeSans Medium 28px" , 
	title_separator_thickness = 10, 
	title_separator_color = {100,100,100,100},
	content = Group{}--children = {Rectangle{size={20,20},position= {100,100,0}, color = {255,255,255,255}}}},
    }

 --overwrite defaults
    if t ~= nil then 
        for k, v in pairs (t) do
	    p[k] = v 
        end 
    end 

 --the umbrella Group
    local db_group_cur_y = 6

    local  db_group = Group {
    	  name = "dialogBox",  
    	  position = {200, 200, 0}, 
          reactive = true, 
          extra = {type = "DialogBox"} 
    }


    local create_dialogBox  = function ()

    	local d_box, title_separator, title, d_box_img, title_separator_img
   
    	db_group:clear()
    	db_group.size = { p.ui_width , p.ui_height }

		if p.skin == "Custom" then 
			local key = string.format("dBG:%d,%d,%d,%s", p.ui_width, p.ui_height, p.border_width, color_to_string(p.title_separator_color))

			d_box = assets(key, my_draw_dialogBG, p.ui_width, p.ui_height, p.border_width, p.title_separator_color)
			d_box.y = d_box.y 
			d_box:set{name="d_box"} 

    		title= Text{text = p.label, font= p.title_font, color = p.title_color}     
    		title:set{name = "title", position = {(p.ui_width - title.w - 50)/2 , db_group_cur_y - 5}}
			db_group:add(d_box,title)
		else 
        	d_box_img = assets(skin_list[p.skin]["dialogbox"])
        	d_box_img:set{name="d_box_img", size = { p.ui_width , p.ui_height } , opacity = 0}
			db_group:add(d_box_img, title)
		end

		if p.content then 
	     	db_group:add(p.content)
		end 

     end 

     create_dialogBox ()

     mt = {}
     mt.__newindex = function (t, k, v)
	 	if k == "bsize" then  
	    	p.ui_width = v[1] 
	    	p.ui_height = v[2]  
        else 
           p[k] = v
        end
		if k ~= "selected" then 
        	create_dialogBox()
		end
     end 

     mt.__index = function (t,k)
	if k == "bsize" then 
	    return {p.ui_width, p.ui_height}  
        else 
	    return p[k]
        end 
     end 

     setmetatable (db_group.extra, mt) 
     return db_group
end 
]]

function ui_element.dialogBox(t) 
 
--default parameters
   local p = {
	skin = "Custom", 
	ui_width = 500 ,
	ui_height = 400 ,
	label = "Dialog Box Title" ,
	border_color  = {255,255,255,100}, --"FFFFFFC0" , 
	fill_color  = {255,255,255,100},
	title_color = {255,255,255,180} , --"FFFFFF" , 
	title_font = "FreeSans Medium 28px" , 
	border_width  = 4 ,
	padding_x = 0 ,
	padding_y = 0 ,
	border_corner_radius = 22 ,
	title_separator_thickness = 4, 
	title_separator_color = {255,255,255,100},
	content = Group{}--children = {Rectangle{size={20,20},position= {100,100,0}, color = {255,255,255,255}}}},
    }

 --overwrite defaults
    if t~= nil then 
        for k, v in pairs (t) do
	    p[k] = v 
        end 
    end 

 --the umbrella Group
    local db_group_cur_y = 6

    local  db_group = Group {
    	  name = "dialogBox",  
    	  position = {200, 200, 0}, 
          reactive = true, 
          extra = {type = "DialogBox"} 
    }


    local create_dialogBox  = function ()
   
    	local d_box, title_separator, title, d_box_img, title_separator_img, key

        db_group:clear()
        db_group.size = { p.ui_width , p.ui_height - 34}

		if p.skin == "Custom" then 
			key = string.format("dialogBox:%d:%d:%d:%s:%s:%d:%d:%d:%d:%s", p.ui_width, p.ui_height, p.border_width, color_to_string(p.border_color), color_to_string( p.fill_color ), p.padding_x, p.padding_y, p.border_corner_radius, p.title_separator_thickness, color_to_string( p.title_separator_color))

        	d_box = assets(key, my_make_dialogBox_bg, p.ui_width, p.ui_height, p.border_width, p.border_color, p.fill_color, p.padding_x, p.padding_y, p.border_corner_radius, p.title_separator_thickness, p.title_separator_color) 

			d_box.y = d_box.y - 34
			d_box:set{name="d_box"} 
			db_group:add(d_box)
		else 
        	--d_box_img = assets(skin_list[p.skin]["dialogbox"])
        	--d_box_img:set{name="d_box_img", size = { p.ui_width , p.ui_height } , opacity = 0}
			--db_group:add(d_box_img)

			p.title_font = "FreeSans Medium 24px"  
			p.title_separator_thickness = 10
			p.title_separator_color = {100,100,100,100}

			local key = string.format("dBG:%d,%d,%d,%s", p.ui_width, p.ui_height, p.border_width, color_to_string(p.title_separator_color))

			d_box = assets(key, my_draw_dialogBG, p.ui_width, p.ui_height, p.border_width, p.title_separator_color)
			d_box.y = d_box.y 
			d_box:set{name="d_box"} 

    		title= Text{text = p.label, font= p.title_font, color = p.title_color}     
    		title:set{name = "title", position = {(p.ui_width - title.w - 50)/2 , db_group_cur_y - 5}}
			db_group:add(d_box)

			db_group.w = d_box.w
			db_group.h = d_box.h

		end
        title= Text{text = p.label, font= p.title_font, color = p.title_color}     
        title:set{name = "title", position = {(p.ui_width - title.w )/2 , db_group_cur_y }}
		db_group:add(title)

		if p.content then 
	     	db_group:add(p.content)
		end 
     end 

     create_dialogBox ()

     mt = {}
     mt.__newindex = function (t, k, v)
	 	if k == "bsize" then  
	    	p.ui_width = v[1] 
	    	p.ui_height = v[2]  
        else 
           p[k] = v
        end
		if k ~= "selected" then 
        	create_dialogBox()
		end
     end 

     mt.__index = function (t,k)
	if k == "bsize" then 
	    return {p.ui_width, p.ui_height}  
        else 
	    return p[k]
        end 
     end 

     setmetatable (db_group.extra, mt) 
     return db_group
end 