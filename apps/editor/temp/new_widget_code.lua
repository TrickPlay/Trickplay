

--[[


 	 Drop Down Button : 

]]


--[[
function widget.dropDownButton(table) 

 --default parameters
    local p = {
    	font = "DejaVu Sans 30px",
    	color = {255,255,255,255}, --"FFFFFF",
    	skin = "canvas", 
    	wwidth = 180,
    	wheight = 60, 
	items = {"item1", "item2", "item3"},

    	text = "Button", 
    	focus_color = {27,145,27,255}, --"1b911b", 

    	border_color = {255,255,255,255}, --"FFFFFF"
    	border_width = 1,
    	padding_x = 0,
    	padding_y = 0,
    	border_radius = 0,
    }

 --overwrite defaults
    if table ~= nil then 
        for k, v in pairs (table) do
	    p[k] = v 
        end 
    end 

 --the umbrella Group
    local ring, focus_ring, text, button, focus 
    local items = Group{name = "items"}

    b_group = Group
    {
        name = "button", 
        size = { p.wwidth , p.wheight},
        position = {100, 100, 0},  
        reactive = true,
        extra = {type = "Button"}
    } 

    local create_button = function() 
    

	if(p.skin ~= "canvas") then 
		p.button_image = assets(skin_list[p.skin]["button"])
		p.focus_image  = assets(skin_list[p.skin]["button_focus"])
	end
        b_group:clear()
        b_group.size = { p.wwidth , p.wheight}

        button_ring = make_ring(p.wwidth, p.wheight, p.border_color, p.border_width, p.padding_x, p.padding_y, p.border_radius)
        button_ring:set{name="ring", position = { 0 , 0 }, opacity = 255 }

        focus_ring = make_ring(p.wwidth, p.wheight, p.focus_color, p.border_width, p.padding_x, p.padding_y, p.border_radius)
        focus_ring:set{name="focus_ring", position = { 0 , 0 }, opacity = 0}

       	
	if(p.skin ~= "canvas") then 
            button = assets(skin_list[p.skin]["button"])
            button:set{name="button", position = { 0 , 0 } , size = { p.wwidth , p.wheight } , opacity = 255}
            focus = assets(skin_list[p.skin]["button_focus"])
            focus:set{name="focus", position = { 0 , 0 } , size = { p.wwidth , p.wheight } , opacity = 0}
	else 
	     button = Image{}
	     focus = Image{}
	end 
        text = Text{name = "text", text = p.text, font = p.font, color = p.color} --reactive = true 
        text:set{name = "text", position = { (p.wwidth  -text.w)/2, (p.wheight - text.h)/2}}

	for i, j in pairs(p.items) do 
               items:add(Text{name="item"..tostring(i), text = j, font=p.font, color =p.color, opacity = 255})     
     	end 

	local function find_item_ring_sz()
	    local items_w = 0 
	    local items_h = 0	
	    for i, j in pairs(items) do 
	    	if (j.w > items_w) then   
		     items_w = j.w
		end 
	        items_h = items_h + j.h
	    end 

	    
	    return items_w, items_h
	end 

        items_w, items_h = find_item_ring_sz()

	for i, j in pairs(items.children) do 
               j.position = {p.wwidth/2 - j.width/2, p.wheight/2 - j.height/2}
               j.position = {p.wwidth/2 - j.width/2 + j_padding, p.wheight/2 - j.height/2}
     	end 

 	item_ring = make_ring(items_w, items_h, p.border_color, p.border_width, p.padding_x, p.padding_y, p.border_radius)


        b_group:add(button_ring, focus_ring, button, focus, text)

        if (p.skin == "canvas") then button.opacity = 0 print("heheheheh")
        else button_ring.opacity = 0 end 

    end 

    create_button()

    function b_group.extra.on_focus_in() 
        if (p.skin == "canvas") then 
	     button_ring.opacity = 0
	     focus_button_ring.opacity = 255
        else
	     button.opacity = 0
             focus.opacity = 255
        end 
	b_group:grab_key_focus(b_group)
    end
    
    function b_group.extra.on_focus_out() 
        if (p.skin == "canvas") then 
	     button_ring.opacity = 255
	     focus_ring.opacity = 0
             focus.opacity = 0
        else
	     button.opacity = 255
             focus.opacity = 0
	     focus_ring.opacity = 0
        end 
    end
	
    mt = {}
    mt.__newindex = function (t, k, v)
        if k == "bsize" then  
	    p.wwidth = v[1] p.wheight = v[2]  
        else 
           p[k] = v
        end
        create_button()
    end 

    mt.__index = function (t,k)
        if k == "bsize" then 
	    return {p.wwidth, p.wheight}  
        else 
	    return p[k]
        end 
    end 

    setmetatable (b_group.extra, mt) 

    return b_group 
end


-]]


--[[ Group Selector ]]






