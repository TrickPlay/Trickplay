
local contents = app.contents

local H = 44
local top = 10
local left = 10

local tests = {}

local last_run = settings.last

local focused = nil

for i = 1 , #contents do
    local file = contents[ i ]
    local name = string.match( file , "examples/(.*)%.lua" )
    if name then
        name = string.gsub( name , "_" , " " )
        local text = Text
        {
            font = "FreeSans "..tostring( H - 14 ).."px",
            color = "FFFFFF",
            text = name,
            x = left,
            y = top,
            extra = { file = file }
        }
        
        screen:add( text )
        
        table.insert( tests , text )
        
        top = top + H
        if top + H > screen.h then
            top = 10
            left = left + screen.w / 4
        end
        
        if last_run == file then
            focused = # tests
        end
        
    end
end
    
if # tests > 0 then

    focused = focused or 1
    
    local focus = Rectangle
    {
        color = "964e20" ,
        size = { screen.w / 4 , H } ,
        position = tests[ focused ].position
    }
    
    screen:add( focus )
    
    focus:lower_to_bottom()
        
    function screen.on_key_down( screen , key )
        
        if key == keys.Up and focused > 1 then
            focused = focused - 1
            focus.position = tests[ focused ].position
        elseif key == keys.Down and focused < # tests then
            focused = focused + 1
            focus.position = tests[ focused ].position
        elseif key == keys.Return then
            local file = tests[ focused ].extra.file
            settings.last = file
            screen:clear()
            screen.on_key_down = nil
            dofile( file )
        end
        
    end
    
end
    
screen:show()