
--------------------------------------------------------------------------------
--Timer Numbers
--------------------------------------------------------------------------------
local timer_numbers = {}

for i = 0,9 do
    
    local t = Text{
        text = i,
        font = "DejaVu Sans Mono 100px"
    }
    
    local c = Canvas(t.w,t.h)
    
    c:text_element_path(t)
    
    c:set_source_color("ffffff")
    
    c:stroke(true)
    
    c:set_source_color("ff0000")
    
    c:fill(true)
    
    timer_numbers[i] = c:Image()
    
    clone_sources_layer:add( timer_numbers[i] )
    
end
--]]

local digits = {}

function start_timer(start_value,callback)
    
    local num_digits = 0
    
    while(start_value / 10 > 1) do
        
        start_value = start_value / 10
        
        num_digits = num_digits + 1
        
    end
    
end