
-- Button 

 function Button (width, height, border_width, border_color, caption, font, color, button, focus)

    local ring_size = {}
    local style = {}
    local padding_x     = 7
    local padding_y     = 7 
    local border_radius = 12
    

    if not width then ring_size.width = 180 end
    if not height then ring_size.height = 60 end
    if not border_width then border_width  = 1 end
    if not border_color then border_color  = "FFFFFF" end 
    if not caption then caption = "Button" end
    if not font then style.font = "DejaVu Sans 30px"  end 
    if not color then style.color = "FFFFFF" end 
    if not button then button = assets("assets/smallbutton.png") end 
    if not focus then focus = assets("assets/smallbuttonfocus.png") end 

    local function make_ring()
        local ring = Canvas{ size = {ring_size.width, ring_size.height } }
        ring:begin_painting()
        ring:set_source_color( border_color )
        ring:round_rectangle(
            padding_x + border_width / 2,
            padding_y + border_width / 2,
            ring_size.width - border_width - padding_x * 2 ,
            ring_size.height - border_width - padding_y * 2 ,
            border_radius )
        ring:stroke()
        ring:finish_painting()
        return ring
    end 

    local ring = make_ring ()

    local text = Text{text = caption}:set( style )
    text.name = "caption"
    text.reactive = true

    --local focus = assets( "assets/button-focus.png" )
    

    group = Group
    {
        size = { ring_size.width , ring_size.height},
        children =
        {
            ring:set{name="ring", position = { 0 , 0 } },
            button:set{name="button", position = { 0 , 0 } , size = { ring_size.width , ring_size.height } , opacity = 255 },
            focus:set{name="focus", position = { 0 , 0 } , size = { ring_size.width , ring_size.height } , opacity = 0 },
            text:set{name = "text", position = { (ring_size.width  -text.w)/2, (ring_size.height - text.h)/2} }
        }, 
       position = {100, 100, 0},  
       name = "button", 
       reactive = true 
    }
    
    function group.extra.on_focus_in()
        focus.opacity = 255
	group:grab_key_focus(group)
    end
    
    function group.extra.on_focus_out()
        focus.opacity = 0
    end
	
    function group:on_button_down(x,y,button,num_clicks)
    end 

    mt = {}
    mt.__newindex = function (t, k, v)

    local function redraw_ring()
       ring = make_ring()
       ring:set{name="ring"}
       focus:set{size={ring_size.width , ring_size.height }}
       text:set{position={(ring_size.width  -text.w)/2, (ring_size.height - text.h)/2} }  
       group:remove(group:find_child("ring"))  
       group:add(ring)
    end  

    if k == "caption" then
       text.text = v
    elseif k == "bsize" then 
       ring_size.width = v[1]
       ring_size.height = v[2]
       redraw_ring()
    elseif (k == "bwidth" or k == "bw" )then 
       ring_size.width = v
       redraw_ring()
    elseif (k == "bheight" or k == "bh") then 
       ring_size.height = v
       redraw_ring()
    end 
    end 

    mt.__index = function (t,k)
    if k == "caption" then 
        return text.text
    elseif k == "bsize" then 
        return ring_size 
    elseif (k == "bwidth" or k == "bw") then 
        return ring_size.width
    elseif (k == "bheight" or k == "bh") then 
        return ring_size.height 
 --[[
    elseif (k == "on_focus_in" ) then 
	return function ()
         focus.opacity = 255
 	 group:grab_key_focus(group)
         end
    elseif (k == "on_focus_out" ) then 
	return function ()
         focus.opacity = 0
         end
    ]]
    end 
    end 
  
  setmetatable (group.extra, mt) 

  return group 

end
