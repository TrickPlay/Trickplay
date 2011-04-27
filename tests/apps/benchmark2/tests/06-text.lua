
local fonts =
{
    "Accidental Presidency",
    "Anivers",
    "Arcade",
    "Aurulent Sans",
    "Banhart",
    "Blackout",
    "Blue Highway",
    "Comfortaa",
    "DejaVu Sans",
    "Delicious",
    "Diavlo",
    "Eraser",
    "Fertigo",
    "Fontin",
    "FreeFont",
    "GraublauWeb",
    "Junction",
    "Liberation Sans",
    "Minya Nouvelle",
    "Museo",
    "Orbitron",
    "Pakenham",
    "Raleway",
    "Sniglet",
    "Steelfish",
    "Teen",
    "X360"    
}

local top = 0
local size = 40
local left = screen.w

for i = 1 , # fonts do
    
    local text = Text
    {
        font = fonts[ i ].." "..tostring( size ).."px",
        color = "FFFFFF" ,
        x = left,
        y = top,
        text = fonts[ i ].." : The quick brown fox jumps over the lazy dog.0123456789"
    }
    
    if left == 0 then
        left = screen.w
    else
        left = 0
    end
    
    screen:add( text )
    
    top = top + size
end

screen:show()

idle.limit = 1/60

local total = Stopwatch()
local ticks = 0
local target_x = screen.w / 2

function idle.on_idle()
    local c = screen.children
    local d = -1
    for i = 1 , # c do
        c[ i ].x = c[ i ].x + d
        d = -d
    end
    ticks = ticks + 1
    if ticks == target_x then
        
        local t = total.elapsed_seconds
        idle.on_idle = nil
        screen:clear()
        finish_test( ticks / t , "fps" )
    end
end
        