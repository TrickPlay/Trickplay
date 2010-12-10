
local ROWS  = 4
local COLS  = 4

local BOX_W = screen.w / COLS
local BOX_H = screen.h / ROWS

local actors = 0

local function count_children( e )
    local count = 1
    local children = e.children
    if children then
        for i = 1 , # children do
            count = count + count_children( children[ i ] )
        end
    end
    return count
end

for r = 1 , ROWS do
    
    for c = 1 , COLS do
    
        local globe = Image{ src = "assets/globe.png" }
        
        local g = Group
        {
            size = { BOX_W , BOX_H } ,
            clip = { 0 , 0 , BOX_W , BOX_H },
            position = { BOX_W * ( c - 1 ) , BOX_H * ( r - 1 ) },
            
            children =
            {
                Text
                {
                    font = "DejaVu Sans bold 60px" ,
                    color = "FFFFFFAA" ,
                    text = "TrickPlay",
                    position = { 20 , 20 }
                }
                ,
                Rectangle
                {
                    color = "FF000022",
                    size = { BOX_W - 60 , BOX_H - 60 },
                    position = { 60 , 60 }
                }
                ,
                Rectangle
                {
                    color = "00FF00CC",
                    size = { BOX_W / 4 , BOX_H / 4 },
                    position = { BOX_W / 2 , BOX_H / 2 },
                    z_rotation = { 45 , BOX_W / 8 , BOX_H / 8 },
                }
                ,
                Rectangle
                {
                    color = "0000FFCC",
                    size = { BOX_W / 4 , BOX_H / 4 },
                    position = { BOX_W / 2 , BOX_H / 2 },
                    z_rotation = { 75 , BOX_W / 8 , BOX_H / 8 },
                }
                ,
                Rectangle
                {
                    color = "FF0000CC",
                    size = { BOX_W / 4 , BOX_H / 4 },
                    position = { BOX_W / 2 , BOX_H / 2 },
                    z_rotation = { 105 , BOX_W / 8 , BOX_H / 8 },
                }
                ,
                globe:set
                {
                    scale = { 0.4 , 0.4 },
                    position = { BOX_W / 3 , BOX_H / 2 },
                    y_rotation = { -5 , globe.w * 0.2 , 0 }
                }
                ,
                Group
                {
                    size = { BOX_W , BOX_H },
                    position = { 0 , 0 },
                    x_rotation = { 39 , 0 , 0 },
                    children =
                    {
                        Clone
                        {
                            source = globe,
                            opacity = 0,
                            scale = { 1 , 1 }
                        },
                        Clone
                        {
                            source = globe,
                            opacity = 0,
                            scale = { 1.5 , 1 }
                        },
                        Clone
                        {
                            source = globe,
                            opacity = 0,
                            scale = { 2 , 0.1 }
                        },
                        Clone
                        {
                            source = globe,
                            opacity = 0,
                            scale = { 0.33 , 7 }
                        }
                    }
                }
                ,
                Text
                {
                    font = "DejaVu Sans italic bold 190px",
                    color = "333333FF",
                    text = "Benchmark",
                    position = { BOX_W / 4 , BOX_H - 40 },
                    z_rotation = { -45 , 0 , 0 }
                }
            }
        }
        
        screen:add( g )
        
        actors = actors + count_children( g )
    
    end
    
end

screen:show()

local function start()

    local W = 23

    local sweeper =
    
        Group
        {
            position = { 0 , 0 },
            children =
            {
                Rectangle
                {
                    size = { W , screen.h },
                    color = "FFFFFFFF",
                    position = { 0 , 0 },
                }
                ,
                Rectangle
                {
                    size = { W , screen.h },
                    color = "000000FF",
                    position = { W , 0 },
                }
                ,
                Rectangle
                {
                    size = { W , screen.h },
                    color = "FFFFFF88",
                    position = { W * 2 , 0 },
                }
                ,
                Rectangle
                {
                    size = { W , screen.h },
                    color = "000000FF",
                    position = { W * 3 , 0 },
                }
                ,
                Rectangle
                {
                    size = { W , screen.h },
                    color = "FFFFFFFF",
                    position = { W * 4 , 0 },
                }
            }
        }
        
    local ticks = 0
        
    local timer = Timer( 100 )
    
    function timer:on_timer( )
        ticks = ticks + 1
    end
    
    timer:start()
        
    screen:add( sweeper )

    idle.limit = 1 / 60 

    local total     = Stopwatch()
    local frames    = 0
    local iteration = 1
    
    function idle:on_idle( seconds )
    
        sweeper.x = sweeper.x + 2
        
        frames = frames + 1
        
        if sweeper.x == screen.w then
        
            total:stop()
            
            if iteration == 1 then
                local tv = ( trickplay and trickplay.version ) or "< 0.0.12"
            
                print( "" )
                print( "PLEASE NOTE the clutter version (/ver) and whether profiling is enabled (/prof)" )
                print( "TRICKPLAY VERSION  : "..tv )
                print( "BENCHMARK VERSION  : "..md5( readfile( "main.lua" ) ) )
                print( "DISPLAY DIMENSIONS : "..string.format( "%dx%d" , screen.display_size[1] , screen.display_size[2] ) )
                print( "" )
                print( "#\ttick %\tactors\tframes\ts\tfps" )
            end
            
            print( string.format( "%d\t%d\t%d\t%d\t%2.3f\t%d" ,
                iteration,
                math.ceil( ticks / ( total.elapsed / timer.interval ) * 100 ),
                actors,
                frames ,
                total.elapsed_seconds ,
                frames / total.elapsed_seconds ) )
                
            sweeper.x = 0
            iteration = iteration + 1
            frames = 0
            ticks = 0
            total:start()
        end
        
    end

end

dolater( start )

