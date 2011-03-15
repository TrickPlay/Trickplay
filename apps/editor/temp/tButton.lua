
-- Button 

 Button {
    style         = { font = "DejaVu Sans 30px" , color = "FFFFFF" }, 
    padding_x     = 7,
    padding_y     = 7, 
    width         = 180,
    height        = 60, 
    border_width  = 1,
    border_color  = "FFFFFF",
    border_radius = 12,
    caption = "Button",

    local function make_ring()
        local ring = Canvas{ size = { width , height } }
        ring:begin_painting()
        ring:set_source_color( border_color )
        ring:round_rectangle(
            padding_x + border_width / 2,
            padding_y + border_width / 2,
            width - border_width - padding_x * 2 ,
            height - border_width - padding_y * 2 ,
            border_radius )
        ring:stroke()
        ring:finish_painting()
        return ring
    end,

    local ring = make_ring (),

    local text = Text{ text = caption}:set( style ),
    text.name = "caption",
    text.reactive = true,

    local focus = assets( "assets/button-focus.png" ),

    local group = Group
    {
        size = { width , height },
        children =
        {
            ring:set{ position = { 0 , 0 } },
            focus:set{ position = { 0 , 0 } , size = { width , height } , opacity = 0 },
            text:set{ position = { (width  -text.w)/2, (height - text.h)/2} }
        }, 
       position = {100, 100, 0},  
       name = "button", 
       reactive = true 
    },
    
    function group.extra.on_focus_in()
        focus.opacity = 255
	group:grab_key_focus(group)
    end
    
    function group.extra.on_focus_out()
        focus.opacity = 0
    end
	
    function group:on_button_down(x,y,button,num_clicks)
	if(focus.opacity == 0) then 
		group.on_focus_in()
	else 
		group.on_focus_out()
	end 
    end 


}

 function Button:new(o)
      o = o or {}   -- create object if user does not provide one
      setmetatable(o, self)
      self.__index = self
      return self.group 
 end


 b = Button:new{caption = "", color = {10,10,10,100}, position = {200,200,200}


 



    
--[[
    mt = {}
    mt.__newindex = function (t, k, v)

    if k == "caption" then
       text.text = v
    end 
    end 

    mt.__index = function (t,k)
    --if k == "text" then 
    --return "the value" 
    --end 
    end 
  
  setmetatable (group, mt) 
 ]]

