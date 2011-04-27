

local line = Rectangle{ color = "FF0000" , size = { 4 , screen.h } , position = { 0 , 0 } }

screen:add( line )

local first = true
local watch = Stopwatch()
local right = keys.Right

local min = 1000000
local max = 0
local count = 0
local total = 0
local target_x = screen.w / 4
local timer = Timer( 8000 )

function timer.on_timer( timer )
    timer.on_timer = nil
    screen.on_key_down = nil
    screen:clear()
    finish_test( 0 , "" , "Timed out" )
end

timer:start()

screen:add( Clone{ source = line , x = target_x } )

function screen.on_key_down( screen , key )

    if key == right then
        if first then
            timer:stop()
            first = false
            watch:start()
        else
            local t = watch.elapsed
            min = math.min( min , t )
            max = math.max( max , t )
            count = count + 1
            total = total + t
            
            line.x = line.x + 1
            if line.x >= target_x then
            
                screen.on_key_down = nil
                screen:clear()
                finish_test( total / 1000 , "s" , string.format( "(min=%d ms max = %d ms average=%d ms)" , min  , max , total / count ) )
            
            else
            
                watch:start()
            end
        end
    end
end

title( "Press and hold the right arrow key" )

