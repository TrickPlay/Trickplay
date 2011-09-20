
local function go()

    local images = {}
    
    local contents = app.contents
    
    for i = 1 , # contents do
        if string.match( contents[ i ] , "assets%/image%-load%/.*" ) then
            table.insert( images , contents[ i ] )
        end
    end
    
    local total = 0
    local sw = Stopwatch()
    
    for k = 1 , 5 do
        for i = 1 , # images do
            local b = Bitmap( images[ i ] )
            sw:start()
            local image = b:Image()
            screen:add( image )
            sw:stop()
            total = total + sw.elapsed_seconds
            b = nil
            screen:remove( image )
            image = nil
            for j = 1 , 10 do
                collectgarbage( "collect" )
            end
        end
    end
    
    finish_test( total , "s" )

end

title( "Image upload" )

dolater( go )