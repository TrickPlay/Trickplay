
-- TextField 
 
 function TextField (contents, width, height, border_width, border_color, focus_color, font, color, box_img, focus_box_img)

    local ring_size = {}
    local style = {}
    local padding_x     = 7
    local padding_y     = 7 
    local border_radius = 12

    if not contents then contents = "" end
    if not width then ring_size.width = 200 end
    if not height then ring_size.height = 60 end
    if not border_width then border_width  = 3 end
    if not border_color then border_color  = "FFFFFFC0" end 
    if not focus_color then focus_color  = "1b911b" end 
    if not font then style.font = "DejaVu Sans 30px"  end 
    if not color then style.color = "FFFFFF" end 
    if not box_img then box_img = assets("assets/smallbutton.png") end 
    if not focus_box_img then focus_box_img = assets("assets/smallbuttonfocus.png") end 

    local text = Text{text = contents, editable = true, cursor_visible = false, reactive = true}:set(style)

    local function draw_ring(c)
	local ring = Canvas{ size = {ring_size.width, ring_size.height} }
        ring:begin_painting()
        ring:set_source_color(c)
        ring:round_rectangle( padding_x + border_width / 2,
            padding_y + border_width / 2,
            ring_size.width - border_width - padding_x * 2 ,
            ring_size.height - border_width - padding_y * 2 ,
            border_radius )
    	ring:set_line_width (border_width)
        ring:stroke()
        ring:finish_painting()
        return ring
     end

     local box = draw_ring(border_color)
     local focus_box = draw_ring(focus_color)

     textField = Group
     {
        size = { ring_size.width , ring_size.height},
        children =
        {
            box:set{name="box", position = { 0 , 0 } },
	    focus_box:set{name="focus_box", position = { 0 , 0 }, opacity = 0},
            --box_img:set{name="button", position = { 0 , 0 } , size = { ring_size.width , ring_size.height } , opacity = 255 },
            --focus_box_img:set{name="focus", position = { 0 , 0 } , size = { ring_size.width , ring_size.height } , opacity = 0 },
            text:set{name = "text", position = {padding_x, (ring_size.height - text.h)/2} }
        }, 
       position = {200, 200, 0},  
       name = "textField", 
       reactive = true 
     }

     function textField.extra.on_focus_in()
          text:grab_key_focus()
	  box.opacity = 0 
          focus_box.opacity = 255
	  text.cursor_visible = true
     end

     function textField.extra.on_focus_out()
          box.opacity = 255 
          focus_box.opacity = 0
	  text.cursor_visible = false
     end

     function textField:on_button_down(x,y,button,num_clicks)
	if box.opacity == 255 then 
	     textField.extra.on_focus_in()
	else 
	     textField.extra.on_focus_out()
	end 
     end 


     mt = {}
     mt.__newindex = function (t, k, v)

     local function redraw_ring()
       box = draw_ring(border_color)
       box:set{name="box"}
       focus_box = draw_ring(focus_color)
       focus_box:set{name="focus_box", opacity = 0}
       text:set{position={padding_x, (ring_size.height - text.h)/2} }  
       textField:remove(textField:find_child("box"))  
       textField:add(box)
       textField:remove(textField:find_child("focus_box"))  
       textField:add(focus_box)
     end  

     if k == "contents" then 
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
     elseif (k == "border_width") then 
       border_width= v
       redraw_ring()
     elseif (k == "border_color" or k == "bc") then 
       border_color= v
       redraw_ring()
     elseif (k == "focus_color" or k == "fc") then 
       focus_color= v
       redraw_ring()
     elseif (k == "font") then 
       text:set{font = v}
     elseif (k == "color") then 
       text:set{color = v}
     end 
     end 

     mt.__index = function (t,k)
     if k == "contents" then 
        return text.text
     elseif k == "bsize" then 
        return ring_size 
     elseif (k == "bwidth" or k == "bw") then 
        return ring_size.width
     elseif (k == "bheight" or k == "bh") then 
        return ring_size.height 
     elseif (k == "border_width") then 
        return border_width
     elseif (k == "border_color") then 
        return border_color
     elseif (k == "focus_color") then 
        return focus_color
     elseif (k == "font") then 
        return font
     elseif (k == "color") then 
        return color
     end 
     end 
  
     setmetatable (textField.extra, mt) 
     return textField
end 
